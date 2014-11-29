subst <- function(strings, ..., digits=7) {
  substitutions <- list(...)
  names <- names(substitutions)
  if (is.null(names)) names <- rep("", length(substitutions))
  for (i in seq_along(names)) {
    if ((n <- names[i]) == "")
      n <- as.character(sys.call()[[i+2]])
    value <- substitutions[[i]]
    if (is.numeric(value)) 
      value <- formatC(value, digits=digits, width=1)
    strings <- gsub(paste("%", n, "%", sep=""), value, strings)
  }
  strings
}

addDP <- function(value, digits=7) {
  if (is.numeric(value)) {
    value <- formatC(value, digits=digits, width=1)
    noDP <- !grepl("[.]", value)
    value[noDP] <- paste(value[noDP], ".", sep="")
  }
  value
}

inRows <- function(values, perrow, leadin = '	', digits=7) {
  if (is.matrix(values)) values <- t(values)
  values <- c(values)
  if (is.numeric(values))
    values <- formatC(values, digits=digits, width=1)
  len <- length(values)
  if (len %% perrow != 0)
    values <- c(values, rep("PADDING", perrow - len %% perrow))
  values <- matrix(values, ncol=perrow, byrow=TRUE)
  
  lines <- paste(leadin, apply(values, 1,
                     function(row) paste(row, collapse=", ")))
  lines[length(lines)] <- gsub(", PADDING", "", lines[length(lines)])
  paste(lines, collapse=",\n")
}

convertBBox <- function(id) {
  verts <- rgl.attrib(id, "vertices")
  text <- rgl.attrib(id, "text")
  if (!length(text))
    text <- rep("", NROW(verts))
  mat <- rgl.getmaterial(id = id)
  if (length(mat$color) > 1)
    mat$color <- mat$color[2] # We ignore the "box" colour
  
  if(any(missing <- text == "")) 
    text[missing] <- apply(verts[missing,], 1, function(row) format(row[!is.na(row)]))
    
  res <- integer(0)
  if (any(inds <- is.na(verts[,2]) & is.na(verts[,3]))) 
    res <- c(res, do.call(axis3d, c(list(edge = "x", at = verts[inds, 1], labels = text[inds]), mat)))
  if (any(inds <- is.na(verts[,1]) & is.na(verts[,3]))) 
    res <- c(res, do.call(axis3d, c(list(edge = "y", at = verts[inds, 2], labels = text[inds]), mat)))
  if (any(inds <- is.na(verts[,1]) & is.na(verts[,2]))) 
    res <- c(res, do.call(axis3d, c(list(edge = "z", at = verts[inds, 3], labels = text[inds]), mat)))
  res <- c(res, do.call(box3d, mat))
  res
}

convertBBoxes <- function (id) {
  result <- NULL
  if (NROW(bboxes <- rgl.ids(type = "bboxdeco", subscene = id))) {
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    useSubscene3d(id)
    for (i in bboxes$id) 
      result <- c(result, convertBBox(i))
  }
  children <- subsceneInfo(id)$children
  for (i in children)
    result <- c(result, convertBBoxes(i))
  result
}

rootSubscene <- function() {
  id <- currentSubscene3d()
  repeat {
    info <- subsceneInfo(id)
    if (is.null(info$parent)) return(id)
    else id <- info$parent
  }
}    

# This gets all the clipping planes in a particular subscene
getClipplanes <- function(subscene) {
  shapes <- rgl.ids(subscene=subscene)
  shapes$id[shapes$type == "clipplanes"]
}

# This counts how many clipping planes might affect a particular object
countClipplanes <- function(id) {
  recurse <- function(subscene) {
    result <- 0
    if (id %in% rgl.ids(c("shapes", "bboxdeco"), subscene=subscene)$id) {
      clipids <- getClipplanes(subscene)
      for (clipid in clipids)
        result <- result + rgl.attrib.count(clipid, "offsets")
    }
    subscenes <- rgl.ids("subscene", subscene=subscene)$id
    for (sub in subscenes) {
      if (result >= bound)
        break
      result <- max(result, recurse(sub))
    }
    result
  }
  bound <- length(getClipplanes(0))
  if (!bound) return(0)
  recurse(rootSubscene())
}  

