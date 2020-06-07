
    /**
     * Start drawing
     * @returns { boolean } Previous state
     */
    rglwidgetClass.prototype.startDrawing = function() {
    	var value = this.drawing;
    	this.drawing = true;
    	return value;
    };

    /**
     * Stop drawing and check for context loss
     * @param { boolean } saved - Previous state
     */
    rglwidgetClass.prototype.stopDrawing = function(saved) {
      this.drawing = saved;
      if (!saved && this.gl && this.gl.isContextLost())
        this.restartCanvas();
    };

    /**
     * Update the triangles used to display a plane
     * @param { number } id - id of the plane
     * @param { Object } bbox - bounding box in which to display the plane
     */
    rglwidgetClass.prototype.planeUpdateTriangles = function(obj, bbox) {
      var perms = [[0,0,1], [1,2,2], [2,1,0]],
          x, xrow, elem, A, d, nhits, i, j, k, u, v, w, intersect, which, v0, v2, vx, reverse,
          face1 = [], face2 = [], normals = [],
          nPlanes = obj.normals.length;
      obj.bbox = bbox;
      obj.vertices = [];
      obj.initialized = false;
      for (elem = 0; elem < nPlanes; elem++) {
//    Vertex Av = normal.getRecycled(elem);
        x = [];
        A = obj.normals[elem];
        d = obj.offsets[elem][0];
        nhits = 0;
        for (i=0; i<3; i++)
          for (j=0; j<2; j++)
            for (k=0; k<2; k++) {
              u = perms[0][i];
              v = perms[1][i];
              w = perms[2][i];
              if (A[w] !== 0.0) {
                intersect = -(d + A[u]*bbox[j+2*u] + A[v]*bbox[k+2*v])/A[w];
                if (bbox[2*w] < intersect && intersect < bbox[1+2*w]) {
                  xrow = [];
                  xrow[u] = bbox[j+2*u];
                  xrow[v] = bbox[k+2*v];
                  xrow[w] = intersect;
                  x.push(xrow);
                  face1[nhits] = j + 2*u;
                  face2[nhits] = k + 2*v;
                  nhits++;
                }
              }
            }

            if (nhits > 3) {
            /* Re-order the intersections so the triangles work */
              for (i=0; i<nhits-2; i++) {
                which = 0; /* initialize to suppress warning */
                for (j=i+1; j<nhits; j++) {
                  if (face1[i] == face1[j] || face1[i] == face2[j] ||
                      face2[i] == face1[j] || face2[i] == face2[j] ) {
                    which = j;
                    break;
                  }
                }
                if (which > i+1) {
                  this.swap(x, i+1, which);
                  this.swap(face1, i+1, which);
                  this.swap(face2, i+1, which);
                }
              }
            }
            if (nhits >= 3) {
      /* Put in order so that the normal points out the FRONT of the faces */
              v0 = [x[0][0] - x[1][0] , x[0][1] - x[1][1], x[0][2] - x[1][2]];
              v2 = [x[2][0] - x[1][0] , x[2][1] - x[1][1], x[2][2] - x[1][2]];
              /* cross-product */
              vx = this.xprod(v0, v2);
              reverse = this.dotprod(vx, A) > 0;

              for (i=0; i<nhits-2; i++) {
                obj.vertices.push(x[0]);
                normals.push(A);
                for (j=1; j<3; j++) {
                  obj.vertices.push(x[i + (reverse ? 3-j : j)]);
                  normals.push(A);
                }
              }
            }
      }
      obj.pnormals = normals;
    };
    
    rglwidgetClass.prototype.mode4type = {points : "POINTS",
                     linestrip : "LINE_STRIP",
                     abclines : "LINES",
                     lines : "LINES",
                     sprites : "TRIANGLES",
                     planes : "TRIANGLES",
                     text : "TRIANGLES",
                     quads : "TRIANGLES",
                     surface : "TRIANGLES",
                     triangles : "TRIANGLES"};

    /**
     * Sort objects from back to front
     * @returns { number[] }
     * @param { Object } obj - object to sort
     */
    rglwidgetClass.prototype.depthSort = function(obj) {
      var n = obj.centers.length,
          depths = new Float32Array(n),
          result = new Array(n),
          compare = function(i,j) { return depths[j] - depths[i]; },
          z, w;
      for(i=0; i<n; i++) {
        z = this.prmvMatrix.m13*obj.centers[i][0] +
            this.prmvMatrix.m23*obj.centers[i][1] +
            this.prmvMatrix.m33*obj.centers[i][2] +
            this.prmvMatrix.m43;
        w = this.prmvMatrix.m14*obj.centers[i][0] +
            this.prmvMatrix.m24*obj.centers[i][1] +
            this.prmvMatrix.m34*obj.centers[i][2] +
            this.prmvMatrix.m44;
        depths[i] = z/w;
        result[i] = i;
      }
      result.sort(compare);
      return result;
    };
    
    rglwidgetClass.prototype.disableArrays = function(obj, enabled) {
      var gl = this.gl || this.initGL(),
          objLocs = ["normLoc", "texLoc", "ofsLoc", "pointLoc", "nextLoc"],
          thisLocs = ["posLoc", "colLoc"], i, attr;
      for (i = 0; i < objLocs.length; i++) 
        if (enabled[objLocs[i]]) gl.disableVertexAttribArray(obj[objLocs[i]]);
      for (i = 0; i < thisLocs.length; i++)
        if (enabled[thisLocs[i]]) gl.disableVertexAttribArray(this[objLocs[i]]);
      if (typeof obj.userAttributes !== "undefined") {
      	for (attr in obj.userAttribSizes) {  // Not all attributes may have been used
      	  gl.disableVertexAttribArray( obj.userAttribLocations[attr] );
      	}
      }
    };
    
    /**
     * Set gl depth test based on object's material
     * @param { object } obj - object to use
     */
    rglwidgetClass.prototype.doDepthTest = function(obj) {
      var gl = this.gl,
          tests = {never: gl.NEVER,
                   less:  gl.LESS,
                   equal: gl.EQUAL,
                   lequal:gl.LEQUAL,
                   greater: gl.GREATER,
                   notequal: gl.NOTEQUAL,
                   gequal: gl.GEQUAL,
                   always: gl.ALWAYS},
           test = tests[this.getObjMaterial(obj, "depth_test")];
      gl.depthFunc(test);
    };    
    
    /**
     * Set polygon offset for an obj
     * @param { object } obj - object to use
     */
    rglwidgetClass.prototype.doPolygonOffset = function(obj) { 
      var gl = this.gl;
      if (typeof obj.polygon_offset !== "undefined") {
        gl.polygonOffset(obj.polygon_offset[0],
                          obj.polygon_offset[1]);
        gl.enable(gl.POLYGON_OFFSET_FILL);
      } else
        gl.disable(gl.POLYGON_OFFSET_FILL);
    };
    
    rglwidgetClass.prototype.doClipping = function(obj, subscene) {
      var gl = this.gl,
          clipcheck = 0,
          clipplaneids = subscene.clipplanes,
          clip, i,j;
      for (i=0; i < clipplaneids.length; i++) {
        clip = this.getObj(clipplaneids[i]);
        for (j=0; j < clip.offsets.length; j++) {
          gl.uniform4fv(obj.clipLoc[clipcheck + j], clip.IMVClip[j]);
        }
        clipcheck += clip.offsets.length;
      }
      if (typeof obj.clipLoc !== "undefined")
        for (i=clipcheck; i < obj.clipLoc.length; i++)
          gl.uniform4f(obj.clipLoc[i], 0,0,0,0);
    };
    
    rglwidgetClass.prototype.doLighting = function(obj, subscene) {
      var gl = this.gl, i, light;
        gl.uniformMatrix4fv( obj.normMatLoc, false, new Float32Array(this.normMatrix.getAsArray()) );
        gl.uniform3fv( obj.emissionLoc, obj.emission);
        gl.uniform1f( obj.shininessLoc, obj.shininess);
        for (i=0; i < subscene.lights.length; i++) {
          light = this.getObj(subscene.lights[i]);
          if (!light.initialized) this.initObj(light);
          gl.uniform3fv( obj.ambientLoc[i], this.componentProduct(light.ambient, obj.ambient));
          gl.uniform3fv( obj.specularLoc[i], this.componentProduct(light.specular, obj.specular));
          gl.uniform3fv( obj.diffuseLoc[i], light.diffuse);
          gl.uniform3fv( obj.lightDirLoc[i], light.lightDir);
          gl.uniform1i( obj.viewpointLoc[i], light.viewpoint);
          gl.uniform1i( obj.finiteLoc[i], light.finite);
        }
        for (i=subscene.lights.length; i < obj.nlights; i++) {
          gl.uniform3f( obj.ambientLoc[i], 0,0,0);
          gl.uniform3f( obj.specularLoc[i], 0,0,0);
          gl.uniform3f( obj.diffuseLoc[i], 0,0,0);
        }
    };
    
    rglwidgetClass.prototype.doColors = function(obj) {
      var gl = this.gl;
      if (obj.colorCount === 1) {
        gl.disableVertexAttribArray( this.colLoc );
        gl.vertexAttrib4fv( this.colLoc, new Float32Array(obj.onecolor));
        return false;
      } else {
        gl.enableVertexAttribArray( this.colLoc );
        gl.vertexAttribPointer(this.colLoc, 4, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.cofs);
        return true;
      }
    };
    
    rglwidgetClass.prototype.doNormals = function(obj) {
      var gl = this.gl;
      if (obj.vOffsets.nofs > 0) {
        gl.enableVertexAttribArray( obj.normLoc );
        gl.vertexAttribPointer(obj.normLoc, 3, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.nofs);
        return true;
      } else
        return false;
    };
    
    rglwidgetClass.prototype.doTexture = function(obj) {
      var gl = this.gl, 
          is_spheres = obj.type === "spheres";
        gl.enableVertexAttribArray( obj.texLoc );
        if (is_spheres)
          gl.vertexAttribPointer(obj.texLoc, 2, gl.FLOAT, false, 4*this.sphere.vOffsets.stride, 4*this.sphere.vOffsets.tofs);
        else
          gl.vertexAttribPointer(obj.texLoc, 2, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.tofs);
        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, obj.texture);
        gl.uniform1i( obj.sampler, 0);
        return true;
    };
    
    rglwidgetClass.prototype.doUserAttributes = function(obj) {
      if (typeof obj.userAttributes !== "undefined") {
        var gl = this.gl;
      	for (var attr in obj.userAttribSizes) {  // Not all attributes may have been used
      	  gl.enableVertexAttribArray( obj.userAttribLocations[attr] );
      	  gl.vertexAttribPointer( obj.userAttribLocations[attr], obj.userAttribSizes[attr],
      	  			  gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.userAttribOffsets[attr]);
      	}
      }
    };
    
    rglwidgetClass.prototype.doUserUniforms = function(obj) {
      if (typeof obj.userUniforms !== "undefined") {
        var gl = this.gl;
      	for (var attr in obj.userUniformLocations) {
      	  var loc = obj.userUniformLocations[attr];
      	  if (loc !== null) {
      	    var uniform = obj.userUniforms[attr];
      	    if (typeof uniform.length === "undefined")
      	      gl.uniform1f(loc, uniform);
      	    else if (typeof uniform[0].length === "undefined") {
      	      uniform = new Float32Array(uniform);
      	      switch(uniform.length) {
      	      	case 2: gl.uniform2fv(loc, uniform); break;
      	      	case 3: gl.uniform3fv(loc, uniform); break;
      	      	case 4: gl.uniform4fv(loc, uniform); break;
      	      	default: console.warn("bad uniform length");
      	      }
      	    } else if (uniform.length == 4 && uniform[0].length == 4)
      	      gl.uniformMatrix4fv(loc, false, new Float32Array(uniform.getAsArray()));
      	    else
      	      console.warn("unsupported uniform matrix");
      	  }
      	}
      }
    };
    
    rglwidgetClass.prototype.doLoadIndices = function(obj, pass, indices) {
      var gl = this.gl,
          f = obj.f[pass],
          type = obj.type,
          fnew, step;
      switch(type){
        case "points":
          step = 1;
          break;
        case "lines":
          step = 2;
          break;
        case "planes":
        case "triangles":
          step = 3;
          break;
        case "text":
        case "sprites":
        case "quads":
          step = 6;
          break;
        default:
          return 0;
      }
      if (obj.index_uint)
        fnew = new Uint32Array(step * indices.length);
      else
        fnew = new Uint16Array(step * indices.length);
      for (var i = 0; i < indices.length; i++) {
        for (var j = 0; j < step; j++) {
          fnew[step*i + j] = f[step*indices[i] + j];
        }
      }
      gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, fnew, gl.DYNAMIC_DRAW);
      return fnew.length;
    };
    
    rglwidgetClass.prototype.drawSimple = function(obj, subscene, piece) {
      var 
          flags = obj.flags,
          type = obj.type,
          is_lit = flags & this.f_is_lit,
          has_texture = flags & this.f_has_texture,
          is_transparent = flags & this.f_is_transparent,
          depth_sort = flags & this.f_depth_sort,
          fixed_size = flags & this.f_fixed_size,
          fixed_quads = flags & this.f_fixed_quads,
          is_lines = flags & this.f_is_lines,
          fat_lines = flags & this.f_fat_lines,
          is_twosided = (flags & this.f_is_twosided) > 0,
          gl = this.gl || this.initGL(),
          count,
          pass, mode, pmode,
          enabled = {};

      if (!obj.initialized)
        this.initObj(obj.id);

      if (!obj.vertexCount)
        return;
    
      if (!is_transparent && obj.someHidden) {
        is_transparent = true;
        depth_sort = ["triangles", "quads", "surface",
                      "spheres", "sprites", "text"].indexOf(type) >= 0;
      }        

      this.doDepthTest(obj);
            
      gl.useProgram(obj.prog);

      this.doPolygonOffset(obj);

      gl.bindBuffer(gl.ARRAY_BUFFER, obj.buf);

      gl.uniformMatrix4fv( obj.prMatLoc, false, new Float32Array(this.prMatrix.getAsArray()) );
      gl.uniformMatrix4fv( obj.mvMatLoc, false, new Float32Array(this.mvMatrix.getAsArray()) );

      this.doClipping(obj, subscene);

      if (is_lit)
        this.doLighting(obj, subscene);

      gl.enableVertexAttribArray( this.posLoc );
      enabled.posLoc = true;

      count = obj.vertexCount;
      
      enabled.colLoc = this.doColors(obj);
      if (is_lit)
        enabled.normLoc = this.doNormals(obj);

      if (fixed_size) {
        gl.uniform2f( obj.textScaleLoc, 0.75/this.vp.width, 0.75/this.vp.height);
      }

      if (has_texture || obj.type === "text")
        enabled.texLoc = this.doTexture(obj);

      if (fixed_quads) {
        gl.enableVertexAttribArray( obj.ofsLoc );
        enabled.ofsLoc = true;
        gl.vertexAttribPointer(obj.ofsLoc, 2, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.oofs);
      }
      
      this.doUserAttributes(obj);

      this.doUserUniforms(obj);
      
      for (pass = 0; pass < obj.passes; pass++) {
      	pmode = obj.pmode[pass];
        if (pmode === "culled")
          continue;

      	mode = fat_lines && (is_lines || pmode == "lines") ? "TRIANGLES" : this.mode4type[type];

      	if (is_twosided)
      	  gl.uniform1i(obj.frontLoc, pass !== 0);

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, obj.ibuf[pass]);
        if (typeof piece !== "undefined")
          count = this.doLoadIndices(obj, pass, piece.indices);
        else
          count = obj.f[pass].length;
      	if (!is_lines && pmode === "lines" && !fat_lines) {
          mode = "LINES";
        } else if (pmode === "points") {
          mode = "POINTS";
        }
                          
        if ((is_lines || pmode === "lines") && fat_lines) {
          gl.enableVertexAttribArray(obj.pointLoc);
          enabled.pointLoc = true;
          gl.vertexAttribPointer(obj.pointLoc, 2, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.pointofs);
          gl.enableVertexAttribArray(obj.nextLoc );
          enabled.nextLoc = true;
          gl.vertexAttribPointer(obj.nextLoc, 3, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.nextofs);
          gl.uniform1f(obj.aspectLoc, this.vp.width/this.vp.height);
          gl.uniform1f(obj.lwdLoc, this.getMaterial(id, "lwd")/this.vp.height);
        }

        gl.vertexAttribPointer(this.posLoc,  3, gl.FLOAT, false, 4*obj.vOffsets.stride,  4*obj.vOffsets.vofs);

        gl.drawElements(gl[mode], count, obj.index_uint ? gl.UNSIGNED_INT : gl.UNSIGNED_SHORT, 0);
        this.disableArrays(obj, enabled);
      }
    };
   
    rglwidgetClass.prototype.drawPlanes = function(obj, subscene) {
      if (obj.bbox !== subscene.par3d.bbox || !obj.initialized) {
          this.planeUpdateTriangles(obj, subscene.par3d.bbox);
      }
      this.drawSimple(obj, subscene, piece);
   };

    /**
     * Draw spheres in a subscene
     * @param { object } obj - object to draw
     * @param { object } subscene 
     * @param { object } piece 
     */
    rglwidgetClass.prototype.drawSpheres = function(obj, subscene, piece) {
      var flags = obj.flags,
          type = obj.type,
          is_lit = flags & this.f_is_lit,
          has_texture = flags & this.f_has_texture,
          is_transparent = flags & this.f_is_transparent,
          depth_sort = flags & this.f_depth_sort,
          gl = this.gl || this.initGL(),
          sphereMV, baseofs, ofs, sscale, i, j, k, count,
          enabled = {};

      if (!obj.initialized)
        this.initObj(obj.id);

      if (!obj.vertexCount)
        return;
    
      if (!is_transparent && obj.someHidden) {
        is_transparent = true;
        depth_sort = ["triangles", "quads", "surface",
                      "spheres", "sprites", "text"].indexOf(type) >= 0;
      }        

      this.doDepthTest(obj);
      
      gl.useProgram(obj.prog);

      this.doPolygonOffset(obj);

      gl.bindBuffer(gl.ARRAY_BUFFER, this.sphere.buf);
      
      gl.uniformMatrix4fv( obj.prMatLoc, false, new Float32Array(this.prMatrix.getAsArray()) );
      gl.uniformMatrix4fv( obj.mvMatLoc, false, new Float32Array(this.mvMatrix.getAsArray()) );

      this.doClipping(obj, subscene);

      if (is_lit) 
        this.doLighting(obj, subscene);

      gl.enableVertexAttribArray( this.posLoc );
      enabled.posLoc = true;

      var nc = obj.colorCount;
      count = obj.vertexCount;

        var scale = subscene.par3d.scale,
            scount = count, indices;
        gl.vertexAttribPointer(this.posLoc,  3, gl.FLOAT, false, 4*this.sphere.vOffsets.stride,  0);
        gl.enableVertexAttribArray(obj.normLoc );
        enabled.normLoc = true;
        gl.vertexAttribPointer(obj.normLoc,  3, gl.FLOAT, false, 4*this.sphere.vOffsets.stride,  0);
        gl.disableVertexAttribArray( this.colLoc );
        var sphereNorm = new CanvasMatrix4();
        sphereNorm.scale(scale[0], scale[1], scale[2]);
        sphereNorm.multRight(this.normMatrix);
        gl.uniformMatrix4fv( obj.normMatLoc, false, new Float32Array(sphereNorm.getAsArray()) );

        if (nc == 1) {
          gl.vertexAttrib4fv( this.colLoc, new Float32Array(obj.onecolor));
        }

        if (has_texture)
          enabled.texLoc = this.doTexture(obj);

        if (depth_sort) {
          if (typeof piece === "undefined")
            console.error("piece not defined");
          scount = 1;
        }

        for (i = 0; i < scount; i++) {
          sphereMV = new CanvasMatrix4();

          if (depth_sort) {
            baseofs = piece.subid*obj.vOffsets.stride;
          } else {
            baseofs = i*obj.vOffsets.stride;
          }

          ofs = baseofs + obj.vOffsets.radofs;
          sscale = obj.values[ofs];

          sphereMV.scale(sscale/scale[0], sscale/scale[1], sscale/scale[2]);
          sphereMV.translate(obj.values[baseofs],
                             obj.values[baseofs+1],
                             obj.values[baseofs+2]);
          sphereMV.multRight(this.mvMatrix);
          gl.uniformMatrix4fv( obj.mvMatLoc, false, new Float32Array(sphereMV.getAsArray()) );

          if (nc > 1) {
            ofs = baseofs + obj.vOffsets.cofs;
            gl.vertexAttrib4f( this.colLoc, obj.values[ofs],
                                        obj.values[ofs+1],
                                       obj.values[ofs+2],
                                       obj.values[ofs+3] );
          }
          gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.sphere.ibuf);
          if (depth_sort) {
            indices = piece.indices;
            f = new Uint16Array(3*indices.length);
            for (j=0; j < indices.length; j++) 
              for (k=0; k < 3; k++)
                f[3*j + k] = this.sphere.it[3*indices[j] + k];
            gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, f, gl.DYNAMIC_DRAW);
            gl.drawElements(gl.TRIANGLES, 3*indices.length, gl.UNSIGNED_SHORT, 0);
          } else {
            gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.sphere.it, gl.DYNAMIC_DRAW);
            gl.drawElements(gl.TRIANGLES, this.sphere.sphereCount, gl.UNSIGNED_SHORT, 0);
          }
        }
        
        this.disableArrays(obj, enabled);
   };
   
    /**
     * Prepare clipplanes for drawing
     * @param { object } obj - clip planes object
     * @param { object } subscene
     */
    rglwidgetClass.prototype.drawClipplanes = function(obj) {
      var count = obj.offsets.length,
        IMVClip = [];
      for (var i=0; i < count; i++) {
        IMVClip[i] = this.multMV(this.invMatrix, obj.vClipplane.slice(4*i, 4*(i+1)));
      }
      obj.IMVClip = IMVClip;      
    }
   
    /**
     * Draw a sprites object in a subscene
     * @param { object } obj - object to draw
     * @param { object } subscene
     * @param { object } piece
     */
    rglwidgetClass.prototype.drawSprites = function(obj, subscene, piece) {
      var flags = obj.flags,
          is_transparent = flags & this.f_is_transparent,
          sprites3d = flags & this.f_sprites_3d,
          i,j,
          origMV = new CanvasMatrix4( this.mvMatrix ),
          origPRMV = null,
          pos, radius, userMatrix;

      if (!sprites3d) {
        this.drawSimple(obj, subscene, piece);
        return;
      }
      
      if (!obj.initialized)
        this.initObj(obj.id);

      if (!obj.vertexCount)
        return;
    
      is_transparent |= obj.someHidden;
      
      var norigs = obj.vertices.length,
          savenorm = new CanvasMatrix4(this.normMatrix);

      this.normMatrix = subscene.spriteNormmat;
      userMatrix = (typeof obj.userMatrix === "undefined") ? 
                   new CanvasMatrix4() : obj.userMatrix;
                   
      if (typeof piece !== "undefined")
          norigs = 1;
          
      if (this.prmvMatrix !== null)
         origPRMV = new CanvasMatrix4( this.prmvMatrix );

      for (iOrig=0; iOrig < norigs; iOrig++) {
        if (typeof piece !== "undefined")
          j = piece.subid;
        else
          j = iOrig;
        pos = this.multVM([].concat(obj.vertices[j]).concat(1.0),
                          origMV);
        radius = obj.radii.length > 1 ? obj.radii[j][0] : obj.radii[0][0];
        this.mvMatrix = new CanvasMatrix4(userMatrix);
        this.mvMatrix.scale(radius);
        this.mvMatrix.translate(pos[0]/pos[3], pos[1]/pos[3], pos[2]/pos[3]);
        this.setprmvMatrix();
        if (sprites3d)
          for (i=0; i < obj.objects.length; i++)
            this.drawObjId(obj.objects[i], subscene.id);
      }
      this.normMatrix = savenorm;
      this.mvMatrix = origMV;
      if (origPRMV !== null)
        this.prmvMatrix = origPRMV;
    };
   
    rglwidgetClass.prototype.drawObjId = function(id, subsceneid, piece) {
      if (typeof id !== "number")
        this.alertOnce("drawObjId id is "+typeof id);

     this.drawObj(this.getObj(id), this.getObj(subsceneid), piece);
   }
   
    /**
     * Draw an object in a subscene
     * @param { number } id - object to draw
     * @param { number } subsceneid - id of subscene
     */
    rglwidgetClass.prototype.drawObj = function(obj, subscene, piece) {
      var 
          flags = obj.flags,
          type = obj.type,
          is_lit = flags & this.f_is_lit,
          has_texture = flags & this.f_has_texture,
          is_transparent = flags & this.f_is_transparent,
          depth_sort = flags & this.f_depth_sort,
          is_lines = flags & this.f_is_lines,
          fat_lines = flags & this.f_fat_lines,
          fixed_size = flags & this.f_fixed_size,
          fixed_quads = flags & this.f_fixed_quads,
          is_twosided = (flags & this.f_is_twosided) > 0,
          gl = this.gl || this.initGL(),
          i, j, count,
          pass, mode, pmode,
          enabled = {};

      switch(type) {
        case "surface":
        case "triangles":
        case "quads":
        case "lines":
        case "linestrip":
        case "points":
        case "text":
          this.drawSimple(obj, subscene, piece);
          return;
        case "planes":
          this.drawPlanes(obj, subscene);
          return;
        case "spheres":
          this.drawSpheres(obj, subscene, piece);
          return;
        case "clipplanes":
          this.drawClipplanes(obj);
          return;
        case "sprites":
          this.drawSprites(obj, subscene, piece);
          return;
        case "light":
        case "bboxdeco":
          return;
      }
      
      console.log("drawObj for type = "+type);

      if (!obj.initialized)
        this.initObj(obj.id);

      if (!obj.vertexCount)
        return;
    
      if (!is_transparent &&
    	  obj.someHidden) {
        is_transparent = true;
        depth_sort = ["triangles", "quads", "surface",
                      "sprites", "text"].indexOf(type) >= 0;
      }        

      this.doDepthTest(obj);
      
      gl.useProgram(obj.prog);

      this.doPolygonOffset(obj);

      gl.bindBuffer(gl.ARRAY_BUFFER, obj.buf);

      gl.uniformMatrix4fv( obj.prMatLoc, false, new Float32Array(this.prMatrix.getAsArray()) );
      gl.uniformMatrix4fv( obj.mvMatLoc, false, new Float32Array(this.mvMatrix.getAsArray()) );

      this.doClipping(obj, subscene);

      if (is_lit) 
        this.doLighting(obj, subscene);

      if (fixed_size) {
        gl.uniform2f( obj.textScaleLoc, 0.75/this.vp.width, 0.75/this.vp.height);
      }

      gl.enableVertexAttribArray( this.posLoc );
      enabled.posLoc = true;

      count = obj.vertexCount;

        enabled.colLoc = this.doColors(obj);

      if (is_lit)
        enabled.normLoc = this.doNormals(obj);

      if (has_texture || type === "text") {
        enabled.texLoc = this.doTexture(obj);
      }

      if (fixed_quads) {
        gl.enableVertexAttribArray( obj.ofsLoc );
        enabled.ofsLoc = true;
        gl.vertexAttribPointer(obj.ofsLoc, 2, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.oofs);
      }
      
      this.doUserAttributes(obj);

      this.doUserUniforms(obj);

      for (pass = 0; pass < obj.passes; pass++) {
      	pmode = obj.pmode[pass];
        if (pmode === "culled")
          continue;

      	mode = fat_lines && (is_lines || pmode == "lines") ? "TRIANGLES" : this.mode4type[type];
        if (depth_sort && pmode == "filled") {// Don't try depthsorting on wireframe or points
          var faces = this.depthSort(obj),
              nfaces = faces.length,
              frowsize = Math.floor(obj.f[pass].length/nfaces);

            f = obj.index_uint ? new Uint32Array(obj.f[pass].length) : new Uint16Array(obj.f[pass].length);
            for (i=0; i<nfaces; i++) {
              for (j=0; j<frowsize; j++) {
                f[frowsize*i + j] = obj.f[pass][frowsize*faces[i] + j];
              }
            }
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, obj.ibuf[pass]);
            gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, f, gl.DYNAMIC_DRAW);
        }

      	if (is_twosided)
      	  gl.uniform1i(obj.frontLoc, pass !== 0);

          gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, obj.ibuf[pass]);

        if (type === "sprites" || type === "text" || type === "quads") {
          count = count * 6/4;
        } else if (type === "surface") {
          count = obj.f[pass].length;
        }

        count = obj.f[pass].length;
      	if (!is_lines && pmode === "lines" && !fat_lines) {
          mode = "LINES";
        } else if (pmode === "points") {
          mode = "POINTS";
        }
                          
        if ((is_lines || pmode === "lines") && fat_lines) {
          gl.enableVertexAttribArray(obj.pointLoc);
          enabled.pointLoc = true;
          gl.vertexAttribPointer(obj.pointLoc, 2, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.pointofs);
          gl.enableVertexAttribArray(obj.nextLoc );
          enabled.nextLoc = true;
          gl.vertexAttribPointer(obj.nextLoc, 3, gl.FLOAT, false, 4*obj.vOffsets.stride, 4*obj.vOffsets.nextofs);
          gl.uniform1f(obj.aspectLoc, this.vp.width/this.vp.height);
          gl.uniform1f(obj.lwdLoc, this.getMaterial(id, "lwd")/this.vp.height);
        }

        gl.vertexAttribPointer(this.posLoc,  3, gl.FLOAT, false, 4*obj.vOffsets.stride,  4*obj.vOffsets.vofs);

        gl.drawElements(gl[mode], count, obj.index_uint ? gl.UNSIGNED_INT : gl.UNSIGNED_SHORT, 0);
        this.disableArrays(obj, enabled);
     }
     
   };

    /**
     * Draw the background for a subscene
     * @param { number } id - id of background object
     * @param { number } subsceneid - id of subscene
     */
    rglwidgetClass.prototype.drawBackground = function(id, subsceneid) {
      var gl = this.gl || this.initGL(),
          obj = this.getObj(id),
          bg, i;

      if (!obj.initialized)
        this.initObj(id);

      if (obj.colors.length) {
        bg = obj.colors[0];
        gl.clearColor(bg[0], bg[1], bg[2], bg[3]);
        gl.depthMask(true);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
      }
      if (typeof obj.quad !== "undefined") {
        this.prMatrix.makeIdentity();
        this.mvMatrix.makeIdentity();
        gl.disable(gl.BLEND);
        gl.disable(gl.DEPTH_TEST);
        gl.depthMask(false);
        for (i=0; i < obj.quad.length; i++)
          this.drawObjId(obj.quad[i], subsceneid);
      }
    };

    /**
     * Draw a subscene
     * @param { number } subsceneid - id of subscene
     * @param { boolean } opaquePass - is this the opaque drawing pass?
     */
    rglwidgetClass.prototype.drawSubscene = function(subsceneid, opaquePass) {
      var gl = this.gl || this.initGL(),
          sub = this.getObj(subsceneid),
          objects = this.scene.objects,
          subids = sub.objects,
          subscene_has_faces = false,
          subscene_needs_sorting = false,
          flags, i, obj;
      if (sub.par3d.skipRedraw)
        return;
      
      this.opaquePass = opaquePass;
      
      for (i=0; i < subids.length; i++) {
      	obj = objects[subids[i]];
        flags = obj.flags;
        if (typeof flags !== "undefined") {
          subscene_has_faces |= (flags & this.f_is_lit)
                           & !(flags & this.f_fixed_quads);
          obj.is_transparent = (flags & this.f_is_transparent) || obj.someHidden;
          subscene_needs_sorting |= (flags & this.f_depth_sort) || obj.is_transparent;
        }
      }

      this.setViewport(subsceneid);

      if (typeof sub.backgroundId !== "undefined" && opaquePass)
          this.drawBackground(sub.backgroundId, subsceneid);

      if (subids.length) {
        this.setprMatrix(subsceneid);
        this.setmvMatrix(subsceneid);

        if (subscene_has_faces) {
          this.setnormMatrix(subsceneid);
          if ((sub.flags & this.f_sprites_3d) &&
              typeof sub.spriteNormmat === "undefined") {
            sub.spriteNormmat = new CanvasMatrix4(this.normMatrix);
          }
        }

        if (subscene_needs_sorting)
          this.setprmvMatrix();

        var clipids = sub.clipplanes;
        if (typeof clipids === "undefined") {
          console.warn("bad clipids");
        }
        if (clipids.length > 0) {
          this.invMatrix = new CanvasMatrix4(this.mvMatrix);
          this.invMatrix.invert();
          for (i = 0; i < clipids.length; i++)
            this.drawObjId(clipids[i], subsceneid);
        }

        subids = sub.opaque.concat(sub.transparent);
        if (opaquePass) {
          gl.enable(gl.DEPTH_TEST);
          gl.depthMask(true);
          gl.disable(gl.BLEND);
          for (i = 0; i < subids.length; i++) {
            if (!this.getObj(subids[i]).is_transparent)	
              this.drawObjId(subids[i], subsceneid);
          }
        } else {
          this.subsceneid = subsceneid;
          gl.depthMask(false);
          gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA,
                               gl.ONE, gl.ONE);
          gl.enable(gl.BLEND);
//          for (i = 0; i < subids.length; i++) {
//            if (this.getObj(subids[i]).is_transparent)
//              this.drawObjId(subids[i], subsceneid);
//          }
        }
        if (opaquePass) {
          subids = sub.subscenes;
          for (i = 0; i < subids.length; i++) {
            this.drawSubscene(subids[i], opaquePass);
          }
        }
      }
    };
    
    /**
     * Set the context for drawing transparently
     */
    rglwidgetClass.prototype.setContext = function(context) {
      var result = [], objid, obj, type;
      context = context.slice();
      context.reverse();
      while (context.length > 0) {
        objid = context.pop();
        obj = this.getObj(objid);
        type = obj.type;
        switch (type) {
          case "subscene":
            this.drawSubscene(objid, false);
            break;
          case "sprites":
            result = result.concat(context.pop());
            break;
          default:
            console.error("bad type in setContext");
        }
      }
      return result;
    };
    
    /**
     * Draw the transparent pieces of a scene
     */
    rglwidgetClass.prototype.drawPieces = function(pieces) {
      var i, prevcontext = [], context;
      for (i = 0; i < pieces.length; i++) {
        context = pieces[i].context.slice();
        if (context !== prevcontext) {
          prevcontext = context.slice();
          context = this.setContext(context);
        }
        this.drawObjId(pieces[i].objid, this.subsceneid, 
                     piece = pieces[i]);
      }
    };
 
    /**
     * Draw the whole scene
     */
    rglwidgetClass.prototype.drawScene = function() {
      var gl = this.gl || this.initGL(),
          wasDrawing = this.startDrawing();
      if (!wasDrawing) {
        if (this.select.state !== "inactive")
          this.selectionChanged();
        gl.enable(gl.DEPTH_TEST);
        gl.depthFunc(gl.LEQUAL);
        gl.clearDepth(1.0);
        gl.clearColor(1,1,1,1);
        gl.depthMask(true); // Must be true before clearing depth buffer
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        this.drawSubscene(this.scene.rootSubscene, true);
        var pieces = this.getSubscenePieces([], this.scene.rootSubscene);
        pieces = this.sortPieces(pieces);
        this.drawPieces(pieces);
        // this.drawSubscene(this.scene.rootSubscene, false);
      }
      this.stopDrawing(wasDrawing);
    };
