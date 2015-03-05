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
    subids <- rgl.ids(c("shapes", "bboxdeco"), subscene=subscene)
    ids <- subids$id
    for (spriteid in ids[subids$type == "sprites"]) {
    	ids <- c(ids, rgl.attrib(spriteid, "ids"))  
    }
    if (id %in% ids) {
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
                       snapshot = TRUE, commonParts = TRUE, reuse = NULL,
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

  getPrefix <- function(id) 
    prefixes$prefix[prefixes$id == id][1]

  shaders <- function(id, type, flags) {
    if (type == "clipplanes" || flags["reuse"]) return(NULL)
    mat <- rgl.getmaterial(id=id)
    is_lit <- flags["is_lit"]
    is_smooth <- flags["is_smooth"]
    has_texture <- flags["has_texture"]
    fixed_quads <- flags["fixed_quads"]
    sprites_3d <- flags["sprites_3d"]
    sprite_3d <- flags["sprite_3d"]
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
      else if (sprite_3d)
'	uniform vec3 uOrig;
	uniform float uSize;
	uniform mat4 usermat;',
	
'	void main(void) {',

      if (clipplanes || (!fixed_quads && !sprite_3d))
'	  vPosition = mvMatrix * vec4(aPos, 1.);',

      if (!fixed_quads && !sprite_3d)
'	  gl_Position = prMatrix * vPosition;',
	  
      if (type == "points") subst(
'	  gl_PointSize = %size%;', size=addDP(mat$size)),

'	  vCol = aCol;',

      if (is_lit && !fixed_quads && !sprite_3d)
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
	  
      if (sprite_3d)
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
  
  if (commonParts) c(
'
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

	var rglClass = function() {
	  this.zoom = new Array();
	  this.FOV  = new Array();
	  this.userMatrix = new Array();
	  this.viewport = new Array();
	  this.listeners = new Array();
	  this.clipplanes = new Array();
	  this.opaque = new Array();
	  this.transparent = new Array();
	  this.subscenes = new Array();

	  this.flags = new Array();
	  this.prog = new Array();
	  this.ofsLoc = new Array();
	  this.origLoc = new Array();
	  this.sizeLoc = new Array();
	  this.usermatLoc = new Array();
	  this.vClipplane = new Array();
	  this.texture = new Array();
	  this.texLoc = new Array();
	  this.sampler = new Array();
	  this.origsize = new Array();
	  this.values = new Array();
	  this.normLoc = new Array();
	  this.clipLoc = new Array();
	  this.centers = new Array();
	  this.f = new Array();
	  this.buf = new Array();
	  this.ibuf = new Array();
	  this.mvMatLoc = new Array();
	  this.prMatLoc = new Array();
	  this.textScaleLoc = new Array();
	  this.normMatLoc = new Array();
	  this.IMVClip = new Array();

	  this.drawFns = new Array();
	  this.clipFns = new Array();

	  this.prMatrix = new CanvasMatrix4();
	  this.mvMatrix = new CanvasMatrix4();
	  this.vp = null;
	  this.prmvMatrix = null;
	  this.origs = null;
	};
	  
	(function() {
	  this.getShader = function( gl, id ){
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
	  this.multMV = function(M, v) {
	     return [M.m11*v[0] + M.m12*v[1] + M.m13*v[2] + M.m14*v[3],
		     M.m21*v[0] + M.m22*v[1] + M.m23*v[2] + M.m24*v[3],
		     M.m31*v[0] + M.m32*v[1] + M.m33*v[2] + M.m34*v[3],
		     M.m41*v[0] + M.m42*v[1] + M.m43*v[2] + M.m44*v[3]];
	  }',
	  paste0(
'	  this.f_', flagnames, ' = ', 2^(seq_along(flagnames)-1), ';'),
'	  this.whichList = function(id) {
	    if (this.flags[id] & this.f_is_subscene)
	      return "subscenes";
	    else if (this.flags[id] & this.f_is_clipplanes)
	      return "clipplanes";
	    else if (this.flags[id] & this.f_is_transparent)
	      return "transparent";
	    else
	      return "opaque"; 
          }
	  this.inSubscene = function(id, subscene) {
	    var thelist = this.whichList(id);
	    return this[thelist][subscene].indexOf(id) > -1;
	  }
          this.addToSubscene = function(id, subscene) {
            var thelist = this.whichList(id);
	    if (this[thelist][subscene].indexOf(id) == -1)
	      this[thelist][subscene].push(id);
	  }
	  this.delFromSubscene = function(id, subscene) {
	    var thelist = this.whichList(id);
	    var i = this[thelist][subscene].indexOf(id);
	    if (i > -1)
	      this[thelist][subscene].splice(i, 1);
	  }	      
    }).call(rglClass.prototype);
'),
  subst(
'
	var %prefix%rgl = new rglClass();
	%prefix%rgl.start = function() {
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
	   var normMatrix = new CanvasMatrix4();
	   var saveMat = new Object();
	   var distance;
	   var posLoc = 0;
	   var colLoc = 1;
', prefix, snapshotimg2, width, height))
  
  setUser <- function() {
    subsceneids <- rgl.ids("subscene", subscene = 0)$id
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    result <- subst(
'       var activeSubscene = %root%;', root=rootSubscene(), prefix)
    
    for (id in subsceneids) {
      useSubscene3d(id)
      info <- subsceneInfo(id)
      result <- c(result, subst(
'	   this.flags[%id%] = %flags%;', id, flags = numericFlags(getSubsceneFlags(id))))
      if (info$embeddings["projection"] != "inherit") {
        useSubscene3d(id)
        result <- c(result, subst(
'	   this.zoom[%id%] = %zoom%;
	   this.FOV[%id%] = %fov%;', id, zoom = par3d("zoom"), fov = max(1, min(179, par3d("FOV")))))
      }
      viewport <- par3d("viewport")*c(wfactor, hfactor)
      result <- c(result, subst(
'	   this.viewport[%id%] = [%v1%, %v2%, %v3%, %v4%];',
      	  id, v1 = viewport[1], v2 = viewport[2], v3 = viewport[3], v4 = viewport[4]))
      if (info$embeddings["model"] != "inherit") {
        result <- c(result, subst(
'	   this.userMatrix[%id%] = new CanvasMatrix4();
	   this.userMatrix[%id%].load([', id),
    inRows(t(par3d("userMatrix")), perrow=4, leadin='	   '),
'		]);')
      }
      
      clipplanes <- getClipplanes(id)
      subids <- which( ids %in% rgl.ids()$id )
      opaque <- ids[subids[!flags[subids,"sprite_3d"] & !flags[subids,"is_transparent"] & types[subids] != "clipplanes"]]
      transparent <- ids[subids[!flags[subids,"sprite_3d"] & flags[subids,"is_transparent"] & types[subids] != "clipplanes"]]
      subscenes <- as.integer(info$children)
      
      result <- c(result, subst(
'	   this.clipplanes[%id%] = [%clipplanes%];
	   this.opaque[%id%] = [%opaque%];
	   this.transparent[%id%] = [%transparent%];
	   this.subscenes[%id%] = [%subscenes%];
',      id, clipplanes = paste(clipplanes, collapse=","),
	opaque = paste(opaque, collapse=","),
	transparent = paste(transparent, collapse=","),
	subscenes = paste(subscenes, collapse=",")))
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
	       %prefix%rgl.drawScene();
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
    # Use -1 as a fake ID of the sphere data          
    if ((-1) %in% prefixes$id) {
      reuse <- TRUE
      thisprefix <- getPrefix(-1)
    } else {
      reuse <- FALSE
      thisprefix <- prefix
      prefixes <<- rbind(prefixes, data.frame(id = -1, prefix = thisprefix, texture = ""))
      x <- subdivision3d(octahedron3d(),2)
      x$vb[4,] <- 1
      r <- sqrt(x$vb[1,]^2 + x$vb[2,]^2 + x$vb[3,]^2)
      values <- t(x$vb[1:3,])/r
    }
    sphereCount <<- 384 # length(x$it)
    sphereStride <<- 12
    c(
'	   // ****** sphere object ******',
      if (!reuse) subst(
'	   this.sphereverts = new Float32Array([
%values%
           ]);
	   this.spherefaces=new Uint16Array([
%faces%
	   ]);', values = inRows(values, perrow=3, '	   '),
	   faces = inRows(t(x$it)-1, perrow=3, '	   ')),
      subst(
'	   var sphereBuf = gl.createBuffer();
	   gl.bindBuffer(gl.ARRAY_BUFFER, sphereBuf);
	   gl.bufferData(gl.ARRAY_BUFFER, %thisprefix%rgl.sphereverts, gl.STATIC_DRAW);
	   var sphereIbuf = gl.createBuffer();
	   gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereIbuf);
	   gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, %thisprefix%rgl.spherefaces, gl.STATIC_DRAW);
',         thisprefix))
}    

  setViewport <- function() 
'	     this.vp = this.viewport[id];
	     gl.viewport(this.vp[0], this.vp[1], this.vp[2], this.vp[3]);
	     gl.scissor(this.vp[0], this.vp[1], this.vp[2], this.vp[3]);'
	     
  setprMatrix <- function(subsceneid) {
    info <- subsceneInfo(subsceneid)
    embedding <- info$embeddings["projection"]
    if (embedding == "replace")
      result <-
'	     this.prMatrix.makeIdentity();'
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
    c(result, subst(
'	     var radius = %radius%;
	     var distance = %distance%;
	     var t = tan(this.FOV[%id%]*PI/360);
	     var near = distance - radius;
	     var far = distance + radius;
	     var hlen = t*near;
	     var aspect = this.vp[2]/this.vp[3];
	     var z = this.zoom[%id%];
	     if (aspect > 1) 
	       this.prMatrix.frustum(-hlen*aspect*z, hlen*aspect*z, 
	                        -hlen*z, hlen*z, near, far);
	     else  
	       this.prMatrix.frustum(-hlen*z, hlen*z, 
	                        -hlen*z/aspect, hlen*z/aspect, 
	                        near, far);',
            prefix, id = subsceneid, radius, distance))
  }

  setmvMatrix <- function(subsceneid) {
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    
    useSubscene3d(subsceneid)
    observer <- par3d("observer")
    
    c('
         this.mvMatrix.makeIdentity();',
      setmodelMatrix(subsceneid),
      subst(
'         this.mvMatrix.translate(%x%, %y%, %z%);',
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
'	     this.mvMatrix.translate( %cx%, %cy%, %cz% );
	     this.mvMatrix.scale( %sx%, %sy%, %sz% );   
	     this.mvMatrix.multRight( %prefix%rgl.userMatrix[%id%] );',
     prefix, id = subsceneid,
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
	     normMatrix.multRight( %prefix%rgl.userMatrix[%id%] );',
         prefix, id = subsceneid,
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
'	     this.prmvMatrix = new CanvasMatrix4( this.mvMatrix );
	     this.prmvMatrix.multRight( this.prMatrix );'

  init <- function(id, type, flags) {
    is_indexed <- flags["is_indexed"]
    mat <- rgl.getmaterial(id=id)
    is_lit <- flags["is_lit"]
    has_texture <- flags["has_texture"]
    fixed_quads <- flags["fixed_quads"]
    depth_sort <- flags["depth_sort"]
    sprites_3d <- flags["sprites_3d"]
    sprite_3d <- flags["sprite_3d"]
    is_clipplanes <- type == "clipplanes"
    clipplanes <- countClipplanes(id)
    thisprefix <- getPrefix(id)
    
    result <- subst(
'
	   // ****** %type% object %id% ******
	   this.flags[%id%] = %flags%;', type, id, flags = numericFlags(flags))
    if (!sprites_3d && !is_clipplanes)
      result <- c(result, subst(
'	   this.prog[%id%]  = gl.createProgram();
	   gl.attachShader(this.prog[%id%], this.getShader( gl, "%thisprefix%vshader%id%" ));
	   gl.attachShader(this.prog[%id%], this.getShader( gl, "%thisprefix%fshader%id%" ));
	   //  Force aPos to location 0, aCol to location 1 
	   gl.bindAttribLocation(this.prog[%id%], 0, "aPos");
	   gl.bindAttribLocation(this.prog[%id%], 1, "aCol");
	   gl.linkProgram(this.prog[%id%]);', thisprefix, id))
   
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
'	   this.vClipplane[%id%]=[', id),
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
'	   var texinfo = drawTextToCanvas(texts, %cex%);',
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
'	   this.ofsLoc[%id%] = gl.getAttribLocation(this.prog[%id%], "aOfs");',
          id))
          
    if (sprite_3d) result <- c(result, subst(
'	   this.origLoc[%id%] = gl.getUniformLocation(this.prog[%id%], "uOrig");
	   this.sizeLoc[%id%] = gl.getUniformLocation(this.prog[%id%], "uSize");
	   this.usermatLoc[%id%] = gl.getUniformLocation(this.prog[%id%], "usermat");',
	  id))

    if (has_texture) {
        tofs <- NCOL(values)
        if (type != "sprites")
            texcoords <- rgl.attrib(id, "texcoords")
        if (!sprites_3d)
            values <- cbind(values, texcoords)
        if (mat$texture %in% prefixes$texture) {
            i <- which(mat$texture == prefixes$texture)[1]
            texprefix <- prefixes$prefix[i]
            texid <- prefixes$id[i]
        } else {
            texprefix <- prefix
            texid <- id
            file.copy(mat$texture, file.path(dir, paste(texprefix, "texture", texid, ".png", sep="")))
        }
        i <- which(prefixes$id == id & prefixes$prefix == prefix)      
        prefixes$texture[i] <<- mat$texture
        i <- which(mat$texture == prefixes$texture & prefix == prefixes$prefix)
        load_texture <- length(i) < 2 # first time loaded in this scene
        if (!load_texture)
            texid <- prefixes$id[i[1]]
    } else
        load_texture <- FALSE
    
    if (load_texture || type == "text") result <- c(result, subst(
'	   this.texture[%id%] = gl.createTexture();
	   this.texLoc[%id%] = gl.getAttribLocation(this.prog[%id%], "aTexcoord");
	   this.sampler[%id%] = gl.getUniformLocation(this.prog[%id%],"uSampler");',
	  id))

    if (load_texture)	  
        result <- c(result, subst(
'	   loadImageToTexture("%texprefix%texture%texid%.png", this.texture[%id%]);',
          id, texprefix, texid))
    else if (has_texture)  # just reuse the existing texture
        result <- c(result, subst(
'	   this.texture[%id%] = this.texture[%texid%];',
                      id, texid))              
    
    if (type == "text") result <- c(result, subst(
'	   handleLoadedTexture(this.texture[%id%], document.getElementById("%prefix%textureCanvas"));',
        prefix, id))
      
    stride <- NCOL(values)

    result <- c(result,
      if (sprites_3d) subst(
'	   this.origsize[%id%]=new Float32Array([', id)
      else if (!flags["reuse"])
'	   var v=new Float32Array([',
      if (!flags["reuse"]) 
        c(inRows(values, stride, leadin='	   '),
'	   ]);'),

      if (sprites_3d) c(subst(
'	   this.userMatrix[%id%] = new Float32Array([', id),
        inRows(rgl.attrib(id, "usermatrix"), 4, leadin='	   '),
'	   ]);'),
        
      if (type == "text" && !flags["reuse"]) subst(
'	   for (var i=0; i<%len%; i++) 
	     for (var j=0; j<4; j++) {
	         var ind = %stride%*(4*i + j) + %tofs%;
	         v[ind+2] = 2*(v[ind]-v[ind+2])*texinfo.widths[i];
	         v[ind+3] = 2*(v[ind+1]-v[ind+3])*texinfo.textHeight;
	         v[ind] *= texinfo.widths[i]/texinfo.canvasX;
	         v[ind+1] = 1.0-(texinfo.offset + i*texinfo.skip 
	           - v[ind+1]*texinfo.textHeight)/texinfo.canvasY;
	     }', len=length(texts), stride, tofs),
	     
      if (!sprites_3d && !flags["reuse"]) subst(
'	   this.values[%id%] = v;', 
                  id),
	   
      if (is_lit && !fixed_quads && !sprites_3d) subst(
'	   this.normLoc[%id%] = gl.getAttribLocation(this.prog[%id%], "aNorm");', 
        id),
      if (clipplanes && !sprites_3d) c(subst(
'	   this.clipLoc[%id%] = new Array();', id),
      	subst(paste0(
'	   this.clipLoc[%id%][', seq_len(clipplanes)-1, '] = gl.getUniformLocation(this.prog[%id%], "vClipplane', seq_len(clipplanes), '");'),
           id))
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
'	   this.centers[%id%] = new Float32Array([', id),
        inRows(rgl.attrib(id, "centers"), 3, leadin='	   '),
'	   ]);')

        fname <- subst("this.f[%id%]", id)
        var <- ""
        drawtype <- "DYNAMIC_DRAW"
      } else {
        fname <- "f"
        var <- "var "
        drawtype <- "STATIC_DRAW"
      }
      
      result <- c(result, subst(
'	   %var%%fname%=new Uint16Array([', 
          var, fname),
	inRows(c(f), frowsize, leadin='	   '),
'	   ]);')
    }
    result <- c(result,
      if (type != "spheres" && !sprites_3d) subst(
'	   this.buf[%id%] = gl.createBuffer();
	   gl.bindBuffer(gl.ARRAY_BUFFER, this.buf[%id%]);
	   gl.bufferData(gl.ARRAY_BUFFER, %thisprefix%rgl.values[%id%], gl.STATIC_DRAW);',
   		thisprefix, id),
      if (is_indexed && type != "spheres" && !sprites_3d) subst(
'	   this.ibuf[%id%] = gl.createBuffer();
	   gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.ibuf[%id%]);
	   gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, %fname%, gl.%drawtype%);',
   		id, fname, drawtype),
      if (!sprites_3d && !is_clipplanes) subst(
'	   this.mvMatLoc[%id%] = gl.getUniformLocation(this.prog[%id%],"mvMatrix");
	   this.prMatLoc[%id%] = gl.getUniformLocation(this.prog[%id%],"prMatrix");',
   		  id),
      if (type == "text") subst(
'	   this.textScaleLoc[%id%] = gl.getUniformLocation(this.prog[%id%],"textScale");',
		  id),
      if (is_lit && !sprites_3d) subst(
'	   this.normMatLoc[%id%] = gl.getUniformLocation(this.prog[%id%],"normMatrix");',
		  id)
   		 ) 
    c(result, '')
  }
  
  draw <- function(id, type, flags) {
    mat <- rgl.getmaterial(id=id)
    is_lit <- flags["is_lit"]
    is_indexed <- flags["is_indexed"]
    depth_sort <- flags["depth_sort"]
    has_texture <- flags["has_texture"]
    fixed_quads <- flags["fixed_quads"]
    is_transparent <- flags["is_transparent"]
    sprites_3d <- flags["sprites_3d"]
    sprite_3d <- flags["sprite_3d"]
    thisprefix <- getPrefix(id)
    
    result <- subst(
'
       // ****** %type% object %id% *******
       this.drawFns[%id%] = function(id, clipplanes) {',
       type, id)
  
    if (type == "clipplanes") {
      count <- rgl.attrib.count(id, "offsets")
      result <- c(result, subst(
'	     this.IMVClip[id] = new Array();', id))       	
      for (i in seq_len(count) - 1) {
        result <- c(result, subst(
'	     this.IMVClip[id][%i%] = this.multMV(this.invMatrix, this.vClipplane[id]%slice%);',
	id, i, slice = subst(".slice(%first%, %stop%)", first = 4*i, stop = 4*(i+1))))
      }
      result <- c(result, subst(
'       }
       this.clipFns[%id%] = function(id, objid, count) {', id))
      count <- rgl.attrib.count(id, "offsets")
      result <- c(result, 
      	    if (count == 1)
'	     gl.uniform4fv(this.clipLoc[objid][count], this.IMVClip[id][0]);
	     return(count + 1);
	   }'
	    else if (count > 1)
      	    	subst(
'	     for (var i=0; i<%count%; i++)   
	       gl.uniform4fv(this.clipLoc[objid][count + i], this.IMVClip[id][i]);
	     return(count + %count%);
       }', id, count))
      return(result)
    }

    if (sprites_3d) {
      norigs <- rgl.attrib.count(id, "vertices")
      result <- c(result, subst(
'	     this.origs = this.origsize[id];
	     this.usermat = this.userMatrix[id];
	     for (iOrig=0; iOrig < %norigs%; iOrig++) {',
        id, norigs))
      spriteids <- rgl.attrib(id, "ids")
      for (i in seq_along(spriteids)) 
        result <- c(result, subst(
'	       this.drawFns[%spriteid%].call(this, %spriteid%, clipplanes);',
	  spriteid = spriteids[i]))
      result <- c(result, 
'	     }')
    } else {
      result <- c(result, subst(	     
'	     gl.useProgram(this.prog[id]);', id),
       
        if (sprite_3d) subst(
'	     gl.uniform3f(this.origLoc[id], this.origs[4*iOrig], 
	                                this.origs[4*iOrig+1],
	                                this.origs[4*iOrig+2]);
	     gl.uniform1f(this.sizeLoc[id], this.origs[4*iOrig+3]);
	     gl.uniformMatrix4fv(this.usermatLoc[id], false, this.usermat);',
	  id),
	  
        if (type == "spheres") 
'	     gl.bindBuffer(gl.ARRAY_BUFFER, sphereBuf);'
        else subst(
'	     gl.bindBuffer(gl.ARRAY_BUFFER, this.buf[id]);',
         id),
       
        if (is_indexed && type != "spheres") subst(    
'	     gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.ibuf[id]);', id)
        else if (type == "spheres")
'	     gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereIbuf);',

        subst(
'	     gl.uniformMatrix4fv( this.prMatLoc[id], false, new Float32Array(this.prMatrix.getAsArray()) );
	     gl.uniformMatrix4fv( this.mvMatLoc[id], false, new Float32Array(this.mvMatrix.getAsArray()) );',
         id))
         
      result <- c(result, 
'	     var clipcheck = 0;
	     for (var i=0; i < clipplanes.length; i++)
	       clipcheck = this.clipFns[clipplanes[i]].call(this, clipplanes[i], id, clipcheck);')           
      if (is_lit && !sprite_3d)
        result <- c(result, subst(
'	     gl.uniformMatrix4fv( this.normMatLoc[id], false, new Float32Array(normMatrix.getAsArray()) );',
          id))
          
      if (is_lit && sprite_3d)
        result <- c(result, subst(
'	     gl.uniformMatrix4fv( this.normMatLoc[id], false, this.usermat);',
          id))
	  
      if (type == "text") 
        result <- c(result, 
'	     gl.uniform2f( this.textScaleLoc[id], 0.75/this.vp[2], 0.75/this.vp[3]);')	

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
	       var z = this.prmvMatrix.m13*this.centers[id][3*i] 
	             + this.prmvMatrix.m23*this.centers[id][3*i+1]
	             + this.prmvMatrix.m33*this.centers[id][3*i+2]
	             + this.prmvMatrix.m43;
	       var w = this.prmvMatrix.m14*this.centers[id][3*i] 
	             + this.prmvMatrix.m24*this.centers[id][3*i+1]
	             + this.prmvMatrix.m34*this.centers[id][3*i+2]
	             + this.prmvMatrix.m44;
	       depths[i] = z/w;
	       faces[i] = i;
	     }
	     var depthsort = function(i,j) { return depths[j] - depths[i] }
	     faces.sort(depthsort);',
           nfaces, id),
           if (type != "spheres") subst(
'	     var f = new Uint16Array(this.f[id].length);
	     for (var i=0; i<%nfaces%; i++) {
	       for (var j=0; j<%frowsize%; j++) {
	         f[%frowsize%*i + j] = this.f[id][%frowsize%*faces[i] + j];
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
	     gl.enableVertexAttribArray(this.normLoc[id] );
	     gl.vertexAttribPointer(this.normLoc[id],  3, gl.FLOAT, false, %sphereStride%,  0);
	     gl.disableVertexAttribArray( colLoc );
	     var sphereNorm = new CanvasMatrix4();
	     sphereNorm.scale(%sx%, %sy%, %sz%);
	     sphereNorm.multRight(normMatrix);
	     gl.uniformMatrix4fv( this.normMatLoc[id], false, new Float32Array(sphereNorm.getAsArray()) );', 
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
	       var scale = %thisprefix%rgl.values[id][ofs];
	       sphereMV.scale(%sx%*scale, %sy%*scale, %sz%*scale);
	       sphereMV.translate(%thisprefix%rgl.values[id][baseofs], 
	       			  %thisprefix%rgl.values[id][baseofs+1], 
	       			  %thisprefix%rgl.values[id][baseofs+2]);
	       sphereMV.multRight(this.mvMatrix);
	       gl.uniformMatrix4fv( this.mvMatLoc[id], false, new Float32Array(sphereMV.getAsArray()) );',
	     radofs=radofs/4, stride=stride/4, id, sx, sy, sz, thisprefix),
	 
	   if (nc > 1) subst(
'	       ofs = baseofs + %cofs%;       
	       gl.vertexAttrib4f( colLoc, %thisprefix%rgl.values[id][ofs], 
					  %thisprefix%rgl.values[id][ofs+1], 
					  %thisprefix%rgl.values[id][ofs+2],
					  %thisprefix%rgl.values[id][ofs+3] );',
	     cofs=cofs/4, id, thisprefix),
	   
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
'	     gl.enableVertexAttribArray( this.normLoc[id] );
	     gl.vertexAttribPointer(this.normLoc[id], 3, gl.FLOAT, false, %stride%, %nofs%);',
            id, stride, nofs))
        }
    
        if (has_texture || type == "text") {
          result <- c(result, subst(
'	     gl.enableVertexAttribArray( this.texLoc[id] );
	     gl.vertexAttribPointer(this.texLoc[id], 2, gl.FLOAT, false, %stride%, %tofs%);
	     gl.activeTexture(gl.TEXTURE0);
	     gl.bindTexture(gl.TEXTURE_2D, this.texture[id]);
	     gl.uniform1i( this.sampler[id], 0);',
            id, stride, tofs))
        }
      
        if (fixed_quads) {
          result <- c(result, subst(
'	     gl.enableVertexAttribArray( this.ofsLoc[id] );
	     gl.vertexAttribPointer(this.ofsLoc[id], 2, gl.FLOAT, false, %stride%, %ofs%);',
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
    result <- c(result,
'       }')
    result
  }
    
  scriptMiddle <- function() {
    rootid <- rootSubscene()
    subst(
'	   gl.enable(gl.DEPTH_TEST);
	   gl.depthFunc(gl.LEQUAL);
	   gl.clearDepth(1.0);
	   gl.clearColor(1,1,1,1);
	   var drag  = 0;
	   
	   this.drawScene = function() {
	     gl.depthMask(true);
	     gl.disable(gl.BLEND);
	     gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
	     this.drawFns[%rootid%].call(this, %rootid%)
	     gl.flush ();
	   }
', rootid)
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
       // ***** subscene %subsceneid% ****
       this.drawFns[%subsceneid%] = function(id) {',
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
      
          if (subscene_needs_sorting) setprmvMatrix), 

'	     var clipids = this.clipplanes[id];
	     if (clipids.length > 0) {
	       this.invMatrix = new CanvasMatrix4(this.mvMatrix);
	       this.invMatrix.invert();
	       for (var i = 0; i < this.clipplanes[id].length; i++) 
	         this.drawFns[clipids[i]].call(this, clipids[i]);
	     }
	     var subids = this.opaque[id];
	     for (var i = 0; i < subids.length; i++) 
	       this.drawFns[subids[i]].call(this, subids[i], clipids);
	     subids = this.transparent[id];
	     if (subids.length > 0) {
	       gl.depthMask(false);
	       gl.blendFuncSeparate(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA,
	                          gl.ONE, gl.ONE);
	       gl.enable(gl.BLEND);
	       for (var i = 0; i < subids.length; i++) 
	         this.drawFns[subids[i]].call(this, subids[i], clipids);
	     }
	     subids = this.subscenes[id];
	     for (var i = 0; i < subids.length; i++)
	       this.drawFns[subids[i]].call(this, subids[i]);
      }')
    result
  }
	  
  drawEnd <- '
	   this.drawScene();
'	   
  mouseHandlers <- function() {
    save <- currentSubscene3d()
    on.exit(useSubscene3d(save))
    
    x0 <- y0 <- widths <- heights <- tests <- models <- 
            projections <- listeners <- character(0)
    
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
      l <- par3d("listeners", subscene=parent)
      listeners <<- c(listeners, subst("%id%: [ %ids% ]", id = parent, 
                                       ids = paste(unique(l), collapse=",")))
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
	inRows(projections, perrow=6, "         "), subst(
'  	     };
	   %prefix%rgl.listeners = {', prefix),
        inRows(listeners, perrow=2, "         "),
'  	     };
',
'  	   var whichSubscene = function(coords){',
  	   tests, subst(
'         return(%id%);
       }
',	id=rootid)
    )
  
    handlers <- par3d("mouseMode")
    if (any(notdone <- handlers %in% c("polar", "selecting"))) {
      warning("Mouse mode(s) '", handlers[notdone], "' not supported.  'trackball' used.")
      handlers[notdone] <- "trackball"
    }

    # User handlers are different than others, so do them first
    for (i in which(handlers == "user")) {
      handlers[i] <- paste0("user", i)
      handlerfns <- rgl.getMouseCallbacks(i)
      actions <- c("down", "move", "end")
      defaults <- c("trackball", "zoom", "fov")
      for (j in 1:3) 
        if (!is.null(handlerfns[[j]])) {
          fn <- attr(handlerfns[[j]], "javascript")
          if (!is.null(fn)) {
            result <- c(result, subst(
'           var %handler%%action% = %fn%', 
              handler = handlers[i], action = actions[j], fn = fn))
          } else if (!is.null(name <- attr(handlerfns[[j]], "jsName"))) {
            result <- c(result, subst(
'           var %handler%%action% = function(x, y) {
             %javascript%(activeSubscene%args%)
	   }', handler = handlers[i], action = actions[j], javascript = name,
                          args = if (j < 3) ", x, y" else ""))
          } else {                  
            warning("No \"javascript\" or \"jsName\" attribute found on user handler.  Default used instead.")
            handlers[i] <- defaults[i]
          }
        }
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
        trackball = subst(
'	   var trackballdown = function(x,y) {
	     rotBase = screenToVector(x, y);
	     var l = %prefix%rgl.listeners[activeModel[activeSubscene]];
	     saveMat = new Object();
	     for (var i = 0; i < l.length; i++) 
	       saveMat[l[i]] = new CanvasMatrix4(%prefix%rgl.userMatrix[l[i]]);
	   }
	   
	   var trackballmove = function(x,y) {
	     var rotCurrent = screenToVector(x,y);
	     var dot = rotBase[0]*rotCurrent[0] + 
	   	       rotBase[1]*rotCurrent[1] + 
	   	       rotBase[2]*rotCurrent[2];
	     var angle = acos( dot/vlen(rotBase)/vlen(rotCurrent) )*180./PI;
	     var axis = xprod(rotBase, rotCurrent);
	     var l = %prefix%rgl.listeners[activeModel[activeSubscene]];
	     for (i = 0; i < l.length; i++) {
	       %prefix%rgl.userMatrix[l[i]].load(saveMat[l[i]]);
	       %prefix%rgl.userMatrix[l[i]].rotate(angle, axis[0], axis[1], axis[2]);
	     }
	     %prefix%rgl.drawScene();
	   }
	   var trackballend = 0;
', prefix),

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
	     var l = %prefix%rgl.listeners[activeModel[activeSubscene]];
	     saveMat = new Object();
	     for (var i = 0; i < l.length; i++) 
	     saveMat[l[i]] = new CanvasMatrix4(%prefix%rgl.userMatrix[l[i]]);
	   }
	   	   
	   var %h%move = function(x,y) {
	     var rotCurrent = screenToVector(x,height/2);
	     var angle = (rotCurrent[0] - rotBase[0])*180/PI;
	     var rotMat = new CanvasMatrix4();
	     rotMat.rotate(angle, %h%[0], %h%[1], %h%[2]);
	     var l = %prefix%rgl.listeners[activeModel[activeSubscene]];
	     for (i = 0; i < l.length; i++) {
	       %prefix%rgl.userMatrix[l[i]].load(saveMat[l[i]]);
	       %prefix%rgl.userMatrix[l[i]].multLeft(rotMat);
	     }
	     %prefix%rgl.drawScene();
	   }
	   
	   var %h%end = 0;
	   
',           h, prefix)),
      zoom = subst(
'	   var y0zoom = 0;
	   var zoom0 = 0;
	   var zoomdown = function(x, y) {
	     y0zoom = y;
	     zoom0 = new Object();
	     l = %prefix%rgl.listeners[activeProjection[activeSubscene]];
	     for (i = 0; i < l.length; i++)
	     zoom0[l[i]] = log(%prefix%rgl.zoom[l[i]]);
	   }

	   var zoommove = function(x, y) {
	     l = %prefix%rgl.listeners[activeProjection[activeSubscene]];
	     for (i = 0; i < l.length; i++)
	       %prefix%rgl.zoom[l[i]] = exp(zoom0[l[i]] + (y-y0zoom)/height);
	     %prefix%rgl.drawScene();
	   }
	   
	   var zoomend = 0;
',      prefix),
      fov = subst(
'	   var y0fov = 0;
	   var fov0 = 0;
	   var fovdown = function(x, y) {
	     y0fov = y;
	     fov0 = new Object();
	     l = %prefix%rgl.listeners[activeProjection[activeSubscene]];
	     for (i = 0; i < l.length; i++)
	       fov0[l[i]] = %prefix%rgl.FOV[l[i]];
	   }

	   var fovmove = function(x, y) {
	     l = %prefix%rgl.listeners[activeProjection[activeSubscene]];
	     for (i = 0; i < l.length; i++)
	       %prefix%rgl.FOV[l[i]] = max(1, min(179, fov0[l[i]] + 180*(y-y0fov)/height));
	     %prefix%rgl.drawScene();
	   }
	   
	   var fovend = 0;
',      prefix)))  }
        
    down <- paste(handlers, "down", sep="")
    move <- paste(handlers, "move", sep="")
    end <-  paste(handlers, "end", sep="")
    none <- handlers == "none"
    down[none] <- "0"
    move[none] <- "0"
    end[none] <- "0"
    c(result, subst(
'	   var mousedown = [%d1%, %d2%, %d3%];
	   var mousemove = [%m1%, %m2%, %m3%];
	   var mouseend = [%e1%, %e2%, %e3%];
',    d1=down[1], d2=down[2], d3=down[3], m1=move[1], m2=move[2], m3=move[3],
      e1=end[1],  e2=end[2],  e3=end[3]))
  }
	
  scriptEnd <- subst(
'	   function relMouseCoords(event){
	     var totalOffsetX = 0;
	     var totalOffsetY = 0;
	     var currentElement = canvas;
	   
	     do{
	       totalOffsetX += currentElement.offsetLeft;
	       totalOffsetY += currentElement.offsetTop;
	       currentElement = currentElement.offsetParent;
	     }
	     while(currentElement)
	   
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
	     if ( drag == 0 ) return;
	     var f = mouseend[drag-1];
	     if (f) 
	       f();
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
	     l = %prefix%rgl.listeners[activeProjection[activeSubscene]];
	     for (i = 0; i < l.length; i++)
	       %prefix%rgl.zoom[l[i]] *= ds;
	     %prefix%rgl.drawScene();
	     ev.preventDefault();
	   };
	   canvas.addEventListener("DOMMouseScroll", wheelHandler, false);
	   canvas.addEventListener("mousewheel", wheelHandler, false);

	}
	</script>', prefix)

  footer <- function() subst('
	<canvas id="%prefix%canvas" class="rglWebGL" width="1" height="1"></canvas> 
	<p id="%prefix%debug">
	%snapshotimg%
	You must enable Javascript to view this page properly.</p>',
    prefix, snapshotimg)

  flagnames <- c("is_lit", "is_smooth", "has_texture", "is_indexed", 
		 "depth_sort", "fixed_quads", "is_transparent", 
		 "is_lines", "sprites_3d", "sprite_3d", 
		 "is_subscene", "is_clipplanes", "reuse")
		 
  getFlags <- function(id, type) {    
    if (type == "subscene")
      return(getSubsceneFlags(id))
      
    result <- structure(rep(FALSE, length(flagnames)), names = flagnames)
    if (type == "clipplanes") {
      result["is_clipplanes"] <- TRUE
      return(result)
    }
    
    mat <- rgl.getmaterial(id=id)
    result["is_lit"] <- mat$lit && type %in% c("triangles", "quads", "surface", "planes", 
                                     "spheres", "sprites")
                                     
    result["is_smooth"] <- mat$smooth && type %in% c("triangles", "quads", "surface", "planes", 
                                     "spheres")
                                     
    result["has_texture"] <- !is.null(mat$texture) && length(rgl.attrib.count(id, "texcoords"))
    
    result["is_transparent"] <- is_transparent <- any(rgl.attrib(id, "colors")[,"a"] < 1)
    
    result["depth_sort"] <- depth_sort <- is_transparent && type %in% c("triangles", "quads", "surface",
                                                  "spheres", "sprites", "text")

    result["sprites_3d"] <- sprites_3d <- type == "sprites" && rgl.attrib.count(id, "ids")
    
    result["is_indexed"] <- (depth_sort || type %in% c("quads", "surface", "text", "sprites")) && !sprites_3d
    
    result["fixed_quads"] <- type %in% c("text", "sprites") && !sprites_3d
    result["is_lines"]    <- type %in% c("lines", "linestrip", "abclines")
    
    result
  }
  
  getSubsceneFlags <- function(id) {
     result <- structure(rep(FALSE, length(flagnames)), names = flagnames)
     result["is_subscene"] <- TRUE
     subs <- rgl.ids(subscene = id)
     for (i in seq_len(nrow(subs))) 
	result <- result | getFlags(subs[i, "id"], subs[i, "type"])
     return(result)
  }
  
  numericFlags <- function(flags) {
    if (is.matrix(flags))
      n <- ncol(flags)
    else
      n <- length(flags)
    flags %*% 2^(seq_len(n)-1)
  }
  
  flagConstants <- 

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
    file.copy(system.file(file.path("doc", "CanvasMatrix.js"), package = "rgl"), 
                          file.path(dir, "CanvasMatrix.js"))

  if (is.null(reuse) || isTRUE(reuse)) 
    prefixes <- data.frame(id = integer(), prefix = character(), texture = character())
  else {
    if (!is.data.frame(reuse) || !all(c("id", "prefix") %in% names(reuse)))
      stop(dQuote("reuse"), " should be a dataframe with columns ", dQuote("id"), " and ", dQuote("prefix"))
    prefixes <- reuse[,c("id", "prefix", "texture")]
  }
  
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
    templatelines <- subst(templatelines, rglVersion = packageVersion("rgl"), prefix = prefix)

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
  flags <- matrix(FALSE, nrow = length(ids), ncol=length(flagnames), 
		  dimnames = list(NULL, flagnames))

  i <- 0
  while (i < length(ids)) {
    i <- i + 1
    flags[i,] <- getFlags(ids[i], types[i])
    if (flags[i, "sprites_3d"]) {
      subids <- rgl.attrib(ids[i], "ids")
      flags[ids %in% subids, "sprite_3d"] <- TRUE
    } 
  }   
  flags[ids %in% prefixes$id, "reuse"] <- TRUE
  
  unknowntypes <- setdiff(types, knowntypes)
  if (length(unknowntypes))
    warning("Object type(s) ", 
      paste("'", unknowntypes, "'", sep="", collapse=", "), " not handled.")

  keep <- types %in% knowntypes
  ids <- ids[keep]
  flags <- flags[keep,,drop=FALSE]
  types <- types[keep]

  if (length(ids))
    prefixes <- rbind(prefixes, data.frame(id = ids, 
                      prefix = prefix, texture = ""))

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
  
  for (i in seq_along(ids))
    result <- c(result, draw(ids[i], types[i], flags[i,]))
  
  subscenes <- rgl.ids("subscene", subscene = 0)$id
  for (i in seq_along(subscenes))
    result <- c(result, drawSubscene(subscenes[i]))

  result <- c(result, drawEnd, mouseHandlers(), scriptEnd, footer(),
              if (!is.null(template)) 
              	templatelines[replace + seq_len(length(templatelines)-replace)]
              else
              	subst("<script>%prefix%rgl.start();</script>", prefix = prefix)
             )
              	
  cat(result, file=filename, sep="\n")
  if (!is.null(reuse)) {
    prefixes <- prefixes[!duplicated(prefixes$id),]
    attr(filename, "reuse") <- prefixes
  }  
  invisible(filename)
}
