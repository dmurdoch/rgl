    /**
     * Methods related to shaders
     * @name ___METHODS_FOR_SHADERS___
     * @memberof rglwidgetClass
     * @kind function
     * @instance
     */
    
    /**
     * Generate the defines for the shader code for an object.
     * 
     * This is a static method so it can be called from R.
     * 
     * @returns {string}
     * @param  id - id of object
     * @param  type - type of object
     * @param  flags - object flags
     * @param  nclipplanes - number of clipping planes in scene 
     *         (may not all be active)
     * @param  nlights - number of lights in scene (ditto)
     * @param  normals - normals for object
     * @param  pointSize - point size for object 
     * @param  textype - texture type for object 
     * @param  antialias - use antialiasing?
     */
    rglwidgetClass.getDefines = function(id, type, flags, nclipplanes, nlights, normals, pointSize, textype, antialias) {
      var
          is_lit = rglwidgetClass.isSet(flags, rglwidgetClass.f_is_lit),
          has_texture = rglwidgetClass.isSet(flags, rglwidgetClass.f_has_texture),
          fixed_quads = rglwidgetClass.isSet(flags, rglwidgetClass.f_fixed_quads),
          fixed_size = rglwidgetClass.isSet(flags, rglwidgetClass.f_fixed_size),
          is_points = rglwidgetClass.isSet(flags, rglwidgetClass.f_is_points),
          is_transparent = rglwidgetClass.isSet(flags, rglwidgetClass.f_is_transparent),
          is_twosided = rglwidgetClass.isSet(flags, rglwidgetClass.f_is_twosided),
          fat_lines = rglwidgetClass.isSet(flags, rglwidgetClass.f_fat_lines),
          is_brush = rglwidgetClass.isSet(flags, rglwidgetClass.f_is_brush),
          has_fog = rglwidgetClass.isSet(flags, rglwidgetClass.f_has_fog),
          has_normals = (typeof normals !== "undefined") ||
                        type === "spheres",
          needs_vnormal = (is_lit && !fixed_quads && !is_brush) || (is_twosided && has_normals),
          rotating = rglwidgetClass.isSet(flags, rglwidgetClass.f_rotating),
          title, defines;

      title = "  /* ****** "+type+" object "+id+" vertex shader ****** */\n";
      
      defines = "#define NCLIPPLANES " + nclipplanes + "\n"+
                "#define NLIGHTS " + nlights + "\n";
      
      if (fat_lines)
        defines = defines + "#define FAT_LINES 1\n";
      
      if (fixed_quads)
        defines = defines + "#define FIXED_QUADS 1\n";

      if (fixed_size)
        defines = defines + "#define FIXED_SIZE 1\n";

      if (has_fog)
        defines = defines + "#define HAS_FOG 1\n";
        
      if (has_normals)
        defines = defines + "#define HAS_NORMALS 1\n";
        
      if (has_texture) {
        defines = defines + "#define HAS_TEXTURE 1\n";
        defines = defines + "#define TEXTURE_" + textype + "\n";
      }
      
      if (is_brush)
        defines = defines + "#define IS_BRUSH 1\n";  

      if (type === "linestrip")
        defines = defines + "#define IS_LINESTRIP 1\n";         

      if (is_lit)
        defines = defines + "#define IS_LIT 1\n"; 
      
      if (is_points) {
        defines = defines + "#define IS_POINTS 1\n";
        defines = defines + "#define POINTSIZE " + Number.parseFloat(pointSize).toFixed(1) + "\n";
      }
        
      if (type === "sprites")
        defines = defines + "#define IS_SPRITES 1\n";
        
      if (type === "text")
        defines = defines + "#define IS_TEXT 1\n";

      if (is_transparent)
        defines = defines + "#define IS_TRANSPARENT 1\n"; 
        
      if (is_twosided)
        defines = defines + "#define IS_TWOSIDED 1\n";
        
      if (needs_vnormal)
        defines = defines + "#define NEEDS_VNORMAL 1\n";

      if (rotating)
        defines = defines + "#define ROTATING 1\n";
        
      if (antialias)
        defines = defines + "#define ROUND_POINTS 1\n";   

      // console.log(result);
      return title + defines;
    };

    /**
     * Create code for vertex and fragment shaders
     * @returns {Object}
     * @param { number } shaderType - gl code for shader type
     * @param { string } code - code for the shader
     */
    rglwidgetClass.prototype.getShaders = function(obj) {
      var header, 
        vertex = obj.userVertexShader, 
        fragment = obj.userFragmentShader;
      
      header = rglwidgetClass.getDefines(
        obj.id, obj.type, obj.flags, 
        this.countClipplanes(), this.countLights(), 
        obj.normals, 
        this.getMaterial(obj, "size"), 
        this.getMaterial(obj, "textype"), 
        this.getMaterial(obj, "point_antialias")
      );

      if (typeof vertex === "undefined")
        vertex = document.getElementById("rgl-vertex-shader").text;
        
      if (typeof fragment === "undefined") 
        fragment = document.getElementById("rgl-fragment-shader").text;

//      console.log("vertex:");
//      console.log(header + vertex);
//      console.log("fragment:");
//      console.log(header + fragment);
      
      return {vertex: header + vertex,
              fragment: header + fragment};
    };
    
    
    /**
     * Call gl functions to create and compile shader from code
     * @returns {Object}
     * @param { number } shaderType - gl code for shader type
     * @param { string } code - code for the shader
     */
    rglwidgetClass.prototype.getShader = function(shaderType, code) {
        var gl = this.gl, shader;
        shader = gl.createShader(shaderType);
        gl.shaderSource(shader, code);
        gl.compileShader(shader);
        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS) && !gl.isContextLost())
            alert(gl.getShaderInfoLog(shader));
        return shader;
    };

