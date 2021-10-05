    /**
     * Methods related to textures
     * @name ___METHODS_FOR_TEXTURES___
     * @memberof rglwidgetClass
     * @kind function
     * @instance
     */
     
    rglwidgetClass.prototype.getTexFilter = function(filter) {
      var gl = this.gl || this.initGL();
      switch(filter) {
        case "nearest": return gl.NEAREST;
        case "linear": return gl.LINEAR;
        case "nearest.mipmap.nearest": return gl.NEAREST_MIPMAP_NEAREST;
        case "linear.mipmap.nearest": return gl.LINEAR_MIPMAP_NEAREST;
        case "nearest.mipmap.linear": return gl.NEAREST_MIPMAP_LINEAR;
        case "linear.mipmap.linear": return gl.LINEAR_MIPMAP_LINEAR;
        default: console.error("Unknown filter: "+filter);
      }
    };
     
    /**
     * Handle a texture after its image has been loaded
     * @param { Object } texture - the gl texture object
     * @param { number } i - the level in a mipmap
     * @param { Object } textureCanvas - the canvas holding the image
     */
    rglwidgetClass.prototype.handleLoadedTexture = function(texture, i, textureCanvas, mipmap, minfilter, magfilter, generate) {
      var gl = this.gl || this.initGL();
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
      gl.bindTexture(gl.TEXTURE_2D, texture);
      if (typeof mipmap === "undefined")
        mipmap = true;
      if (typeof generate === "undefined")
        generate = mipmap;
      if (i === 0) {
        if (typeof minfilter === "undefined")
          minfilter = mipmap ? gl.LINEAR_MIPMAP_NEAREST : gl.LINEAR;
        if (typeof magfilter === "undefined")
          magfilter = gl.LINEAR;

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, magfilter);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, minfilter);
        if (mipmap) {
          // Prevents s-coordinate wrapping (repeating).
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
          // Prevents t-coordinate wrapping (repeating).
          gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        }
      }
      gl.texImage2D(gl.TEXTURE_2D, i, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, textureCanvas);
      if (generate) /* only one texture */
        gl.generateMipmap(gl.TEXTURE_2D);
      gl.bindTexture(gl.TEXTURE_2D, null);
    };

    /**
     * Get maximum dimension of texture in current browser.
     * @returns {number}
     */
    rglwidgetClass.prototype.getMaxTexSize = function() {
      var gl = this.gl || this.initGL();	
      return Math.min(4096, gl.getParameter(gl.MAX_TEXTURE_SIZE));
    };
    
    /**
     * Load an image to a texture
     * @param { string } uri - The image location
     * @param { Object } texture - the gl texture object
     */
    rglwidgetClass.prototype.loadImageToTexture = function(obj) {
      var canvas = this.textureCanvas,
          ctx = canvas.getContext("2d"),
          image = new Image(),
          self = this,
          minindex = Infinity,
          texture = obj.texture,
          mat = obj.material, uris,
          minfilter = this.getTexFilter(this.getMaterial(obj, "texminfilter")),
          magfilter = this.getTexFilter(this.getMaterial(obj, "texmagfilter"));
      if (typeof mat.uris !== "undefined")
        uris = mat.uris;
      else if (typeof mat.uriElementId === "undefined")
        uris = [""];
      else
        uris = document.getElementById(mat.uriElementId).rglinstance.getObj(mat.uriId).material.uris;
        
       image.onload = function() {
         var canvasX = self.getPowerOfTwo(image.width),
             canvasY = self.getPowerOfTwo(image.height),
             maxTexSize = self.getMaxTexSize(),
             idx = this.idx,
             texmipmap = self.getMaterial(obj, "texmipmap");
         
         if (!texmipmap && idx > 0)
           return;  /* Skip later images if not mipmapping */

         if (idx < uris.length - 1 && 
             (canvasX > maxTexSize || canvasY > maxTexSize))
           return; /* Skip images that are too large. */
         while (Math.max(canvasX, canvasY) > maxTexSize && maxTexSize > 1)  {
           /* This only runs if there are no more images */
           canvasX = Math.max(1, canvasX/2);
           canvasY = Math.max(1, canvasY/2);
         }
         canvas.width = canvasX;
         canvas.height = canvasY;
         ctx.imageSmoothingEnabled = true;
         ctx.drawImage(image, 0, 0, canvasX, canvasY);
         minindex = Math.min(minindex, idx);
         self.handleLoadedTexture(texture, idx - minindex, canvas, texmipmap,
         minfilter, magfilter, texmipmap && uris.length === 1);
         if (texmipmap && uris.length > 1) {
           if (idx >= uris.length-1) {
           /* We may have run out of images, but not be down to 1x1 yet */
             while (canvasX > 1 || canvasY > 1) {
               canvas.width = canvasX = Math.max(1, canvasX/2);
               canvas.height = canvasY = Math.max(1, canvasY/2);
               image.idx = idx + 1;
               ctx.drawImage(image, 0, 0, canvasX, canvasY);
               self.handleLoadedTexture(texture, idx - minindex, canvas, true, minfilter, magfilter, false);
             }
             self.drawScene();
           } else {
             idx += 1;
             image.idx = idx;
             image.src = uris[idx];
           }
         } else
           self.drawScene();
       };
       
       image.idx = 0;
       image.src = uris[0];
     };

    /**
     * Draw text to the texture canvas
     * @returns { Object } object with text measurements
     * @param { string } text - the text
     * @param { number } cex - expansion
     * @param { string } family - font family
     * @param { number } font - font number
     */
    rglwidgetClass.prototype.drawTextToCanvas = function(text, cex, family, font) {
       var canvasX, canvasY,
           scaling = 20,
           textColour = "white",

           backgroundColour = "rgba(0,0,0,0)",
           canvas = this.textureCanvas,
           ctx = canvas.getContext("2d"),
           i, textHeight = 0, textHeights = [], width, widths = [], 
           offsetx, offsety = 0, line, lines = [], offsetsx = [],
           offsetsy = [], lineoffsetsy = [], fontStrings = [],
           maxTexSize = this.getMaxTexSize(),
           getFontString = function(i) {
             textHeights[i] = scaling*cex[i];
             var fontString = textHeights[i] + "px",
                 family0 = family[i],
                 font0 = font[i];
             if (family0 === "sans")
               family0 = "sans-serif";
             else if (family0 === "mono")
               family0 = "monospace";
             fontString = fontString + " " + family0;
             if (font0 === 2 || font0 === 4)
               fontString = "bold " + fontString;
             if (font0 === 3 || font0 === 4)
               fontString = "italic " + fontString;
             return fontString;
           };
       cex = this.repeatToLen(cex, text.length);
       family = this.repeatToLen(family, text.length);
       font = this.repeatToLen(font, text.length);

       canvasX = 1;
       line = -1;
       offsetx = maxTexSize;
       for (i = 0; i < text.length; i++)  {
         ctx.font = fontStrings[i] = getFontString(i);
         width = widths[i] = ctx.measureText(text[i]).width;
         if (offsetx + width > maxTexSize) {
           offsety = offsety + 2*textHeight;
           if (line >= 0)
             lineoffsetsy[line] = offsety;
           line += 1;
           if (offsety > maxTexSize)
             console.error("Too many strings for texture.");
           textHeight = 0;
           offsetx = 0;
         }
         textHeight = Math.max(textHeight, textHeights[i]);
         offsetsx[i] = offsetx;
         offsetx += width;
         canvasX = Math.max(canvasX, offsetx);
         lines[i] = line;
       }
       offsety = lineoffsetsy[line] = offsety + 2*textHeight;
       for (i = 0; i < text.length; i++) {
       	 offsetsy[i] = lineoffsetsy[lines[i]];
       }
       
       canvasX = this.getPowerOfTwo(canvasX);
       canvasY = this.getPowerOfTwo(offsety);

       canvas.width = canvasX;
       canvas.height = canvasY;

       ctx.fillStyle = backgroundColour;
       ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

       ctx.textBaseline = "alphabetic";
       for(i = 0; i < text.length; i++) {
         ctx.font = fontStrings[i];
         ctx.fillStyle = textColour;
         ctx.textAlign = "left";
         ctx.fillText(text[i], offsetsx[i],  offsetsy[i]);
       }
       return {canvasX:canvasX, canvasY:canvasY,
               widths:widths, textHeights:textHeights,
               offsetsx:offsetsx, offsetsy:offsetsy};
     };

