// These functions order the centers of displayed objects so they
// can be drawn using the painters algorithm, necessary to support
// transparency

    rglwidgetClass.prototype.getPieces = function(incontext, objid, subid, obj) {
      var n = obj.centers.length,
          depth,
          result = new Array(n),
          context = incontext.slice();
          
      for(i=0; i<n; i++) {
        z = this.prmvMatrix.m13*obj.centers[i][0] +
            this.prmvMatrix.m23*obj.centers[i][1] +
            this.prmvMatrix.m33*obj.centers[i][2] +
            this.prmvMatrix.m43;
        w = this.prmvMatrix.m14*obj.centers[i][0] +
            this.prmvMatrix.m24*obj.centers[i][1] +
            this.prmvMatrix.m34*obj.centers[i][2] +
            this.prmvMatrix.m44;
        depth = z/w;
        result[i] = {context: context, 
                     objid: objid,
                     subid: subid,
                     index: i, 
                     depth: depth};
      }
      return result;    
    };
    
    rglwidgetClass.prototype.getSpritesPieces = function(context, subsceneid, obj, iOrig) {
      var origMV = new CanvasMatrix4( this.mvMatrix ),
          origPRMV = new CanvasMatrix4( this.prmvMatrix ),
          pos = this.multVM([].concat(obj.vertices[iOrig]).concat(1.0),
                                 origMV),
          radius = obj.radii.length > 1 ? obj.radii[iOrig][0] : obj.radii[0][0],
          j, result = [];
      context = context.slice();
      context = context.concat(iOrig);
      this.mvMatrix = new CanvasMatrix4(obj.userMatrix).scale(radius).translate(pos[0]/pos[3], pos[1]/pos[3], pos[2]/pos[3]);
      this.setprmvMatrix();
      for (j = 0; j < obj.objects.length; j++)
        result = result.concat(getObjPieces(context, subsceneid, obj.objects[j]));
      this.mvMatrix = origMV;
      this.prmvMatrix = origPRMV;
      return result;
    };
    
    rglwidgetClass.prototype.getSpherePieces = function(context, subsceneid, obj, i) {
      var origMV = new CanvasMatrix4( this.mvMatrix ),
          origPRMV = new CanvasMatrix4( this.prmvMatrix ),
          pos = obj.vertices[i],
          sscale = obj.radii.length > 1 ? obj.radii[i][0] : obj.radii[0][0],
          subscene = this.getObj(subsceneid),
          scale = subscene.par3d.scale,
          result;
          
      this.mvMatrix = new CanvasMatrix4();
      this.mvMatrix.scale(sscale/scale[0], sscale/scale[1], sscale/scale[2]);
      this.mvMatrix.translate(pos[0], pos[1], pos[2]);
      this.mvMatrix.multRight(origMV);
      this.setprmvMatrix();
      result = this.getPieces(context, obj.id, i, this.sphere);
      this.mvMatrix = origMV;
      this.prmvMatrix = origPRMV;
      return result;
    };
    
    rglwidgetClass.prototype.getObjPieces = function(context, subsceneid, objid) {
      var obj = this.getObj(objid),
          subscene = this.getObj(subsceneid),
          flags = obj.flags,
          type = obj.type,
          is_transparent = flags & this.f_is_transparent,
          sprites_3d = flags & this.f_sprites_3d,
          i, count, 
          result = [];
        
      if (type === "planes") {
        if (obj.bbox !== subscene.par3d.bbox || !obj.initialized) {
          this.planeUpdateTriangles(obj, subscene.par3d.bbox);
        }
      }

      if (!obj.initialized)
        this.initObj(obj.id);

      if (type === "light" || type === "bboxdeco" || !obj.vertexCount)
        return result;
    
      if (!is_transparent && obj.someHidden)
        is_transparent = true;
      
      if (sprites_3d) {
        var norigs = obj.vertices.length;
        this.origs = obj.vertices;
        this.usermat = new Float32Array(obj.userMatrix.getAsArray());
        context.push(objid);
        for (this.iOrig=0; this.iOrig < norigs; this.iOrig++) {
          for (i=0; i < obj.objects.length; i++) {
            result = result.concat(this.getSpritesPieces(context, subsceneid, obj, iOrig, i));
          }
        }
        return result;
      }

      if (type === "spheres" && is_transparent) {
        count = obj.vertexCount;
        for (i = 0; i < count; i++) {
          result = result.concat(this.getSpherePieces(context, subsceneid, obj, i));
        }
        return result;
      }

      if (is_transparent)
        result = this.getPieces(context, objid, 0, obj);
        
      return result;
    };
    
    rglwidgetClass.prototype.getSubscenePieces = function(context, subsceneid) {
      var sub = this.getObj(subsceneid),
          objects = this.scene.objects,
          subids = sub.objects,
          subscene_needs_sorting = false,
          flags, i, obj,
          result = [];
      if (sub.par3d.skipRedraw)
        return result;
      for (i=0; i < subids.length; i++) {
      	obj = objects[subids[i]];
        flags = obj.flags;
        if (typeof flags !== "undefined") {
          obj.is_transparent = (flags & this.f_is_transparent) || obj.someHidden;
          subscene_needs_sorting |= (flags & this.f_depth_sort) || obj.is_transparent;
        }
      }
      if (!subscene_needs_sorting)
        return result;

      this.setViewport(subsceneid);

      context.push(subsceneid);
      
      if (subids.length) {
        this.setprMatrix(subsceneid);
        this.setmvMatrix(subsceneid);
        this.setprmvMatrix();

        subids = sub.opaque.concat(sub.transparent);
        for (i = 0; i < subids.length; i++) {
          if (this.getObj(subids[i]).is_transparent)
            result = result.concat(this.getObjPieces(context, subsceneid, subids[i]));
        }
        subids = sub.subscenes;
        for (i = 0; i < subids.length; i++) {
          result = result.concat(this.getSubscenePieces(context, subids[i]));
        }
      }
      return result;
    };
    
    rglwidgetClass.prototype.sortPieces = function(pieces) {
      var compare = function(i,j) {
        var diff = j.depth - i.depth;
        // We want to avoid context or obj changes,
        // so sort on those next.
        if (diff === 0) {
          var c1 = j.context.slice(),
              c2 = i.context.slice();
          diff = c1.length - c2.length; 
          while (diff === 0 && c1.length > 0) {
            diff = c1.pop() - c2.pop();
          }
          if (diff === 0)
            diff = j.objid - i.objid;
          if (diff === 0)
            diff = j.subid - i.subid;
        }
        return diff;
      }, result = [];
      if (pieces.length) {
        pieces = pieces.sort(compare);
        var i,
            thiscontext = pieces[0].context, 
            thisobjid = pieces[0].objid, 
            thissubid = pieces[0].subid,
            indices = [];
        for (i= 0; i < pieces.length; i++) {
          if (pieces[i].context !== thiscontext || 
              pieces[i].objid !== thisobjid ||
              pieces[i].subid !== thissubid) {
            result = result.concat({context: thiscontext, objid: thisobjid,
                                    subid: thissubid, indices: indices});
            thiscontext = pieces[i].context;
            thisobjid = pieces[i].objid;
            thissubid = pieces[i].subid;
            indices = [];
          }
          indices = indices.concat(pieces[i].index);
        }
        result = result.concat({context: thiscontext, objid: thisobjid,
                                subid: thissubid,
                                indices: indices});
      }
      return result;
    };
    
