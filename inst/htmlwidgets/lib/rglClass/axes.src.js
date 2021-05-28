    /**
     * Methods related to axes
     * @name ___METHODS_FOR_AXES___
     * @memberof rglwidgetClass
     * @kind function
     * @instance
     */
     
    /**
     * Choose edges for ticks
     * @param { Matrix } prmv - projection-model-view matrix
     */
    rglwidgetClass.prototype.getTickEdges = function(prmv){
      var vertices = [[0,0,0,1], [0,0,1,1],
                      [0,1,0,1], [0,1,1,1],
                      [1,0,0,1], [1,0,1,1],
                      [1,1,0,1], [1,1,1,1]], 
           dim, i, j, k, edges, hull, step, result = [], proj = [];
      for (i = 0; i < vertices.length; i++) {
        proj[i] = this.multVM(vertices[i], prmv);
        proj[i][0] = proj[i][0]/proj[i][3];
        proj[i][1] = proj[i][1]/proj[i][3];
        proj[i][2] = i;
      }
      hull = this.chull(proj.slice());  
      for (i = 0; i < hull.length; i++)
        hull[i] = hull[i][2];
      hull.push(hull[0]);
      for (dim = 0; dim < 3; dim++) { 
        edges = [];
        step = Math.pow(2, 2-dim);
        for (i = 0; i < 4; i++) {
          j = (dim === 0) ? i : (dim === 1) ? i + 2*(i>1) : 2*i;
          for (k = 0; k < hull.length - 1; k++) {
            if ((hull[k] === j && hull[k+1] === j + step) ||
                (hull[k] === j+step && hull[k+1] === j))
          
              edges.push([j, j+step], [j+step, j]);
          }
        }
        // Find the edge with a vertex closest
        // to the bottom left corner
        if (edges.length) {
          var best, best2, val = Infinity, newval;
          for (i = 0; i < edges.length; i++) {
            j = edges[i][0];
            newval = proj[j][0] + proj[j][1];
            if (newval < val) {
              best = j;
              best2 = edges[i][1];
              val = newval;
            }
          }
          result[dim] = vertices[best].slice(0,3);
          result[dim][dim] = undefined;
        }
      }
      return result;
    };
    
    /**
     * Choose tick locations
     * @param { Object } obj - The bboxdeco
     * @param { Array }  bbox - The bounding box limits
     * @param { Array }  edges - Which edges get the ticks?
    */
    rglwidgetClass.prototype.getTickLocations = function(obj){
      var dim, i, limits, locations = [], result = [[],[],[]], value,
          len, delta, range, bbox = obj.bbox;
      for (dim = 0; dim < 3; dim++) {
        limits = bbox.slice(2*dim, 2*dim + 2);
        range = limits[1] - limits[0];
        switch(obj.axes.mode[dim]) {
        case "custom":
          for (i=0; i < obj.vertices.length; i++) {
            value = (obj.vertices[i][dim] - limits[0])/range;
            if (typeof value !== "undefined")
              result[dim].push(value);
          }
          break;
        case "fixedstep":
          len = Math.floor(range/obj.axes.unit[dim]);
          delta = obj.axes.unit[dim];
          for (i = 0; i < len; i++)
            result[dim].push(i*delta);          
          break;
        case "fixednum":
          len = obj.axes.nticks[dim];
          delta = (len > 1) ? range/(len-1) : 0;
          for (i = 0; i < len; i++)
            result[dim].push(i*delta/range);
          break;
        case "pretty":
          locations = this.R_pretty(limits[0], limits[1], 5,
                                  2, // min_n
                                  0.75, // shrink_sml
                                  [1.5, 2.75], // high_u_fact
                                  0, // eps_correction
                                  0); // return_bounds)  
          for (i = locations.lo; i <= locations.up; i++) {
            value = (i*locations.unit - limits[0])/range;
            if (0 < value && value < 1)
              result[dim].push(value);
          }
        }
      }
      return result;
    };
    
    /**
     * Set tick vertices
     * @param { Object } ticks - the tick object
     * @param { Array }  edges - Which edges get the ticks?
    */
    rglwidgetClass.prototype.getTickVertices = function(ticks) {
      var dim, i, j, vertices = [], locations, 
          edges = ticks.edges, edge;
      for (dim = 0; dim < 3; dim++) {
        locations = ticks.locations[dim];
        if (locations.length)
          for (i = 0; i < locations.length; i++) 
            if (typeof edges[dim] !== "undefined") {
              edge = edges[dim].slice();
              edge[dim] = locations[i];
              vertices.push(edge);
              edge = edge.slice();
              for (j = 0; j < 3; j++)       
                if ((dim < 2 && j === 1 - dim) || 
                    (dim === 2 && j === 0))
                  edge[j] += 2*(edge[j] - 0.5)/ticks.axes.marklen[dim];
              vertices.push(edge);
            }
        }
      ticks.vertices = vertices;
      ticks.vertexCount = vertices.length;
      ticks.values = new Float32Array(this.flatten(vertices));
      ticks.initialized = false;
    };
    
    /**
     * Set tick labels
     * @param { Object } obj - the bbox object
    */
    rglwidgetClass.prototype.placeTickLabels = function(obj) {
      var ticks = obj.ticks, labels = obj.labels, i,j,k,
          vertices = [], tickvertices = ticks.vertices, 
          vertex, locations, dim, edges = obj.ticks.edges;
      j = 0;
      for (dim = 0; dim < 3; dim++) {
        if (typeof edges[dim] === "undefined") 
          continue;
        locations = ticks.locations[dim];
        if (locations.length)
          for (i = 0; i < locations.length; i++) {
            while (j < tickvertices.length && 
                   tickvertices[j][dim] !== locations[i]) j++;
            if (j >= tickvertices.length)
              break;
            vertex = tickvertices[j].slice();
            for (k = 0; k < 3; k++)
              vertex[k] += 2*(tickvertices[j+1][k] - vertex[k]);
            vertices.push(vertex);
            j += 2;
          }
        }
      labels.vertices = vertices;
      labels.centers = labels.vertices;
      labels.initialized = false;
    };  
     
    rglwidgetClass.prototype.setTickLabels = function(obj) {
      var ticks = obj.ticks, mode, locations, labels = [],
      start = 0, nticks, dim, i, limits, range, values = [], max;
      for (dim = 0; dim < 3; dim++) {
        mode = obj.axes.mode[dim];
        nticks = obj.axes.nticks[dim]; // used on input only for custom!
        if (mode === "custom") 
          labels = labels.concat(obj.texts.slice(start, start + nticks));
        else {
          limits = obj.bbox.slice(2*dim, 2*(dim+1));
          range = limits[1] - limits[0];
          locations = ticks.locations[dim];
          max = -Infinity
          for (i = 0; i < locations.length; i++) {
            values.push(limits[0] + range*locations[i]);
            max = Math.max(max, Math.abs(values[i]));
          }
          for (i = 0; i < locations.length; i++) {
            if (Math.abs(values[i])/max < Math.pow(10, -5))
              values[i] = 0;
            labels.push(this.signif(values[i], 5).toString());
          }
          obj.axes.nticks[dim] = locations.length;  
        }
        start += nticks;
      }
      obj.labels.texts = labels;
    };