writeWebGL <- function(dir="webGL", filename=file.path(dir, "index.html"), 
                       template = system.file(file.path("WebGL", "template.html"), package = "rgl"),
                       prefix = "",
                       snapshot = TRUE, commonParts = TRUE,
		       font="Arial",
                       width, height) {
 
  # Lots of utility functions and constants defined first; execution starts way down there...
  

  vec2vec3 <- function(vec) {
    vec <- addDP(vec)
    sprintf("vec3(%s, %s, %s)", vec[1], vec[2], vec[3])
  }
  
  col2rgba <- function(col) as.numeric(col2rgb(col, alpha=TRUE))/255
  
  col2vec3 <- function(col) vec2vec3(col2rgba(col))
  
  vec2vec4 <- function(vec) {
    vec <- addDP(vec)
    sprintf("vec4(%s, %s, %s, %s)", vec[1], vec[2], vec[3], vec[4])
  }
  
  header <- function() c(
  	if (commonParts) 
'	<script src="CanvasMatrix.js" type="text/javascript"></script>',
        subst(
'	<canvas id="%prefix%textureCanvas" style="display: none;" width="256" height="256">
        %snapshotimg%
	Your browser does not support the HTML5 canvas element.</canvas>
', prefix, snapshotimg))

  shaders <- function(id, type, flags) {
    if (type == "clipplanes") return(NULL)
    mat <- rgl.getmaterial(id=id)
    is_lit <- flags["is_lit"]
    is_smooth <- flags["is_smooth"]
    has_texture <- flags["has_texture"]
    fixed_quads <- flags["fixed_quads"]
    sprites_3d <- flags["sprites_3d"]
    toplevel <- flags["toplevel"]
    clipplanes <- countClipplanes(id)
    
    if (has_texture)
      texture_format <- mat$textype

    if (is_lit) {
      lights <- rgl.ids("lights")
      if (is.na(lights$id[1])) {
        # no lights
        is_lit <- FALSE
      }
      else {
        lAmbient <- list()
        lDiffuse <- list()
        lSpecular <- list()
        lightxyz <- list()
        lighttype <- matrix(NA, length(lights$id), 2)
        colnames(lighttype) <- c("viewpoint", "finite")
        for (i in seq_along(lights$id)) {
            lightid <- lights$id[[i]]
            lightcols <- rgl.attrib(lightid, "colors")
            lAmbient[[i]] <- lightcols[1,]
            lDiffuse[[i]] <- lightcols[2,]
            lSpecular[[i]] <- lightcols[3,]
            lightxyz[[i]] <- rgl.attrib(lightid, "vertices")
            lighttype[i,] <- t(rgl.attrib(lightid, "flags"))
        }
      }
    }
    vertex <- subst(
'	<!-- ****** %type% object %id% ****** -->',
      type, id)
    if (sprites_3d)
      return(c(vertex, 
'	<!-- 3d sprite, no shader -->
'            ))

    vertex <- c(vertex, subst(
'	<script id="%prefix%vshader%id%" type="x-shader/x-vertex">', 
      prefix, id),
	
'	attribute vec3 aPos;
	attribute vec4 aCol;
	uniform mat4 mvMatrix;
	uniform mat4 prMatrix;
	varying vec4 vCol;
	varying vec4 vPosition;',
	
      if (is_lit && !fixed_quads) 
'	attribute vec3 aNorm;
	uniform mat4 normMatrix;
	varying vec3 vNormal;',
		  
      if (has_texture || type == "text")
'	attribute vec2 aTexcoord;
	varying vec2 vTexcoord;',
	
      if (type == "text")
'	uniform vec2 textScale;',

      if (fixed_quads)
'	attribute vec2 aOfs;'
      else if (!toplevel)
'	uniform vec3 uOrig;
	uniform float uSize;
	uniform mat4 usermat;',
	
'	void main(void) {',

      if (clipplanes || (!fixed_quads && toplevel))
'	  vPosition = mvMatrix * vec4(aPos, 1.);',

      if (!fixed_quads && toplevel)
'	  gl_Position = prMatrix * vPosition;',
	  
      if (type == "points") subst(
'	  gl_PointSize = %size%;', size=addDP(mat$size)),

'	  vCol = aCol;',

      if (is_lit && !fixed_quads && toplevel)
'	  vNormal = normalize((normMatrix * vec4(aNorm, 1.)).xyz);',

      if (has_texture || type == "text")
'	  vTexcoord = aTexcoord;',

      if (type == "text") 
'	  vec4 pos = prMatrix * mvMatrix * vec4(aPos, 1.);
	  pos = pos/pos.w;
	  gl_Position = pos + vec4(aOfs*textScale, 0.,0.);',
	  
      if (type == "sprites") 
'	  vec4 pos = mvMatrix * vec4(aPos, 1.);
	  pos = pos/pos.w + vec4(aOfs, 0., 0.);
	  gl_Position = prMatrix*pos;',
	  
      if (!toplevel)
'	  vNormal = normalize((vec4(aNorm, 1.)*normMatrix).xyz);	  
	  vec4 pos = mvMatrix * vec4(uOrig, 1.);
	  vPosition = pos/pos.w + vec4(uSize*(vec4(aPos, 1.)*usermat).xyz,0.);
	  gl_Position = prMatrix * vPosition;',
	  	  
'	}
	</script>
')

    # Important:  in some implementations (e.g. ANGLE) declarations that involve computing must be local (inside main()), not global
    fragment <- c(subst(
'	<script id="%prefix%fshader%id%" type="x-shader/x-fragment"> 
	#ifdef GL_ES
	precision highp float;
	#endif
	varying vec4 vCol; // carries alpha
	varying vec4 vPosition;',
      prefix, id),
      
      if (has_texture || type == "text") 
'	varying vec2 vTexcoord;
	uniform sampler2D uSampler;',
  
      if (is_lit && !fixed_quads)
'	varying vec3 vNormal;',

      if (clipplanes) paste0(
'	uniform vec4 vClipplane', seq_len(clipplanes), ';'),

      if (is_lit && !all(lighttype[,"viewpoint"]))
'	uniform mat4 mvMatrix;',

'	void main(void) {',

      if (clipplanes) paste0(
'	  if (dot(vPosition, vClipplane', seq_len(clipplanes), ') < 0.0) discard;'),

      if (is_lit)
'	  vec3 eye = normalize(-vPosition.xyz);',      

   # collect lighting information   
      if (is_lit) {
        res <- subst(
'	  const vec3 emission = %emission%;',
          emission = vec2vec3(col2rgba(mat$emission)))

        for (idn in seq_along(lights$id)) { 
          finite <- lighttype[idn,"finite"]
          viewpoint <- lighttype[idn, "viewpoint"]
          res <- c(res, subst(
'	  const vec3 ambient%idn% = %ambient%;
	  const vec3 specular%idn% = %specular%;// light*material
	  const float shininess%idn% = %shininess%;
	  vec4 colDiff%idn% = vec4(vCol.rgb * %diffuse%, vCol.a);',
          ambient = vec2vec3(col2rgba(mat$ambient)*lAmbient[[idn]] + col2rgba(mat$emission)), #FIXME : Materialemission wird bei mehreren Lichtquellen mehrfach genutzt 
          specular = vec2vec3(col2rgba(mat$specular)*lSpecular[[idn]]), 
          shininess = addDP(mat$shininess),
          diffuse = vec2vec3(lDiffuse[[idn]]),
          idn = idn),
     
          {
            lightdir <- lightxyz[[idn]]
            if (!finite)
              lightdir <- normalize(lightdir)
            if (viewpoint)
              lightdir <- vec2vec3(lightdir)
            else
              lightdir <- subst('(mvMatrix * %lightdir%).xyz', lightdir=vec2vec4(c(lightdir,1)))
            # directional light
            if (!finite) {
              subst(
'	  const vec3 lightDir%idn% = %lightdir%;
	  vec3 halfVec%idn% = normalize(lightDir%idn% + eye);',
              lightdir = lightdir,
              idn = idn)
            }
            else { # point-light
              subst(
'	  vec3 lightDir%idn% = normalize(%lightdir% - vPosition.xyz);
	  vec3 halfVec%idn% = normalize(lightDir%idn% + eye);',
              lightdir = lightdir,
              idn = idn)
            }
          })
        }
        res
      }
      else {
'      vec4 colDiff = vCol;'
      },

      if (is_lit) {
        res <- c(
'      vec4 lighteffect = vec4(emission, 0.);')
        if (fixed_quads) {
          res <- c(res,
'	  vec3 n = vec3(0., 0., -1.);')
        }
        else {
          res <- c(res,
'	  vec3 n = normalize(vNormal);
	  n = -faceforward(n, n, eye);')
        }
        for (idn in seq_along(lights$id)) {
          res <- c(res, subst(
'	  vec3 col%idn% = ambient%idn%;
	  float nDotL%idn% = dot(n, lightDir%idn%);
	  col%idn% = col%idn% + max(nDotL%idn%, 0.) * colDiff%idn%.rgb;
	  col%idn% = col%idn% + pow(max(dot(halfVec%idn%, n), 0.), shininess%idn%) * specular%idn%;
	  lighteffect = lighteffect + vec4(col%idn%, colDiff%idn%.a);',
          idn = idn))
        }
        res
      }
      else { 
'	  vec4 lighteffect = colDiff;'
      },

      if ((has_texture && texture_format == "rgba") || type == "text")
'	  vec4 textureColor = lighteffect*texture2D(uSampler, vTexcoord);',

      if (has_texture) switch(texture_format,
         rgb = 
'	  vec4 textureColor = lighteffect*vec4(texture2D(uSampler, vTexcoord).rgb, 1.);',
	 alpha =
'	  vec4 textureColor = texture2D(uSampler, vTexcoord);
	  float luminance = dot(vec3(1.,1.,1.), textureColor.rgb)/3.;
	  textureColor =  vec4(lighteffect.rgb, lighteffect.a*luminance);',
         luminance =
'	  vec4 textureColor = vec4(lighteffect.rgb*dot(texture2D(uSampler, vTexcoord).rgb, vec3(1.,1.,1.))/3.,
                                   lighteffect.a);',
         luminance.alpha =
'	  vec4 textureColor = texture2D(uSampler, vTexcoord);
	  float luminance = dot(vec3(1.,1.,1.),textureColor.rgb)/3.;
	  textureColor = vec4(lighteffect.rgb*luminance, lighteffect.a*textureColor.a);'),
           
      if (has_texture)
'	  gl_FragColor = textureColor;'
      else if (type == "text")
'	  if (textureColor.a < 0.1)
	    discard;
	  else
	    gl_FragColor = textureColor;'
        else
'	  gl_FragColor = lighteffect;',

'	}
	</script> 
'     )
    c(vertex, fragment)    
  }

  scriptheader <- function() c(
  '
	<script type="text/javascript">',
  
  if (commonParts)
'
	function getShader ( gl, id ){
	   var shaderScript = document.getElementById ( id );
	   var str = "";
	   var k = shaderScript.firstChild;
	   while ( k ){
	     if ( k.nodeType == 3 ) str += k.textContent;
	     k = k.nextSibling;
	   }
	   var shader;
	   if ( shaderScript.type == "x-shader/x-fragment" )
             shader = gl.createShader ( gl.FRAGMENT_SHADER );
	   else if ( shaderScript.type == "x-shader/x-vertex" )
             shader = gl.createShader(gl.VERTEX_SHADER);
	   else return null;
	   gl.shaderSource(shader, str);
	   gl.compileShader(shader);
	   if (gl.getShaderParameter(shader, gl.COMPILE_STATUS) == 0)
	     alert(gl.getShaderInfoLog(shader));
	   return shader;
	}

	var min = Math.min;
	var max = Math.max;
	var sqrt = Math.sqrt;
	var sin = Math.sin;
	var acos = Math.acos;
	var tan = Math.tan;
	var SQRT2 = Math.SQRT2;
	var PI = Math.PI;
	var log = Math.log;
	var exp = Math.exp;
',
  subst(
'
	function %prefix%webGLStart() {
	   var debug = function(msg) {
	     document.getElementById("%prefix%debug").innerHTML = msg;
	   }
	   debug("");

	   var canvas = document.getElementById("%prefix%canvas");
	   if (!window.WebGLRenderingContext){
	     debug("%snapshotimg2% Your browser does not support WebGL. See <a href=\\\"http://get.webgl.org\\\">http://get.webgl.org</a>");
	     return;
	   }
	   var gl;
	   try {
	     // Try to grab the standard context. If it fails, fallback to experimental.
	     gl = canvas.getContext("webgl") 
	       || canvas.getContext("experimental-webgl");
	   }
	   catch(e) {}
	   if ( !gl ) {
	     debug("%snapshotimg2% Your browser appears to support WebGL, but did not create a WebGL context.  See <a href=\\\"http://get.webgl.org\\\">http://get.webgl.org</a>");
	     return;
	   }
	   var width = %width%;  var height = %height%;
	   canvas.width = width;   canvas.height = height;
	   var prMatrix = new CanvasMatrix4();
	   var mvMatrix = new CanvasMatrix4();
	   var normMatrix = new CanvasMatrix4();
	   var saveMat = new CanvasMatrix4();
	   saveMat.makeIdentity();
	   var distance;
	   var posLoc = 0;
	   var colLoc = 1;
', prefix, snapshotimg2, width, height))
  
  setUser <- function() {
    subsceneids <- rgl.ids("subscene", subscene = 0)$id
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    result <- subst(
'       var zoom = new Object();
       var fov = new Object();
       var userMatrix = new Object();
       var activeSubscene = %root%;', root=rootSubscene())
    
    for (id in subsceneids) {
      info <- subsceneInfo(id)
      if (info$embeddings["projection"] != "inherit") {
        useSubscene3d(id)
        result <- c(result, subst(
'       zoom[%id%] = %zoom%;
       fov[%id%] = %fov%;', id, zoom = par3d("zoom"), fov = max(1, min(179, par3d("FOV")))))
      }
      if (info$embeddings["model"] != "inherit") {
        useSubscene3d(id)
        result <- c(result, subst(
'       userMatrix[%id%] = new CanvasMatrix4();
       userMatrix[%id%].load([', id),
    inRows(t(par3d("userMatrix")), perrow=4, leadin='	   '),
'		]);')
      }
    }    
    result
  }
  
  textureSupport <- subst(
'	   function getPowerOfTwo(value) {
	     var pow = 1;
	     while(pow<value) {
	       pow *= 2;
	     }
	     return pow;
	   }

	   function handleLoadedTexture(texture, textureCanvas) {
	     gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);

	     gl.bindTexture(gl.TEXTURE_2D, texture);
	     gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, textureCanvas);
	     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
	     gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
	     gl.generateMipmap(gl.TEXTURE_2D);

	     gl.bindTexture(gl.TEXTURE_2D, null);
	   }
	   
	   function loadImageToTexture(filename, texture) {   
	     var canvas = document.getElementById("%prefix%textureCanvas");
	     var ctx = canvas.getContext("2d");
	     var image = new Image();
	     
	     image.onload = function() {
	       var w = image.width;
	       var h = image.height;
	       var canvasX = getPowerOfTwo(w);
	       var canvasY = getPowerOfTwo(h);
	       canvas.width = canvasX;
	       canvas.height = canvasY;
	       ctx.imageSmoothingEnabled = true;
	       ctx.drawImage(image, 0, 0, canvasX, canvasY);
	       handleLoadedTexture(texture, canvas);
   	       drawScene();
	     }
	     image.src = filename;
	   }  	   
', prefix)

  textSupport <- subst( 
'	   function drawTextToCanvas(text, cex) {
	     var canvasX, canvasY;
	     var textX, textY;

	     var textHeight = 20 * cex;
	     var textColour = "white";
	     var fontFamily = "%font%";

	     var backgroundColour = "rgba(0,0,0,0)";

	     var canvas = document.getElementById("%prefix%textureCanvas");
	     var ctx = canvas.getContext("2d");

	     ctx.font = textHeight+"px "+fontFamily;

	     canvasX = 1;
	     var widths = [];
	     for (var i = 0; i < text.length; i++)  {
	       widths[i] = ctx.measureText(text[i]).width;
	       canvasX = (widths[i] > canvasX) ? widths[i] : canvasX;
	     }	  
	     canvasX = getPowerOfTwo(canvasX);

	     var offset = 2*textHeight; // offset to first baseline
	     var skip = 2*textHeight;   // skip between baselines	  
	     canvasY = getPowerOfTwo(offset + text.length*skip);
	     
	     canvas.width = canvasX;
	     canvas.height = canvasY;

	     ctx.fillStyle = backgroundColour;
	     ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height);

	     ctx.fillStyle = textColour;
	     ctx.textAlign = "left";

	     ctx.textBaseline = "alphabetic";
	     ctx.font = textHeight+"px "+fontFamily;

	     for(var i = 0; i < text.length; i++) {
	       textY = i*skip + offset;
	       ctx.fillText(text[i], 0,  textY);
	     }
	     return {canvasX:canvasX, canvasY:canvasY,
	             widths:widths, textHeight:textHeight,
	             offset:offset, skip:skip};
	   }
', font, prefix)

  sphereCount <- 0
  sphereStride <- 0
  
  sphereSupport <- function() {
    x <- subdivision3d(octahedron3d(),2)
    x$vb[4,] <- 1
    r <- sqrt(x$vb[1,]^2 + x$vb[2,]^2 + x$vb[3,]^2)
    values <- t(x$vb[1:3,])/r
    sphereCount <<- length(x$it)
    sphereStride <<- 12
    c(
'	   // ****** sphere object ******
	   var v=new Float32Array([',
      inRows(values, perrow=3, '	   '),
'	   ]);
	   var f=new Uint16Array([', 
      inRows(t(x$it)-1, perrow=3, '	   '),
'	   ]);
	   var sphereBuf = gl.createBuffer();
	   gl.bindBuffer(gl.ARRAY_BUFFER, sphereBuf);
	   gl.bufferData(gl.ARRAY_BUFFER, v, gl.STATIC_DRAW);
	   var sphereIbuf = gl.createBuffer();
	   gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereIbuf);
	   gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, f, gl.STATIC_DRAW);
')
}    

  setViewport <- function() {
    viewport <- par3d("viewport")*c(wfactor, hfactor)
    subst('
	     gl.viewport(%x%, %y%, %width%, %height%);
	     gl.scissor(%x%, %y%, %width%, %height%);
', x = viewport[1], y = viewport[2], width = viewport[3], height = viewport[4])
  }
  
  setprMatrix <- function(subsceneid) {
    info <- subsceneInfo(subsceneid)
    embedding <- info$embeddings["projection"]
    if (embedding == "replace")
      result <-
'	   prMatrix.makeIdentity();'
    else
      result <- setprMatrix(info$parent);
    if (embedding == "inherit")
      return(result)
      
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    
    useSubscene3d(subsceneid)
    
    # This is based on the Frustum::enclose code from geom.cpp
    bbox <- par3d("bbox")
    scale <- par3d("scale")
    ranges <- c(bbox[2]-bbox[1], bbox[4]-bbox[3], bbox[6]-bbox[5])*scale/2
    radius <- sqrt(sum(ranges^2))*1.1 # A bit bigger to handle labels
    if (radius <= 0) radius <- 1
    observer <- par3d("observer")
    distance <- observer[3]
    viewport <- par3d("viewport")
    aspect <- viewport[3]/viewport[4]
    subst(
'	     var radius = %radius%;
	     var distance = %distance%;
	     var t = tan(fov[%id%]*PI/360);
	     var near = distance - radius;
	     var far = distance + radius;
	     var hlen = t*near;
	     var aspect = %aspect%;
	     prMatrix.makeIdentity();
	     if (aspect > 1)
	       prMatrix.frustum(-hlen*aspect*zoom[%id%], hlen*aspect*zoom[%id%], 
	                        -hlen*zoom[%id%], hlen*zoom[%id%], near, far);
	     else  
	       prMatrix.frustum(-hlen*zoom[%id%], hlen*zoom[%id%], 
	                        -hlen*zoom[%id%]/aspect, hlen*zoom[%id%]/aspect, 
	                        near, far);',
            id = subsceneid, radius, distance, aspect)
  }

  setmvMatrix <- function(subsceneid) {
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    
    useSubscene3d(subsceneid)
    observer <- par3d("observer")
    
    c('
         mvMatrix.makeIdentity();',
      setmodelMatrix(subsceneid),
      subst(
'         mvMatrix.translate(%x%, %y%, %z%);',
        x = -observer[1], y = -observer[2], z = -observer[3]))
  }      
	     
  setmodelMatrix <- function(subsceneid) {
    info <- subsceneInfo(subsceneid)
    embedding <- info$embeddings["model"]
    
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    
    useSubscene3d(subsceneid)

    if (embedding != "inherit") {
      scale <- par3d("scale")
      bbox <- par3d("bbox")
      center <- c(bbox[1]+bbox[2], bbox[3]+bbox[4], bbox[5]+bbox[6])/2
      result <- subst(
'	     mvMatrix.translate( %cx%, %cy%, %cz% );
	     mvMatrix.scale( %sx%, %sy%, %sz% );   
	     mvMatrix.multRight( userMatrix[%id%] );',
     id = subsceneid,
     cx=-center[1], cy=-center[2], cz=-center[3],
     sx=scale[1],   sy=scale[2],   sz=scale[3])
    } else result <- character(0)
   
    if (embedding != "replace") 
      result <- c(result, setmodelMatrix(info$parent))
     
    result
  }
  
  setnormMatrix <- function(subsceneid) {
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    
    recurse <- function(subsceneid) {
      info <- subsceneInfo(subsceneid)
      embedding <- info$embeddings["model"]
    
      useSubscene3d(subsceneid)
      if (embedding != "inherit") {    
        scale <- par3d("scale")
        result <- subst(
'	     normMatrix.scale( %sx%, %sy%, %sz% );   
	     normMatrix.multRight( userMatrix[%id%] );',
         id = subsceneid,
         sx=1/scale[1], sy=1/scale[2], sz=1/scale[3])
      } else result <- character(0)
    
      if (embedding != "replace")
        result <- c(result, recurse(info$parent))
      result
    }
    c('
         normMatrix.makeIdentity();',
      recurse(subsceneid))
  }
  
  setprmvMatrix <-
'	     var prmvMatrix = new CanvasMatrix4();
	     prmvMatrix.load(mvMatrix);
	     prmvMatrix.multRight( prMatrix );'

  init <- function(id, type, flags) {
    is_indexed <- flags["is_indexed"]
    mat <- rgl.getmaterial(id=id)
    is_lit <- flags["is_lit"]
    has_texture <- flags["has_texture"]
    fixed_quads <- flags["fixed_quads"]
    depth_sort <- flags["depth_sort"]
    sprites_3d <- flags["sprites_3d"]
    toplevel <- flags["toplevel"]
    is_clipplanes <- type == "clipplanes"
    clipplanes <- countClipplanes(id)
    
    result <- subst(
'
	   // ****** %type% object %id% ******', type, id)
    if (!sprites_3d && !is_clipplanes)
      result <- c(result, subst(
'	   var prog%id%  = gl.createProgram();
	   gl.attachShader(prog%id%, getShader( gl, "%prefix%vshader%id%" ));
	   gl.attachShader(prog%id%, getShader( gl, "%prefix%fshader%id%" ));
	   //  Force aPos to location 0, aCol to location 1 
	   gl.bindAttribLocation(prog%id%, 0, "aPos");
	   gl.bindAttribLocation(prog%id%, 1, "aCol");
	   gl.linkProgram(prog%id%);', id, prefix))
   
    nv <- rgl.attrib.count(id, "vertices")
    if (nv)
      values <- rgl.attrib(id, "vertices")
    else
      values <- NULL
    if (nv > 65535)
    	warning("Object ", id, " has ", nv, " vertices.  Some browsers support only 65535.")
    
    nc <- rgl.attrib.count(id, "colors")
    colors <- rgl.attrib(id, "colors")
    if (nc > 1) {
      if (nc != nv) {
        rows <- rep(seq_len(nc), length.out=nv)
        colors <- colors[rows,,drop=FALSE]
      }
      values <- cbind(values, colors)
    }
    
    nn <- rgl.attrib.count(id, "normals")
    if (nn > 0) {
      normals <- rgl.attrib(id, "normals")
      values <- cbind(values, normals)
    } 
    
    if (type == "spheres") {
      radii <- rgl.attrib(id, "radii")
      if (length(radii) == 1)
        radii <- rep(radii, NROW(values))
      values <- cbind(values, radii)
    }
    
    if (type == "clipplanes") {
      offsets <- rgl.attrib(id, "offsets")
      stopifnot(NCOL(values) == 3)
      values <- cbind(values, offsets)
      result <- c(result,subst(
'	   var vClipplane%id%=[', id),
      inRows(values, 4, leadin='	   '),
'	   ];
')
      return(result)
    }
    
    if (type == "surface") { # Compute indices of triangles
      dim <- rgl.attrib(id, "dim")
      nx <- dim[1]
      nz <- dim[2]
      f <- NULL
      for (j in seq_len(nx-1)-1) {
        v1 <- j + nx*(seq_len(nz) - 1)
        v2 <- v1 + 1
        f <- cbind(f, rbind(v1[-nz],
                            v1[-1],
                            v2[-1],
                            v1[-nz],
                            v2[-1],
                            v2[-nz]))
      }
      frowsize <- 6
    }  
    
    if (type == "text") {
      adj <- rgl.attrib(id, "adj") # Should query scene...
      texts <- rgl.attrib(id, "texts")
      cex <- rgl.attrib(id, "cex")
      if (min(cex) < max(cex))
      	warning("Only the first value of cex used")
      
      values <- values[rep(seq_len(nv), each=4),]
      
      # String heights and widths need to be multiplied in here
      texcoords <- matrix(rep(c(0,-0.5,1,-0.5,1,1.5,0,1.5),nv), 4*nv, 2, byrow=TRUE)
      refs <- matrix(adj, 4*nv, 2, byrow=TRUE)
      tofs <- NCOL(values)
      values <- cbind(values, texcoords)
      oofs <- NCOL(values)
      values <- cbind(values, refs)
      nv <- nv*4
      result <- c(result, 
'	   var texts = [',
      	paste('	    "', texts, '"', sep="", collapse=",\n"),
'	   ];',

        subst(
'	   var texinfo = drawTextToCanvas(texts, %cex%);	 
	   var canvasX%id% = texinfo.canvasX;
	   var canvasY%id% = texinfo.canvasY;',
	  cex=cex[1], id))
    }

    if (type == "sprites") {
      oofs <- NCOL(values)
      if (sprites_3d) 
        values <- cbind(values, rep(rgl.attrib(id, "radii")/2, len=nv))
      else {
        size <- rep(rgl.attrib(id, "radii"), len=4*nv)
        values <- values[rep(seq_len(nv), each=4),]
        texcoords <- matrix(rep(c(0,0,1,0,1,1,0,1),nv), 4*nv, 2, byrow=TRUE)
        values <- cbind(values, (texcoords - 0.5)*size)
        nv <- nv*4
      }
    }

    if (fixed_quads && !sprites_3d) result <- c(result, subst(
'	   var ofsLoc%id% = gl.getAttribLocation(prog%id%, "aOfs");',
          id))
          
    if (!toplevel) result <- c(result, subst(
'	   var origLoc%id% = gl.getUniformLocation(prog%id%, "uOrig");
           var sizeLoc%id% = gl.getUniformLocation(prog%id%, "uSize");
           var usermatLoc%id% = gl.getUniformLocation(prog%id%, "usermat");',
	  id))
    
    if (has_texture || type == "text") result <- c(result, subst(
'	   var texture%id% = gl.createTexture();
	   var texLoc%id% = gl.getAttribLocation(prog%id%, "aTexcoord");
	   var sampler%id% = gl.getUniformLocation(prog%id%,"uSampler");',
	  id))
	  
    if (has_texture) {
      tofs <- NCOL(values)
      if (type != "sprites")
        texcoords <- rgl.attrib(id, "texcoords")
      if (!sprites_3d)
      	values <- cbind(values, texcoords)
      file.copy(mat$texture, file.path(dir, paste(prefix, "texture", id, ".png", sep="")))
      result <- c(result, subst(
'	   loadImageToTexture("%prefix%texture%id%.png", texture%id%);',
        prefix, id))
    }
    
    if (type == "text") result <- c(result, subst(
'    	   handleLoadedTexture(texture%id%, document.getElementById("%prefix%textureCanvas"));',
        id, prefix))
      
    stride <- NCOL(values)
    result <- c(result,
      if (sprites_3d) subst(
'	   var origsize%id%=new Float32Array([', id)
      else
'	   var v=new Float32Array([',
      inRows(values, stride, leadin='	   '),
'	   ]);',

      if (sprites_3d) c(subst(
'	   userMatrix[%id%] = new Float32Array([', id),
        inRows(rgl.attrib(id, "usermatrix"), 4, leadin='	   '),
'	   ]);'),
        
      if (type == "text") subst(
'	   for (var i=0; i<%len%; i++) 
	     for (var j=0; j<4; j++) {
	         ind = %stride%*(4*i + j) + %tofs%;
	         v[ind+2] = 2*(v[ind]-v[ind+2])*texinfo.widths[i];
	         v[ind+3] = 2*(v[ind+1]-v[ind+3])*texinfo.textHeight;
	         v[ind] *= texinfo.widths[i]/texinfo.canvasX;
	         v[ind+1] = 1.0-(texinfo.offset + i*texinfo.skip 
	           - v[ind+1]*texinfo.textHeight)/texinfo.canvasY;
	     }', len=length(texts), stride, tofs),
	     
      if (type == "spheres") subst(
'	   var values%id% = v;', 
                  id),
	   
      if (is_lit && !fixed_quads && !sprites_3d) subst(
'	   var normLoc%id% = gl.getAttribLocation(prog%id%, "aNorm");', 
        id),
	
      if (clipplanes) subst(paste0(
'	   var clipLoc%id%p', seq_len(clipplanes), ' = gl.getUniformLocation(prog%id%, "vClipplane', seq_len(clipplanes), '");'),
           id)
	)
	

    if (is_indexed) {
      if (type %in% c("quads", "text", "sprites") && !sprites_3d) {
        v1 <- 4*(seq_len(nv/4) - 1)
        v2 <- v1 + 1
        v3 <- v2 + 1
        v4 <- v3 + 1
        f <- rbind(v1, v2, v3, v1, v3, v4)
        frowsize <- 6
      } else if (type == "triangles") {
        v1 <- 3*(seq_len(nv/3) - 1)
        v2 <- v1 + 1
        v3 <- v2 + 1
        f <- rbind(v1, v2, v3)
        frowsize <- 3
      } else if (type == "spheres") {
        f <- seq_len(nv)-1
        frowsize <- 8 # not used for depth sorting, just for display
      }  
        
      if (depth_sort) {
        result <- c(result, subst(
'	   var centers%id% = new Float32Array([', id),
        inRows(rgl.attrib(id, "centers"), 3, leadin='	   '),
'	   ]);')

        fname <- subst("f%id%", id)
        drawtype <- "DYNAMIC_DRAW"
      } else {
        fname <- "f"
        drawtype <- "STATIC_DRAW"
      }
      
      result <- c(result, subst(
'	   var %fname%=new Uint16Array([', 
          fname),
	inRows(c(f), frowsize, leadin='	   '),
'	   ]);')
    }
    result <- c(result,
      if (type != "spheres" && !sprites_3d) subst(
'	   var buf%id% = gl.createBuffer();
	   gl.bindBuffer(gl.ARRAY_BUFFER, buf%id%);
	   gl.bufferData(gl.ARRAY_BUFFER, v, gl.STATIC_DRAW);',
   		id),
      if (is_indexed && type != "spheres" && !sprites_3d) subst(
'	   var ibuf%id% = gl.createBuffer();
	   gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibuf%id%);
	   gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, %fname%, gl.%drawtype%);',
   		id, fname, drawtype),
      if (!sprites_3d && !is_clipplanes) subst(
'	   var mvMatLoc%id% = gl.getUniformLocation(prog%id%,"mvMatrix");
	   var prMatLoc%id% = gl.getUniformLocation(prog%id%,"prMatrix");',
   		  id),
      if (type == "text") subst(
'	   var textScaleLoc%id% = gl.getUniformLocation(prog%id%,"textScale");',
		  id),
      if (is_lit && !sprites_3d) subst(
'	   var normMatLoc%id% = gl.getUniformLocation(prog%id%,"normMatrix");',
		  id)
   		 ) 
    c(result, '')
  }
  
  draw <- function(id, type, flags, clipplanes) {
    mat <- rgl.getmaterial(id=id)
    is_lit <- flags["is_lit"]
    is_indexed <- flags["is_indexed"]
    depth_sort <- flags["depth_sort"]
    has_texture <- flags["has_texture"]
    fixed_quads <- flags["fixed_quads"]
    is_transparent <- flags["is_transparent"]
    sprites_3d <- flags["sprites_3d"]
    toplevel <- flags["toplevel"]
    
    result <- subst(
'
	     // ****** %type% object %id% *******',
       type, id)
  
    if (type == "clipplanes") {
      count <- rgl.attrib.count(id, "offsets")
      for (i in seq_len(count)) {
        result <- c(result, subst(
'	     var IMVClip%id%%part% = multMV(invMatrix, vClipplane%id%%slice%);',
	id, i, slice = if (count > 1) subst(".slice(%first%, %stop%)", first = 4*(i-1), stop = 4*i) else "",
	part = if (count > 1) paste0("p", i) else ""))
      }
      return(result)
    }

    if (sprites_3d) {
      norigs <- rgl.attrib.count(id, "vertices")
      result <- c(result, subst(
'	     origs = origsize%id%;
	     usermat = userMatrix[%id%];
	     for (iOrig=0; iOrig < %norigs%; iOrig++) {',
        id, norigs))
      spriteids <- rgl.attrib(id, "ids")
      types <- rgl.attrib(id, "types")
      for (i in seq_along(spriteids)) 
        result <- c(result, draw(spriteids[i], types[i], 
                    c(getFlags(spriteids[i], types[i]), toplevel=FALSE), clipplanes))
      result <- c(result, 
'	     }')
    } else {
      result <- c(result, subst(	     
'	     gl.useProgram(prog%id%);', id),
       
        if (!toplevel) subst(
'	     gl.uniform3f(origLoc%id%, origs[4*iOrig], 
	                                origs[4*iOrig+1],
	                                origs[4*iOrig+2]);
	     gl.uniform1f(sizeLoc%id%, origs[4*iOrig+3]);
	     gl.uniformMatrix4fv(usermatLoc%id%, false, usermat);',
	  id),
	  
        if (type == "spheres") 
'	     gl.bindBuffer(gl.ARRAY_BUFFER, sphereBuf);'
        else subst(
'	     gl.bindBuffer(gl.ARRAY_BUFFER, buf%id%);',
         id),
       
        if (is_indexed && type != "spheres") subst(    
'	     gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibuf%id%);', id)
        else if (type == "spheres")
'	     gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereIbuf);',

        subst(
'	     gl.uniformMatrix4fv( prMatLoc%id%, false, new Float32Array(prMatrix.getAsArray()) );
	     gl.uniformMatrix4fv( mvMatLoc%id%, false, new Float32Array(mvMatrix.getAsArray()) );',
         id))
         
      clipcheck <- 0
      for (clipid in clipplanes) {
        count <- rgl.attrib.count(clipid, "offsets")
        for (i in seq_len(count)) {
          clipcheck <- clipcheck + 1
  	  result <- c(result, subst(
'	     gl.uniform4fv(clipLoc%id%p%clipcheck%, IMVClip%clipid%%part%);',
	       clipid, id, clipcheck, i, 
	       slice = if (count > 1) subst(".slice(%first%, %stop%)", first = 4*(i-1), stop = 4*i) else "",
	       part = if (count > 1) paste0("p", i) else ""))
        }
      }
             
      if (is_lit && toplevel)
        result <- c(result, subst(
'	     gl.uniformMatrix4fv( normMatLoc%id%, false, new Float32Array(normMatrix.getAsArray()) );',
          id))
          
      if (is_lit && !toplevel)
        result <- c(result, subst(
'	     gl.uniformMatrix4fv( normMatLoc%id%, false, usermat);',
          id))
	  
      if (type == "text") {
        viewport <- par3d("viewport")
        result <- c(result, subst(
'	     gl.uniform2f( textScaleLoc%id%, %x%, %y%);',
          id, x=0.75/viewport[3], y=0.75/viewport[4]))	
      }

      result <- c(result, 
'	     gl.enableVertexAttribArray( posLoc );')

      count <- rgl.attrib.count(id, "vertices")
      stride <- 12 
      nc <- rgl.attrib.count(id, "colors")
      if (nc > 1) {
        cofs <- stride
        stride <- stride + 16
      }
    
      nn <- rgl.attrib.count(id, "normals")
      if (nn > 0) {
        nofs <- stride
        stride <- stride + 12
      }
    
      if (type == "spheres") {
        radofs <- stride
        stride <- stride + 4
        scount <- count
      }
    
      if (type == "sprites" && !sprites_3d) {
        oofs <- stride
        stride <- stride + 8
      }
    
      if (has_texture || type == "text") {
        tofs <- stride
        stride <- stride + 8
      }
    
      if (type == "text") {
        oofs <- stride
        stride <- stride + 8
      }

      if (depth_sort) {
        nfaces <- rgl.attrib.count(id, "centers")
        frowsize <- if (sprites_3d) 1 else
          switch(type,
            quads =,
            text =,
            surface =,
            sprites = 6,
            triangles = 3)
        
        result <- c(result, subst(
'	     var depths = new Float32Array(%nfaces%);
	     var faces = new Array(%nfaces%);
	     for(var i=0; i<%nfaces%; i++) {
	       var z = prmvMatrix.m13*centers%id%[3*i] 
	             + prmvMatrix.m23*centers%id%[3*i+1]
	             + prmvMatrix.m33*centers%id%[3*i+2]
	             + prmvMatrix.m43;
	       var w = prmvMatrix.m14*centers%id%[3*i] 
	             + prmvMatrix.m24*centers%id%[3*i+1]
	             + prmvMatrix.m34*centers%id%[3*i+2]
	             + prmvMatrix.m44;
	       depths[i] = z/w;
	       faces[i] = i;
	     }
	     var depthsort = function(i,j) { return depths[j] - depths[i] }
	     faces.sort(depthsort);',
           nfaces, id),
           if (type != "spheres") subst(
'	     var f = new Uint16Array(f%id%.length);
	     for (var i=0; i<%nfaces%; i++) {
	       for (var j=0; j<%frowsize%; j++) {
	         f[%frowsize%*i + j] = f%id%[%frowsize%*faces[i] + j];
	       }
	     }	     
	     gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, f, gl.DYNAMIC_DRAW);',
	   nfaces, id, frowsize))
      }
    
      if (type == "spheres") {
        scale <- par3d("scale")
        sx <- 1/scale[1]
        sy <- 1/scale[2]
        sz <- 1/scale[3]
        result <- c(result, subst(
'	     gl.vertexAttribPointer(posLoc,  3, gl.FLOAT, false, %sphereStride%,  0);
	     gl.enableVertexAttribArray(normLoc%id% );
	     gl.vertexAttribPointer(normLoc%id%,  3, gl.FLOAT, false, %sphereStride%,  0);
	     gl.disableVertexAttribArray( colLoc );
	     var sphereNorm = new CanvasMatrix4();
	     sphereNorm.scale(%sx%, %sy%, %sz%);
	     sphereNorm.multRight(normMatrix);
	     gl.uniformMatrix4fv( normMatLoc%id%, false, new Float32Array(sphereNorm.getAsArray()) );', 
	    id, sphereStride, sx=1/sx, sy=1/sy, sz=1/sz),

          if (nc == 1) {
            colors <- rgl.attrib(id, "colors")
            subst(
'	     gl.vertexAttrib4f( colLoc, %r%, %g%, %b%, %a%);',
	    r=colors[1], g=colors[2], b=colors[3], a=colors[4])
	  },
	
          subst(
'	     for (var i = 0; i < %scount%; i++) {
	       var sphereMV = new CanvasMatrix4();', scount),
	       
	  if (depth_sort) subst(
'	       var baseofs = faces[i]*%stride%', stride=stride/4)
          else subst(
'	       var baseofs = i*%stride%', stride=stride/4),

	  subst(
'	       var ofs = baseofs + %radofs%;	       
	       var scale = values%id%[ofs];
	       sphereMV.scale(%sx%*scale, %sy%*scale, %sz%*scale);
	       sphereMV.translate(values%id%[baseofs], 
	       			  values%id%[baseofs+1], 
	       			  values%id%[baseofs+2]);
	       sphereMV.multRight(mvMatrix);
	       gl.uniformMatrix4fv( mvMatLoc%id%, false, new Float32Array(sphereMV.getAsArray()) );',
	     radofs=radofs/4, stride=stride/4, id, sx, sy, sz),
	 
	   if (nc > 1) subst(
'	       ofs = baseofs + %cofs%;       
	       gl.vertexAttrib4f( colLoc, values%id%[ofs], 
					  values%id%[ofs+1], 
					  values%id%[ofs+2],
					  values%id%[ofs+3] );',
	     cofs=cofs/4, id),
	   
           subst(
'	       gl.drawElements(gl.TRIANGLES, %sphereCount%, gl.UNSIGNED_SHORT, 0);
	     }', sphereCount))

      } else {
        if (nc == 1) {
          colors <- rgl.attrib(id, "colors")
          result <- c(result, subst(
'	     gl.disableVertexAttribArray( colLoc );
	     gl.vertexAttrib4f( colLoc, %r%, %g%, %b%, %a% );', 
            r=colors[1], g=colors[2], b=colors[3], a=colors[4]))
        } else {
          result <- c(result, subst(
'	     gl.enableVertexAttribArray( colLoc );
	     gl.vertexAttribPointer(colLoc, 4, gl.FLOAT, false, %stride%, %cofs%);',
            stride, cofs))
        }
    
        if (is_lit && nn > 0) {
          result <- c(result, subst(
'	     gl.enableVertexAttribArray( normLoc%id% );
	     gl.vertexAttribPointer(normLoc%id%, 3, gl.FLOAT, false, %stride%, %nofs%);',
            id, stride, nofs))
        }
    
        if (has_texture || type == "text") {
          result <- c(result, subst(
'	     gl.enableVertexAttribArray( texLoc%id% );
	     gl.vertexAttribPointer(texLoc%id%, 2, gl.FLOAT, false, %stride%, %tofs%);
	     gl.activeTexture(gl.TEXTURE0);
	     gl.bindTexture(gl.TEXTURE_2D, texture%id%);
	     gl.uniform1i( sampler%id%, 0);',
            id, stride, tofs))
        }
      
        if (fixed_quads) {
          result <- c(result, subst(
'	     gl.enableVertexAttribArray( ofsLoc%id% );
	     gl.vertexAttribPointer(ofsLoc%id%, 2, gl.FLOAT, false, %stride%, %ofs%);',
            id, stride, ofs=oofs))
        }
	     
        mode <- switch(type,
          points = "POINTS",
          linestrip = "LINE_STRIP",
          abclines =,
          lines = "LINES",
          sprites =,
          planes =,
          text =,
          quads =,
          surface =,
          triangles = "TRIANGLES",
          stop("unsupported mode") )
      
        switch(type,
          sprites =,
          text = count <- count*6,
          quads = count <- count*6/4,
          surface = {
            dim <- rgl.attrib(id, "dim")
            nx <- dim[1]
            nz <- dim[2]
            count <- (nx - 1)*(nz - 1)*6
          })
    
        if (flags["is_lines"]) {
          lwd <- mat$lwd
          result <- c(result,subst(
'	     gl.lineWidth( %lwd% );',
            lwd))
        }
      
        result <- c(result, subst(
'	     gl.vertexAttribPointer(posLoc,  3, gl.FLOAT, false, %stride%,  0);',
            stride),
      	
          if (is_indexed) subst(
'	     gl.drawElements(gl.%mode%, %count%, gl.UNSIGNED_SHORT, 0);',
              mode, count)
          else
            subst(
'	     gl.drawArrays(gl.%mode%, 0, %count%);',
              mode, count))
      }
    }      
    result
  }
    
  scriptMiddle <- function() {
'	   gl.enable(gl.DEPTH_TEST);
	   gl.depthFunc(gl.LEQUAL);
	   gl.clearDepth(1.0);
	   gl.clearColor(1,1,1,1);
	   var xOffs = yOffs = 0,  drag  = 0;
	   
           function multMV(M, v) {
	     return [M.m11*v[0] + M.m12*v[1] + M.m13*v[2] + M.m14*v[3],
		     M.m21*v[0] + M.m22*v[1] + M.m23*v[2] + M.m24*v[3],
		     M.m31*v[0] + M.m32*v[1] + M.m33*v[2] + M.m34*v[3],
		     M.m41*v[0] + M.m42*v[1] + M.m43*v[2] + M.m44*v[3]];
	   }
	   	   
	   drawScene();

	   function drawScene(){
	     gl.depthMask(true);
	     gl.disable(gl.BLEND);
	     gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
'
  }
  
  drawSubscene <- function(subsceneid) {
    useSubscene3d(subsceneid)  
    subids <- which( ids %in% rgl.ids()$id )
      
    subscene_has_faces <- any(flags[subids,"is_lit"] & !flags[subids,"fixed_quads"])
    subscene_needs_sorting <- any(flags[subids,"depth_sort"])

    bgid <- rgl.ids("background")$id
    if (!length(bgid) || !length(bg <- rgl.attrib(bgid, "colors")))
      bg <- c(1,1,1,1)
      
    result <- c(subst('
	     // ***** subscene %subsceneid% ****',
	subsceneid),

      setViewport(),    
      
      if (length(bgid)) subst(
'	     gl.clearColor(%r%, %g%, %b%, %a%);
	     gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);',
         r=bg[1], g=bg[2], b=bg[3], a=bg[4]),
              
      if (length(subids)) 
        c(setprMatrix(subsceneid),
          setmvMatrix(subsceneid),
      
          if (subscene_has_faces) setnormMatrix(subsceneid),
      
          if (subscene_needs_sorting) setprmvMatrix)) 

    clipplanes <- getClipplanes(subsceneid)
    if (length(clipplanes)) {
      result <- c(result, 
'	     var invMatrix = new CanvasMatrix4(mvMatrix);
	     invMatrix.invert();')
	     
      for (i in subids)
        if (types[i] == "clipplanes")
          result <- c(result, draw(ids[i], types[i], flags[i,], NULL))
    }    
    for (i in subids) 
      if (toplevel[i] && !flags[i,"is_transparent"] && types[i] != "clipplanes")
        result <- c(result, draw(ids[i], types[i], flags[i,], clipplanes))
    
    has_transparency <- any(flags[subids,"is_transparent"])
    if (has_transparency) {
      result <- c(result, doTransparent)
      for (i in subids)
        if (toplevel[i] && flags[i, "is_transparent"] && types[i] != "clipplanes")
          result <- c(result, draw(ids[i], types[i], flags[i,], clipplanes))
    }
    
    subscenes <- rgl.ids(type = "subscene")$id
    for (i in subscenes)
      result <- c(result, drawSubscene(i))
    result
  }
  
  doTransparent <- '
  	     // ***** Transparent objects next ****
	     gl.depthMask(false);
	     gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA,
	                          gl.ONE, gl.ONE);
	     gl.enable(gl.BLEND);
'
	  
  drawEnd <- '
	     gl.flush ();
	   }
'	   
  mouseHandlers <- function() {
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    
    x0 <- y0 <- widths <- heights <- tests <- models <- projections <- character(0)
    
    useid <- function(id, type="model") {
      info <- subsceneInfo(id)
      if (info$embeddings[type] == "inherit")
        useid(info$parent, type)
      else
        id
    }
    
    rects <- function(parent) {
      useSubscene3d(parent)
      info <- subsceneInfo(parent)      
      for (id in rev(info$children))
        rects(id)

      viewport <- par3d("viewport")*c(wfactor, hfactor)
      x0 <<- c(x0, subst("%id%: %x0%", id=parent, x0=viewport[1]))
      y0 <<- c(y0, subst("%id%: %y0%", id=parent, y0=viewport[2]))
      widths <<- c(widths, subst("%id%: %width%", id=parent, width=viewport[3]))
      heights <<- c(heights, subst("%id%: %height%", id=parent, height=viewport[4]))

      tests <<- c(tests, subst(
'         if (%x0% <= coords.x && coords.x <= %x1% && %y0% <= coords.y && coords.y <= %y1%) return(%id%);',
             id=parent, x0=viewport[1], y0=viewport[2], x1=viewport[1]+viewport[3],
             y1=viewport[2]+viewport[4]))
      models <<- c(models, subst("%id%: %model%", id=parent, model=useid(parent, "model")))
      projections <<- c(projections, subst("%id%: %projection%", id=parent, projection=useid(parent, "projection")))
    }

    rootid <- rootSubscene()      
    rects(rootid)
    
    result <- c(
'  	   var vpx0 = {',
  	     inRows(x0, perrow=6, "          "),
'  	     };
	   var vpy0 = {',  	     
  	     inRows(y0, perrow=6, "          "),
'  	     };
	   var vpWidths = {',
	inRows(widths, perrow=6, "         "),
'  	     };
	   var vpHeights = {',
	inRows(heights, perrow=6, "          "),
'  	     };
	   var activeModel = {',
	inRows(models, perrow=6, "         "),
'  	     };
	   var activeProjection = {',
	inRows(projections, perrow=6, "         "),
'  	     };
',
'  	   var whichSubscene = function(coords){',
  	   tests, subst(
'         return(%id%);
       }
',	id=rootid)
    )
  
    handlers <- par3d("mouseMode")
    if (any(notdone <- handlers %in% c("polar", "selecting", "user"))) {
      warning("Mouse mode(s) '", handlers[notdone], "' not supported.  'trackball' used.")
      handlers[notdone] <- "trackball"
    }
    uhandlers <- setdiff(unique(handlers), "none")
    result <- c(result, 
'       var translateCoords = function(subsceneid, coords){
         return {x:coords.x - vpx0[subsceneid], y:coords.y - vpy0[subsceneid]};
       }
       
       var vlen = function(v) {
	     return sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])
	   }
	   
	   var xprod = function(a, b) {
	     return [a[1]*b[2] - a[2]*b[1],
	             a[2]*b[0] - a[0]*b[2],
	             a[0]*b[1] - a[1]*b[0]];
	   }

	   var screenToVector = function(x, y) {
	     var width = vpWidths[activeSubscene];
	     var height = vpHeights[activeSubscene];
	     var radius = max(width, height)/2.0;
	     var cx = width/2.0;
	     var cy = height/2.0;
	     var px = (x-cx)/radius;
	     var py = (y-cy)/radius;
	     var plen = sqrt(px*px+py*py);
	     if (plen > 1.e-6) { 
	       px = px/plen;
	       py = py/plen;
	     }

	     var angle = (SQRT2 - plen)/SQRT2*PI/2;
	     var z = sin(angle);
	     var zlen = sqrt(1.0 - z*z);
	     px = px * zlen;
	     py = py * zlen;
	     return [px, py, z];
	   }

	   var rotBase;
')
    
    for (i in seq_along(uhandlers)) {
      h <- uhandlers[i]
      result <- c(result, switch(h,
        trackball = 
'	   var trackballdown = function(x,y) {
	     rotBase = screenToVector(x, y);
	     saveMat.load(userMatrix[activeModel[activeSubscene]]);
	   }
	   
	   var trackballmove = function(x,y) {
	     var rotCurrent = screenToVector(x,y);
	     var dot = rotBase[0]*rotCurrent[0] + 
	   	       rotBase[1]*rotCurrent[1] + 
	   	       rotBase[2]*rotCurrent[2];
	     var angle = acos( dot/vlen(rotBase)/vlen(rotCurrent) )*180./PI;
	     var axis = xprod(rotBase, rotCurrent);
	     userMatrix[activeModel[activeSubscene]].load(saveMat);
	     userMatrix[activeModel[activeSubscene]].rotate(angle, axis[0], axis[1], axis[2]);
	     drawScene();
	   }
',

        xAxis =,
        yAxis =,
        zAxis = c(
          if (h == "xAxis") 
'	   var xAxis = [1.0, 0.0, 0.0];'
          else if (h == "yAxis")
'	   var yAxis = [0.0, 1.0, 0.0];'
          else
'	   var zAxis = [0.0, 0.0, 1.0];',
          subst(
'
	   var %h%down = function(x,y) {
	     rotBase = screenToVector(x, height/2);
	     saveMat.load(userMatrix[activeModel[activeSubscene]]);
	   }
	   	   
	   var %h%move = function(x,y) {
	     var rotCurrent = screenToVector(x,height/2);
	     var angle = (rotCurrent[0] - rotBase[0])*180/PI;
	     userMatrix[activeModel[activeSubscene]].load(saveMat);
	     var rotMat = new CanvasMatrix4();
	     rotMat.rotate(angle, %h%[0], %h%[1], %h%[2]);
	     userMatrix[activeModel[activeSubscene]].multLeft(rotMat);
	     drawScene();
	   }
	   
',           h)),
      zoom = 
'	   var y0zoom = 0;
	   var zoom0 = 1;
	   var zoomdown = function(x, y) {
	     y0zoom = y;
	     zoom0 = log(zoom[activeProjection[activeSubscene]]);
	   }

	   var zoommove = function(x, y) {
	     zoom[activeProjection[activeSubscene]] = exp(zoom0 + (y-y0zoom)/height);
	     drawScene();
	   }
', 
      fov = 
'	   var y0fov = 0;
	   var fov0 = 1;
	   var fovdown = function(x, y) {
	     y0fov = y;
	     fov0 = fov[activeProjection[activeSubscene]];
	   }

	   var fovmove = function(x, y) {
	     fov[activeProjection[activeSubscene]] = max(1, min(179, fov0 + 180*(y-y0fov)/height));
	     drawScene();
	   }
'))  }
        
    down <- paste(handlers, "down", sep="")
    move <- paste(handlers, "move", sep="")
    none <- handlers == "none"
    down[none] <- "0"
    move[none] <- "0"
    c(result, subst(
'	   var mousedown = [%d1%, %d2%, %d3%];
	   var mousemove = [%m1%, %m2%, %m3%];
',    d1=down[1], d2=down[2], d3=down[3], m1=move[1], m2=move[2], m3=move[3]))
  }
	
  scriptEnd <- 
'	   function relMouseCoords(event){
	     var totalOffsetX = 0;
	     var totalOffsetY = 0;
	     var currentElement = canvas;
	   
	     do{
	       totalOffsetX += currentElement.offsetLeft;
	       totalOffsetY += currentElement.offsetTop;
	     }
	     while(currentElement = currentElement.offsetParent)
	   
	     var canvasX = event.pageX - totalOffsetX;
	     var canvasY = event.pageY - totalOffsetY;
	   
	     return {x:canvasX, y:canvasY}
	   }
	   
	   canvas.onmousedown = function ( ev ){
	     if (!ev.which) // Use w3c defns in preference to MS
	       switch (ev.button) {
	       case 0: ev.which = 1; break;
	       case 1: 
	       case 4: ev.which = 2; break;
	       case 2: ev.which = 3;
	     }
	     drag = ev.which;
	     var f = mousedown[drag-1];
	     if (f) {
	       var coords = relMouseCoords(ev);
	       coords.y = height-coords.y;
	       activeSubscene = whichSubscene(coords);
	       coords = translateCoords(activeSubscene, coords);
	       f(coords.x, coords.y); 
	       ev.preventDefault();
	     }
	   }    

	   canvas.onmouseup = function ( ev ){	
	     drag = 0;
	   }
	   
	   canvas.onmouseout = canvas.onmouseup;

	   canvas.onmousemove = function ( ev ){
	     if ( drag == 0 ) return;
	     var f = mousemove[drag-1];
	     if (f) {
	       var coords = relMouseCoords(ev);
	       coords.y = height - coords.y;
	       coords = translateCoords(activeSubscene, coords);
	       f(coords.x, coords.y);
	     }
	   }

	   var wheelHandler = function(ev) {
	     var del = 1.1;
	     if (ev.shiftKey) del = 1.01;
	     var ds = ((ev.detail || ev.wheelDelta) > 0) ? del : (1 / del);
	     zoom[activeProjection[activeSubscene]] *= ds;
	     drawScene();
	     ev.preventDefault();
	   };
	   canvas.addEventListener("DOMMouseScroll", wheelHandler, false);
	   canvas.addEventListener("mousewheel", wheelHandler, false);

	}
	</script>'

  footer <- function() subst('
	<canvas id="%prefix%canvas" width="1" height="1"></canvas> 
        <p id="%prefix%debug">
	%snapshotimg%
	You must enable Javascript to view this page properly.</p>',
    prefix, snapshotimg)

  getFlags <- function(id, type) {
    mat <- rgl.getmaterial(id=id)
    is_lit <- mat$lit && type %in% c("triangles", "quads", "surface", "planes", 
                                     "spheres", "sprites")
                                     
    is_smooth <- mat$smooth && type %in% c("triangles", "quads", "surface", "planes", 
                                     "spheres")
                                     
    has_texture <- !is.null(mat$texture) && length(rgl.attrib.count(id, "texcoords"))
    
    is_transparent <- any(rgl.attrib(id, "colors")[,"a"] < 1)
    
    depth_sort <- is_transparent && type %in% c("triangles", "quads", "surface",
                                                  "spheres", "sprites", "text")

    sprites_3d <- type == "sprites" && rgl.attrib.count(id, "ids")
    
    is_indexed <- (depth_sort || type %in% c("quads", "surface", "text", "sprites")) && !sprites_3d
    
    fixed_quads <- type %in% c("text", "sprites") && !sprites_3d
    is_lines <- type %in% c("lines", "linestrip", "abclines")
    
    c(is_lit=is_lit, is_smooth=is_smooth, has_texture=has_texture, is_indexed=is_indexed, depth_sort=depth_sort,
         fixed_quads=fixed_quads, is_transparent=is_transparent, is_lines=is_lines,
         sprites_3d=sprites_3d)
  }
  
  knowntypes <- c("points", "linestrip", "lines", "triangles", "quads",
                  "surface", "text", "abclines", "planes", "spheres",
                  "sprites", "clipplanes")
  
  #  Execution starts here!
  
  
  # Do a few checks first
    
  if (!file.exists(dir))
    dir.create(dir)
  if (!file.info(dir)$isdir)
    stop("'", dir, "' is not a directory.")
  
  if (commonParts)
    file.copy(system.file(file.path("WebGL", "CanvasMatrix.js"), package = "rgl"), 
                          file.path(dir, "CanvasMatrix.js"))

  rect <- par3d("windowRect")
  rwidth <- rect[3] - rect[1] + 1
  rheight <- rect[4] - rect[2] + 1
  if (missing(width)) {
    if (missing(height)) {
      wfactor <- hfactor <- 1  # width = wfactor*rwidth, height = hfactor*rheight
    } else 
      wfactor <- hfactor <- height/rheight
  } else {
    if (missing(height)) {
      wfactor <- hfactor <- width/rwidth
    } else {
      wfactor <- width/rwidth;
      hfactor <- height/rheight;
    }
  }
  width <- wfactor*rwidth;
  height <- hfactor*rheight;
      
  if (snapshot) {
    snapshot3d(file.path(dir, paste(prefix, "snapshot.png", sep="")))
    snapshotimg <- subst('<img src="%prefix%snapshot.png" alt="%prefix%snapshot" width=%width%/><br>', prefix, width)
    snapshotimg2 <- gsub('"', '\\\\\\\\"', snapshotimg)
  } else snapshotimg2 <- snapshotimg <- ""
  
  if (!is.null(template)) {
    templatelines <- readLines(template)
    templatelines <- subst(templatelines, rglVersion = packageVersion("rgl"))

    target <- paste("%", prefix, "WebGL%", sep="")
    replace <- grep( target, templatelines, fixed=TRUE)
    if (length(replace) != 1) 
      stop("template ", sQuote(template), " does not contain ", target)
  
    result <- c(templatelines[seq_len(replace-1)], header())
  } else
    result <- header()

  if (NROW(rgl.ids("bboxdeco", subscene = 0))) {
    saveredraw <- par3d(skipRedraw = TRUE)
    temp <- convertBBoxes(rootSubscene())
    on.exit({ rgl.pop(id=temp); par3d(saveredraw) })
  }
    
  ids <- rgl.ids(subscene = 0)
  types <- as.character(ids$type)
  ids <- ids$id
    
  flags <- getFlags(ids[1], types[1])
  flags <- matrix(flags, nrow=length(ids), ncol=length(flags),
                  dimnames = list(ids, names(flags)), byrow=TRUE)
  toplevel <- rep(TRUE, length(ids))
  i <- 0
  while (i < length(ids)) {
    i <- i + 1
    flags[i,] <- getFlags(ids[i], types[i])
    if (flags[i, "sprites_3d"]) {
      subids <- rgl.attrib(ids[i], "ids")
      toplevel[ids %in% subids] <- FALSE
    }  
  }        
  flags <- cbind(flags, toplevel=toplevel)
  
  unknowntypes <- setdiff(types, knowntypes)
  if (length(unknowntypes))
    warning("Object type(s) ", 
      paste("'", unknowntypes, "'", sep="", collapse=", "), " not handled.")

  keep <- types %in% knowntypes
  ids <- ids[keep]
  flags <- flags[keep,,drop=FALSE]
  toplevel <- toplevel[keep]
  types <- types[keep]

  texnums <- -1
  
  scene_has_faces <- any(flags[,"is_lit"] & !flags[,"fixed_quads"])
  scene_needs_sorting <- any(flags[,"depth_sort"])
  
  for (i in seq_along(ids))
    result <- c(result, shaders(ids[i], types[i], flags[i,]))
    
  result <- c(result, scriptheader(), setUser(),
    textureSupport,
    if ("text" %in% types) textSupport,
    if ("spheres" %in% types) sphereSupport())

  for (i in seq_along(ids)) 
    result <- c(result, init(ids[i], types[i], flags[i,]))
   
  result <- c(result, scriptMiddle())
  
  rootid <- rootSubscene()
  result <- c(result, drawSubscene(rootid))
  
  result <- c(result, drawEnd, mouseHandlers(), scriptEnd, footer(),
              if (!is.null(template)) 
              	templatelines[replace + seq_len(length(templatelines)-replace)]
              else
              	subst("<script>%prefix%webGLStart();</script>", prefix = prefix)
             )
              	
  cat(result, file=filename, sep="\n")
  invisible(filename)
}
