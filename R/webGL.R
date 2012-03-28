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

writeWebGL <- function(dir="webGL", filename=file.path(dir, "index.html"), 
                       snapshot = TRUE, font="Arial",
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
  
  htmlheader <- function() c(
'	<html><head>
	<TITLE>RGL model</TITLE>

	<script src="CanvasMatrix.js" type="text/javascript"></script>
	<canvas id="textureCanvas" style="display: none;" width="256" height="256">',
        snapshotimg,
'	Your browser does not support the HTML5 canvas element.</canvas>
')

  shaders <- function(id, type) {
    mat <- rgl.getmaterial(id = id)
    has_faces <- type %in% c("triangles", "quads", "surface", "planes", "spheres")
    has_texture <- !is.null(mat$texture) && length(rgl.attrib.count(id, "texcoords"))
    if (has_texture)
      texture_format <- mat$textype;

    if (has_faces) {
      lights <- rgl.ids("lights")
      light <- lights$id[1]
      if (is.na(light)) {
        lights <- matrix(0, nrow=3, ncol=4)
        lightdir <- c(0, 0, 1)
      } else {
        lights <- rgl.attrib(light, "colors")
        lAmbient <- lights[1,]
        lDiffuse <- lights[2,]
        lSpecular <- lights[3,]
        lightdir <- rgl.attrib(light, "vertices")[1:3]
      }
      lightdir <- lightdir/sqrt(sum(lightdir^2))
    }
    vertex <- c(subst(
'	<!-- ****** %type% object %id% ****** -->
	<script id="vshader%id%" type="x-shader/x-vertex">', 
      type=type, id=id),
	
'	attribute vec3 aPos;
	attribute vec4 aCol;
	uniform mat4 mvMatrix;
	uniform mat4 prMatrix;
	varying vec4 vDiffuse;',
	
      if (has_faces) subst(
'	attribute vec3 aNorm;
	uniform mat4 normMatrix;
	varying vec3 vNormal;
	const vec3 diffuse = %diffuse%; // light only',
	  diffuse=vec2vec3(lDiffuse)),
	  
      if (has_texture || type == "text")
'	attribute vec2 aTexcoord;
	varying vec2 vTexcoord;',

      if (type == "text")
'	attribute vec2 aTextOfs;
	void main(void) {'
      else
'	void main(void) {
	  gl_Position = prMatrix * mvMatrix * vec4(aPos, 1.);',
	  
      if (type == "points") subst(
'	  gl_PointSize = %size%;', size=addDP(mat$size)),

      if (has_faces)	  
'	  vDiffuse = vec4(aCol.rgb * diffuse, aCol.a);
	  vNormal = normalize((normMatrix * vec4(aNorm, 1.)).xyz);'
      else 
'	  vDiffuse = aCol;',

      if (has_texture || type == "text")
'	  vTexcoord = aTexcoord;',

      if (type == "text") 
'	  vec4 pos = prMatrix * mvMatrix * vec4(aPos, 1.);
	  pos = pos/pos.w;
	  gl_Position = pos + vec4(aTextOfs, 0.,0.);',
	  
'	}
	</script>
')
    eye <- c(0,0,1)
    fragment <- c(subst(
'	<script id="fshader%id%" type="x-shader/x-fragment"> 
	#ifdef GL_ES
	precision highp float;
	#endif
	varying vec4 vDiffuse; // carries alpha',
      id),
      
      if (has_texture || type == "text") 
'	varying vec2 vTexcoord;
	uniform sampler2D uSampler;',
	     
      if (has_faces) subst(
'	const vec3 ambient_plus_emission = %AplusE%;
	const vec3 specular = %specular%;// light*material
	const float shininess = %shininess%;
	const vec3 lightDir = %lightdir%;
	const vec3 halfVec = %halfVec%;
	const vec3 eye = %eye%;
	varying vec3 vNormal;',
	  AplusE = vec2vec3(col2rgba(mat$ambient)*lAmbient + col2rgba(mat$emission)),
	  specular = vec2vec3(col2rgba(mat$specular)*lSpecular), 
	  shininess = addDP(mat$shininess),
	  lightdir = vec2vec3(lightdir),
	  halfVec = vec2vec3(normalize(lightdir + eye)),
	  eye = vec2vec3(eye)),
	
'	void main(void) {
          vec4 diffuse;',

      if (has_faces) 
'	  vec3 col = ambient_plus_emission;
	  vec3 n = normalize(vNormal);
	  n = -faceforward(n, n, eye);
	  float nDotL = dot(n, lightDir);
	  col = col + max(nDotL, 0.) * vDiffuse.rgb;
	  col = col + pow(max(dot(halfVec, n), 0.), shininess) * specular;
	  diffuse = vec4(col, vDiffuse.a);'
      else 
'	  diffuse = vDiffuse;',

      if ((has_texture && texture_format == "rgba") || type == "text")
'	  vec4 textureColor = diffuse*texture2D(uSampler, vTexcoord);',

      if (has_texture) switch(texture_format,
         rgb = 
'	  vec4 textureColor = diffuse*vec4(texture2D(uSampler, vTexcoord).rgb, 1.);',
	 alpha =
'	  vec4 textureColor = texture2D(uSampler, vTexcoord);
	  float luminance = dot(vec3(1.,1.,1.), textureColor.rgb)/3.;
	  textureColor =  vec4(diffuse.rgb, diffuse.a*luminance);',
         luminance =
'	  vec4 textureColor = vec4(diffuse.rgb*dot(texture2D(uSampler, vTexcoord).rgb, vec3(1.,1.,1.))/3.,
                                   diffuse.a);',
         luminance.alpha =
'	  vec4 textureColor = texture2D(uSampler, vTexcoord);
	  float luminance = dot(vec3(1.,1.,1.),textureColor.rgb)/3.;
	  textureColor = vec4(diffuse.rgb*luminance, diffuse.a*textureColor.a);'),
           
      if (has_texture)
'	  gl_FragColor = textureColor;'
      else if (type == "text")
'	  if (textureColor.a < 0.1)
	    discard;
	  else
	    gl_FragColor = textureColor;'
        else
'	  gl_FragColor = diffuse;',

'	}
	</script> 
'     )
    c(vertex, fragment)    
  }

  scriptheader <- function() {
          
    c(
  '
	<script type="text/javascript"> 

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
	var SQRT2 = Math.SQRT2;
	var PI = Math.PI;
	var log = Math.log;
	var exp = Math.exp;
    
	var canvas;
	var width;
	var height;
	
		   
	var debug = function(msg) 
	   document.getElementById("debug").innerHTML = msg;
	
	function webGLStart() {
	   debug("");
	   var gl;
	   canvas = document.getElementById("canvas");
	   if (!window.WebGLRenderingContext){',
      paste(
'	     debug("', snapshotimg2, 
'Your browser does not support WebGL. See <a href=\\\"http://get.webgl.org\\\">http://get.webgl.org</a>");', sep=""),
'	     return;
	   }
	   try {
	     // Try to grab the standard context. If it fails, fallback to experimental.
	     gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
	   }
	   catch(e) {}
	   if ( !gl ) {',
      paste(
'	     debug("', snapshotimg2, 
'Your browser appears to support WebGL, but did not create a WebGL context.  See <a href=\\\"http://get.webgl.org\\\">http://get.webgl.org</a>");', sep=""),
      subst(
'	     return;
	   }
	   var width = %width%;  var height = %height%;
	   canvas.width = width;   canvas.height = height;
	   gl.viewport(0, 0, width, height);
	   var prMatrix = new CanvasMatrix4();
	   var mvMatrix = new CanvasMatrix4();
	   var normMatrix = new CanvasMatrix4();
	   var saveMat = new CanvasMatrix4();
	   saveMat.makeIdentity();
	   var distance;
', width, height))
  }
  
  setUser <- function() c(
    subst(
'	   var zoom = %zoom%;', zoom = par3d("zoom")),
'	   var userMatrix = new CanvasMatrix4();
	   userMatrix.load([',
    paste(formatC(par3d("userMatrix"), digits=7, width=1), collapse=", "),
'		]);')
  
  textureSupport <- 
'	   function getPowerOfTwo(value, pow) {
	     var pow = pow || 1;
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
	     var canvas = document.getElementById("textureCanvas");
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
'

  textSupport <- subst( 
'	   function drawTextToCanvas(text, cex) {
	     var canvasX, canvasY;
	     var textX, textY;

	     var textHeight = 20 * cex;
	     var textColour = "white";
	     var fontFamily = "%font%";

	     var backgroundColour = "rgba(0,0,0,0)";

	     var canvas = document.getElementById("textureCanvas");
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
', font)

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
      paste('	  ', strwrap(paste(formatC(as.numeric(t(values)), digits=7, width=1), collapse=", "))),
'	   ]);
	   var f=new Uint16Array([', 
      paste('	  ', strwrap(paste(x$it-1, collapse=", "))),
'	   ]);
	   var sphereBuf = gl.createBuffer();
	   gl.bindBuffer(gl.ARRAY_BUFFER, sphereBuf);
	   gl.bufferData(gl.ARRAY_BUFFER, v, gl.STATIC_DRAW);
	   var sphereIbuf = gl.createBuffer();
	   gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, sphereIbuf);
	   gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, f, gl.STATIC_DRAW);
')
}    

  setprMatrix <- function() {
    # This is based on the Frustum::enclose code from geom.cpp
    bbox <- par3d("bbox")
    scale <- par3d("scale")
    fov <- par3d("FOV")*pi/180
    ranges <- c(bbox[2]-bbox[1], bbox[4]-bbox[3], bbox[6]-bbox[5])*scale/2
    radius <- sqrt(sum(ranges^2))*1.1 # A bit bigger to handle labels
    if (fov > 0) {
      s <- sin(fov/2)
      t <- tan(fov/2)
    } else {
      s <- 0.5
      t <- 1.0
    }
    distance <- radius/s
    near <- distance - radius
    far <- distance + radius
    hlen <- t*near
    subst(
'	     distance = %distance%;
	     var aspect = width/height;
	     prMatrix.makeIdentity();
	     if (aspect > 1)
	       prMatrix.frustum(-%hlen%*aspect*zoom, %hlen%*aspect*zoom, 
	                        -%hlen%*zoom, %hlen%*zoom, %near%, %far%);
	     else  
	       prMatrix.frustum(-%hlen%*zoom, %hlen%*zoom, 
	                        -%hlen%*zoom/aspect, %hlen%*zoom/aspect, 
	                        %near%, %far%);',
            distance, hlen, near, far)
  }

  setmvMatrix <- function() {
    scale <- par3d("scale")
    bbox <- par3d("bbox")
    center <- c(bbox[1]+bbox[2], bbox[3]+bbox[4], bbox[5]+bbox[6])/2
    subst(
'	     mvMatrix.makeIdentity();
	     mvMatrix.translate( %cx%, %cy%, %cz% );
	     mvMatrix.scale( %sx%, %sy%, %sz% );   
	     mvMatrix.multRight( userMatrix );  
	     mvMatrix.translate(0, 0, -distance);',
     cx=-center[1], cy=-center[2], cz=-center[3],
     sx=scale[1],   sy=scale[2],   sz=scale[3])
  }

  setnormMatrix <- function() {
    scale <- par3d("scale")
    subst(
'	     normMatrix.makeIdentity();
	     normMatrix.scale( %sx%, %sy%, %sz% );   
	     normMatrix.multRight( userMatrix );',
     sx=1/scale[1], sy=1/scale[2], sz=1/scale[3])
  }

  init <- function(id, type) {
    is_indexed <- type %in% c("quads", "surface", "text")
    has_faces <- is_indexed || type %in% c("triangles", "planes", "spheres")
    mat <- rgl.getmaterial(id = id)
    has_texture <- !is.null(mat$texture) && length(rgl.attrib.count(id, "texcoords"))
    
    result <- subst(
'
	   // ****** %type% object %id% ****** 
	   var prog%id%  = gl.createProgram();
	   gl.attachShader(prog%id%, getShader( gl, "vshader%id%" ));
	   gl.attachShader(prog%id%, getShader( gl, "fshader%id%" ));
	   gl.linkProgram(prog%id%);', type, id)
   
    nv <- rgl.attrib.count(id, "vertices")
    values <- rgl.attrib(id, "vertices")
    
    nc <- rgl.attrib.count(id, "colors")
    colors <- rgl.attrib(id, "colors")
    if (nc > 1) {
      if (nc < nv) {
        rows <- rep(seq_len(nc), length.out=nv)
        colors <- colors[rows,]
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
    
    if (type == "surface") { # Compute both indices and constructed normals
      if (nn == 0) 
        normals <- matrix(0, nv, 3)
      dim <- rgl.attrib(id, "dim")
      nx <- dim[1]
      nz <- dim[2]
      f <- NULL
      for (j in seq_len(nx-1)-1) {
        v1 <- j + nx*(seq_len(nz) - 1)
        v2 <- v1 + 1
        f <- cbind(f, rbind(c(v1, v2[nz]), 
                            c(v2, v1[1]+1)))
        if (nn == 0) {
          for (i in seq_along(v1)[-1]) {
            i0 <- v1[i-1]+1
            i1 <- v2[i-1]+1
            i2 <- v1[i]+1
            i3 <- v2[i]+1
            vec0 <- values[i0,1:3]
            vec1 <- values[i1,1:3]
            vec2 <- values[i2,1:3]
            vec3 <- values[i3,1:3]
            n1 <- xprod(vec2-vec0, vec1-vec0)
            n1 <- n1/sqrt(sum(n1^2))
            n2 <- xprod(vec3-vec2, vec1-vec2)
            n2 <- n2/sqrt(sum(n2^2))
            normals[i0,] <- normals[i0,] + n1
            normals[i1,] <- normals[i1,] + n1 + n2
            normals[i2,] <- normals[i2,] + n1 + n2
            normals[i3,] <- normals[i3,] + n2
          }
        }
      }
      f <- f[,-NCOL(f)]
      if (nn == 0) {
        normals <- t(apply(normals, 1, function(x) x/sqrt(sum(x^2))))
        values <- cbind(values, normals)
        nn <- nv
      }
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
      values <- cbind(values, texcoords, refs)
      nv <- nv*4
      result <- c(result, 
'	   var texts = [',
      	paste('	    "', texts, '"', sep="", collapse=",\n"),
'	   ];',

        subst(
'	   var texinfo = drawTextToCanvas(texts, %cex%);	 
	   var canvasX%id% = texinfo.canvasX;
	   var canvasY%id% = texinfo.canvasY;
	   var ofsLoc%id% = gl.getAttribLocation(prog%id%, "aTextOfs");',
	  cex=cex[1], id))
    }
    
    if (has_texture || type == "text") result <- c(result, subst(
'	   var texture%id% = gl.createTexture();
	   var texLoc%id% = gl.getAttribLocation(prog%id%, "aTexcoord");
	   var sampler%id% = gl.getUniformLocation(prog%id%,"uSampler");',
	  id))
	  
    if (has_texture) {
      tofs <- NCOL(values)
      texcoords <- rgl.attrib(id, "texcoords")
      values <- cbind(values, texcoords)
      file.copy(mat$texture, file.path(dir, paste("texture", id, ".png", sep="")))
      result <- c(result, subst(
'	   loadImageToTexture("texture%id%.png", texture%id%);',
        id))
    }
    
    if (type == "text") result <- c(result, subst(
'    	   handleLoadedTexture(texture%id%, document.getElementById("textureCanvas"));',
        id))
      
    stride <- NCOL(values)
    result <- c(result, 
'	   var v=new Float32Array([',
      paste('	  ', strwrap(paste(formatC(as.numeric(t(values)), digits=7, width=1), collapse=", "))),
'	   ]);',

      if (type == "text") subst(
'	   for (var i=0; i<%len%; i++) 
	     for (var j=0; j<4; j++) {
	         ind = %stride%*(4*i + j) + %tofs%;
	         v[ind+2] = 2*(v[ind]-v[ind+2])*texinfo.widths[i]/width;
	         v[ind+3] = 2*(v[ind+1]-v[ind+3])*texinfo.textHeight/height;
	         v[ind] *= texinfo.widths[i]/texinfo.canvasX;
	         v[ind+1] = 1.0-(texinfo.offset + i*texinfo.skip 
	           - v[ind+1]*texinfo.textHeight)/texinfo.canvasY;
	     }', len=length(texts), stride, tofs),
	     
      if (type == "spheres") subst(
'	   var values%id% = v;', 
                  id),
	   
      subst(      
'	   var posLoc%id% = gl.getAttribLocation(prog%id%, "aPos");
	   var colLoc%id% = gl.getAttribLocation(prog%id%, "aCol");',
                  id),
                  
    if (nn > 0 || type == "spheres") subst(
'	   var normLoc%id% = gl.getAttribLocation(prog%id%, "aNorm");', 
        id))

    if (is_indexed) {
      if (type %in% c("quads", "text")) {
        v1 <- 4*(seq_len(nv/4) - 1)
        v2 <- v1 + 1
        v3 <- v2 + 1
        v4 <- v3 + 1
        f <- rbind(v1, v2, v3, v1, v3, v4)
      }
      result <- c(result,
	'	   var f=new Uint16Array([', 
	paste('	  ', strwrap(paste(f, collapse=", "))),
	'	   ]);')
    }
    result <- c(result,
      if (type != "spheres") subst(
'	   var buf%id% = gl.createBuffer();
	   gl.bindBuffer(gl.ARRAY_BUFFER, buf%id%);
	   gl.bufferData(gl.ARRAY_BUFFER, v, gl.STATIC_DRAW);',
   		id),
      if (is_indexed) subst(
'	   var ibuf%id% = gl.createBuffer();
	   gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ibuf%id%);
	   gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, f, gl.STATIC_DRAW);',
   		id),
      subst(
'	   var mvMatLoc%id% = gl.getUniformLocation(prog%id%,"mvMatrix");
	   var prMatLoc%id% = gl.getUniformLocation(prog%id%,"prMatrix");',
   		  id),
      if (has_faces) subst(
'	   var normMatLoc%id% = gl.getUniformLocation(prog%id%,"normMatrix");',
		  id)
   		 ) 
    c(result, '')
  }
  
  draw <- function(id, type) {
    has_faces <- type %in% c("triangles", "quads", "surface", 
                             "planes", "spheres")
    is_indexed <- type %in% c("quads", "surface", "text", "spheres")
    mat <- rgl.getmaterial(id = id)
    has_texture <- !is.null(mat$texture) && length(rgl.attrib.count(id, "texcoords"))
    result <- c(subst(
'
	     // ****** %type% object %id% *******
	     gl.useProgram(prog%id%);',
       type, id),
       
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
       
    if (has_faces)
      result <- c(result,
        subst(
'	     gl.uniformMatrix4fv( normMatLoc%id%, false, new Float32Array(normMatrix.getAsArray()) );',
          id))
          
    result <- c(result, 
        subst(
'	     gl.enableVertexAttribArray( posLoc%id% );',  id))

    count <- rgl.attrib.count(id, "vertices")
    stride <- 12 
    nc <- rgl.attrib.count(id, "colors")
    if (nc > 1) {
      cofs <- stride
      stride <- stride + 16
    }
    
    nn <- rgl.attrib.count(id, "normals")
    if (nn == 0 && type == "surface")
      nn <- rgl.attrib.count(id, "vertices")
    if (nn > 0) {
      nofs <- stride
      stride <- stride + 12
    }
    
    if (type == "spheres") {
      radofs <- stride
      stride <- stride + 4
      scount <- count
    }
    
    if (has_texture || type == "text") {
      tofs <- stride
      stride <- stride + 8
    }
    
    if (type == "text")
      stride <- stride + 8
      
    if (type == "spheres") {
      scale <- par3d("scale")
      sx <- 1/scale[1]
      sy <- 1/scale[2]
      sz <- 1/scale[3]
      result <- c(result, subst(
'	     gl.vertexAttribPointer(posLoc%id%,  3, gl.FLOAT, false, %sphereStride%,  0);
	     gl.enableVertexAttribArray(normLoc%id% );
	     gl.vertexAttribPointer(normLoc%id%,  3, gl.FLOAT, false, %sphereStride%,  0);
	     gl.disableVertexAttribArray( colLoc%id% );
	     var sphereNorm = new CanvasMatrix4();
	     sphereNorm.scale(%sx%, %sy%, %sz%);
	     sphereNorm.multRight(normMatrix);
	     gl.uniformMatrix4fv( normMatLoc%id%, false, new Float32Array(sphereNorm.getAsArray()) );', 
	  id, sphereStride, sx=1/sx, sy=1/sy, sz=1/sz),

        if (nc == 1) {
          colors <- rgl.attrib(id, "colors")
          subst(
'	     gl.vertexAttrib4f( colLoc%id%, %r%, %g%, %b%, %a%);',
           id, r=colors[1], g=colors[2], b=colors[3], a=colors[4])
	},
	
        subst(
'	     for (var i = 0; i < %scount%; i++) {
	       var sphereMV = new CanvasMatrix4();
	       var ofs = i*%stride% + %radofs%;
	       var scale = values%id%[ofs];
	       sphereMV.scale(%sx%*scale, %sy%*scale, %sz%*scale);
	       
	       ofs = i*%stride%;
	       sphereMV.translate(values%id%[ofs], 
	       			  values%id%[ofs+1], 
	       			  values%id%[ofs+2]);
	       sphereMV.multRight(mvMatrix);
	       gl.uniformMatrix4fv( mvMatLoc%id%, false, new Float32Array(sphereMV.getAsArray()) );',
	 scount, stride=stride/4, radofs=radofs/4, id, sx, sy, sz),
	 
	 if (nc > 1) subst(
'	       ofs = i*%stride% + %cofs%;       
	       gl.vertexAttrib4f( colLoc%id%, values%id%[ofs], 
	       				    values%id%[ofs+1], 
	       				    values%id%[ofs+2],
	       				    values%id%[ofs+3] );',
	   stride=stride/4, cofs=cofs/4, id),
	   
         subst(
'	       gl.drawElements(gl.TRIANGLES, %sphereCount%, gl.UNSIGNED_SHORT, 0);
	     }', sphereCount))

    } else {
      if (nc == 1) {
        colors <- rgl.attrib(id, "colors")
        result <- c(result, subst(
'	     gl.disableVertexAttribArray( colLoc%id% );
	     gl.vertexAttrib4f( colLoc%id%, %r%, %g%, %b%, %a% );', 
            id, r=colors[1], g=colors[2], b=colors[3], a=colors[4]))
      } else {
        result <- c(result, subst(
'	     gl.enableVertexAttribArray( colLoc%id% );
	     gl.vertexAttribPointer(colLoc%id%, 4, gl.FLOAT, false, %stride%, %cofs%);',
          id, stride, cofs))
      }
    
      if (nn > 0) {
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
      
      if (type == "text") {
        result <- c(result, subst(
'	     gl.enableVertexAttribArray( ofsLoc%id% );
	     gl.vertexAttribPointer(ofsLoc%id%, 2, gl.FLOAT, false, %stride%, %ofs%);',
          id, stride, ofs=tofs + 8))
      }
      
      mode <- switch(type,
        points = "POINTS",
        linestrip = "LINE_STRIP",
        abclines =,
        lines = "LINES",
        planes =,
        text =,
        quads =,
        triangles = "TRIANGLES",
        surface = "TRIANGLE_STRIP",
        stop("unsupported mode") )
      
      switch(type,
        text = count <- count*6,
        quads = count <- count*6/4,
        surface = {
          dim <- rgl.attrib(id, "dim")
          nx <- dim[1]
          nz <- dim[2]
          count <- (nx - 1)*(nz + 1)*2 - 2
        })
    
      if (type %in% c("lines", "linestrip", "abclines")) {
        lwd <- rgl.getmaterial(id=id)$lwd
        result <- c(result,subst(
'	     gl.lineWidth( %lwd% );',
          lwd))
      }
      
      result <- c(result, subst(
'	     gl.vertexAttribPointer(posLoc%id%,  3, gl.FLOAT, false, %stride%,  0);',
          id, stride),
      	
        if (is_indexed) subst(
'	     gl.drawElements(gl.%mode%, %count%, gl.UNSIGNED_SHORT, 0);',
            mode, count)
        else
          subst(
'	     gl.drawArrays(gl.%mode%, 0, %count%);',
            mode, count))
    }
    result
  }
    
  scriptMiddle <- function() {
    bgid <- rgl.ids("background")
    if (!length(bgid) || !length(bg <- rgl.attrib(bgid$id, "colors")))
      bg <- c(1,1,1,1)
    c(subst(
'
	   gl.enable(gl.DEPTH_TEST);
	   gl.depthFunc(gl.LEQUAL);
	   gl.clearDepth(1.0);
	   gl.clearColor(%r%, %g%, %b%, %a%);
	   var xOffs = yOffs = 0,  drag  = 0;
	   drawScene();

	   function drawScene(){',
        r=bg[1], g=bg[2], b=bg[3], a=bg[4]),
        
      setprMatrix(),
      setmvMatrix(),
      
      if (scene_has_faces) setnormMatrix(),
'	     gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
')
  }
  drawEnd <- '
	     gl.flush ();
	   }
'	   
  mouseHandlers <- function() {
    handlers <- par3d("mouseMode")
    if (any(notdone <- handlers %in% c("polar", "selecting", "fov", "user"))) {
      warning("Mouse mode(s) '", handlers[notdone], "' not supported.  'trackball' used.")
      handlers[notdone] <- "trackball"
    }
    uhandlers <- setdiff(unique(handlers), "none")
    result <- 
'	   var vlen = function(v) {
	     return sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])
	   }
	   
	   var xprod = function(a, b) {
	     return [a[1]*b[2] - a[2]*b[1],
	             a[2]*b[0] - a[0]*b[2],
	             a[0]*b[1] - a[1]*b[0]];
	   }

	   var screenToVector = function(x, y) {
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
'
    
    for (i in seq_along(uhandlers)) {
      h <- uhandlers[i]
      result <- c(result, switch(h,
        trackball = 
'	   var trackballdown = function(x,y) {
	     rotBase = screenToVector(x, y);
	     saveMat.load(userMatrix);
	   }
	   
	   var trackballmove = function(x,y) {
	     var rotCurrent = screenToVector(x,y);
	     var dot = rotBase[0]*rotCurrent[0] + 
	   	       rotBase[1]*rotCurrent[1] + 
	   	       rotBase[2]*rotCurrent[2];
	     var angle = acos( dot/vlen(rotBase)/vlen(rotCurrent) )*180./PI;
	     var axis = xprod(rotBase, rotCurrent);
	     userMatrix.load(saveMat);
	     userMatrix.rotate(angle, axis[0], axis[1], axis[2]);
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
	     saveMat.load(userMatrix);
	   }
	   	   
	   var %h%move = function(x,y) {
	     var rotCurrent = screenToVector(x,height/2);
	     var angle = (rotCurrent[0] - rotBase[0])*180/PI;
	     userMatrix.load(saveMat);
	     var rotMat = new CanvasMatrix4();
	     rotMat.rotate(angle, %h%[0], %h%[1], %h%[2]);
	     userMatrix.multLeft(rotMat);
	     drawScene();
	   }
	   
',           h)),
      zoom = 
'	   var y0 = 0;
	   var zoom0 = 1;
	   var zoomdown = function(x, y) {
	     y0 = y;
	     zoom0 = log(zoom);
	   }

	   var zoommove = function(x, y) {
	     zoom = exp(zoom0 + (y-y0)/height);
	     drawScene();
	   }
'    ))  }
        
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
'	   canvas.onmousedown = function ( ev ){
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
	       f(ev.clientX, height-ev.clientY);
	       ev.preventDefault();
	     }
	   }    
	       
	   canvas.onmouseup = function ( ev ){	
	     drag = 0;
	   }

	   canvas.onmousemove = function ( ev ){
	     if ( drag == 0 ) return;
	     var f = mousemove[drag-1];
	     if (f) f(ev.clientX, height-ev.clientY);
	   }

	   var wheelHandler = function(ev) {
	     var del = 1.1;
	     if (ev.shiftKey) del = 1.01;
	     var ds = ((ev.detail || ev.wheelDelta) > 0) ? del : (1 / del);
	     zoom *= ds;
	     drawScene();
	     ev.preventDefault();
	   };
	   canvas.addEventListener("DOMMouseScroll", wheelHandler, false);
	   canvas.addEventListener("mousewheel", wheelHandler, false);

	}
	</script>'

  htmlEnd <- function() c('
	</head>
	<body onload="webGLStart();"> 
	<canvas id="canvas" width="1" height="1"></canvas> 
        <p id="debug">', 
    snapshotimg, 
'	You must enable Javascript to view this page properly.</p>

	<br>Drag mouse to rotate model. Use mouse wheel or middle button
	to zoom it.
	<hr>
	<br>
	Object written from rgl by writeWebGL.

	</body></html>')

  convertBBox <- function(id) {
    verts <- rgl.attrib(id, "vertices")
    text <- rgl.attrib(id, "text")
    if (!length(text))
      text <- rep("", NROW(verts))
    
    if(any(missing <- text == "")) 
      text[missing] <- apply(verts[missing,], 1, function(row) format(row[!is.na(row)]))
      
    res <- integer(0)
    if (any(inds <- is.na(verts[,2]) & is.na(verts[,3]))) 
      res <- c(res, axis3d("x", at=verts[inds, 1], labels=text[inds]))
    if (any(inds <- is.na(verts[,1]) & is.na(verts[,3]))) 
      res <- c(res, axis3d("y", at=verts[inds, 2], labels=text[inds]))
    if (any(inds <- is.na(verts[,1]) & is.na(verts[,2]))) 
      res <- c(res, axis3d("z", at=verts[inds, 3], labels=text[inds]))
    res <- c(res, box3d())
    res
  }
  
  knowntypes <- c("points", "linestrip", "lines", "triangles", "quads",
                  "surface", "text", "abclines", "planes", "spheres")
  
  #  Execution starts here!
  
  
  # Do a few checks first
    
  if (!file.exists(dir))
    dir.create(dir)
  if (!file.info(dir)$isdir)
    stop("'", dir, "' is not a directory.")
  
  file.copy(system.file(file.path("Javascript", "CanvasMatrix.js"), package = "rgl"), 
                        file.path(dir, "CanvasMatrix.js"))
  
  if (snapshot) {
    snapshot3d(file.path(dir, "snapshot.png"))
    snapshotimg <- '<img src="snapshot.png" alt="Snapshot"/><br>'
    snapshotimg2 <- gsub('"', '\\\\"', snapshotimg)
  } else snapshotimg2 <- snapshotimg <- NULL
  
  rect <- par3d("windowRect")
  rwidth <- rect[3] - rect[1] + 1
  rheight <- rect[4] - rect[2] + 1
  if (missing(width)) {
    if (missing(height)) {
      width <- rwidth
      height <- rheight
    } else
      width <- height * rwidth/rheight
  } else 
    if (missing(height))
      height <- width * rheight/rwidth

  result <- htmlheader()
  
  if (NROW(bbox <- rgl.ids("bboxdeco"))) {
    save <- par3d(skipRedraw = TRUE)
    temp <- convertBBox(bbox$id)
    on.exit({ rgl.pop(id=temp); par3d(save) })
  }
    
  ids <- rgl.ids()
  types <- as.character(ids$type)
  ids <- ids$id
 
  unknowntypes <- setdiff(types, knowntypes)
  if (length(unknowntypes))
    warning("Object type(s) ", 
      paste("'", unknowntypes, "'", sep="", collapse=", "), " not handled.")

    
  ids <- ids[types %in% knowntypes]
  types <- types[types %in% knowntypes]
  texnums <- -1
  
  scene_has_faces <- length(intersect(c("triangles", "quads", 
                           "surface", "planes", "spheres"), types)) > 0
  
  for (i in seq_along(ids))
    result <- c(result, shaders(ids[i], types[i]))
    
  result <- c(result, scriptheader(), setUser(),
    textureSupport,
    if ("text" %in% types) textSupport,
    if ("spheres" %in% types) sphereSupport())

  for (i in seq_along(ids)) 
    result <- c(result, init(ids[i], types[i]))
   
  result <- c(result, scriptMiddle())
  
  for (i in seq_along(ids)) 
    result <- c(result, draw(ids[i], types[i]))
   
  result <- c(result, drawEnd, mouseHandlers(), scriptEnd, htmlEnd())

  cat(result, file=filename, sep="\n")
  invisible(filename)
}
