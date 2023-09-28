setUserShaders <- function(ids, vertexShader = NULL, fragmentShader = NULL,
			   attributes = NULL, uniforms = NULL, textures = NULL,
			   scene = scene3d(minimal),
			   minimal = TRUE) {
  stopifnot(inherits(scene, "rglscene"))
  for (i in ids) {
    id <- as.character(i)
    obj <- scene$objects[[id]]
    if (!is.null(vertexShader))
      obj$userVertexShader <- paste(vertexShader, collapse = "\n")
    if (!is.null(fragmentShader))
      obj$userFragmentShader <- paste(fragmentShader, collapse = "\n")
    obj$userAttributes <- attributes
    obj$userUniforms <- uniforms
    obj$userTextures <- textures
    alldata <- c(obj$userAttributes, obj$userUniforms, obj$userTextures)
    allnames <- names(alldata)
    if (length(allnames) != length(alldata) ||
        any(nchar(allnames) == 0) ||
        any(duplicated(allnames)))
      stop("attributes, uniforms and textures should be named")
    scene$objects[[id]] <- obj
  }
  scene
}

getShaders <- function(id, scene = scene3d(minimal), minimal = TRUE,
											 subscene = currentSubscene3d(),
											 useJavascript = FALSE) {
	if (is.na(useJavascript) || !useJavascript) {
		defines <- getShaderDefines(id, subscene = subscene)
		shaders <- material3d(c("vertex_shader", "fragment_shader"))
		vertexShader <- shaders$vertex_shader
		fragmentShader <- shaders$fragment_shader
		result <- result1 <- structure(list(vertexShader = vertexShader,
															 fragmentShader = fragmentShader,
															 defines = defines), class = "rglshaders")
	}
	if (is.na(useJavascript) || useJavascript) {
		obj <- scene$objects[[as.character(id)]]
		vertexShader <- obj$userVertexShader
		fragmentShader <- obj$userFragmentShader
		if (is.null(vertexShader) || is.null(fragmentShader)) {
			if (!requireNamespace("V8"))
				stop("This function requires the V8 package.")
			scene <- convertScene(scene)
			obj <- scene$objects[[as.character(id)]]
			ctx <- V8::v8()
			ctx$source(system.file("htmlwidgets/lib/rglClass/rglClass.src.js", package="rgl"))
			ctx$source(system.file("htmlwidgets/lib/rglClass/utils.src.js", package="rgl"))
			ctx$source(system.file("htmlwidgets/lib/rglClass/shaders.src.js", package="rgl"))
			
			pointSize <- obj$material$size
			if (is.null(pointSize))
				pointSize <- scene$material$size
			
			antialias <- obj$material$point_antialias
			if (is.null(antialias))
				antialias <- scene$material$point_antialias
			
			textype <- obj$material$textype
			if (is.null(textype))
				textype <- scene$material$textype
			
			texmode <- obj$material$texmode
			if (is.null(texmode))
				texmode <- scene$material$texmode
			
			texenvmap <- obj$material$texenvmap
			if (is.null(texenvmap))
				texenvmap <- scene$material$texenvmap
			
			nclipplanes <- 0
			nlights <- 0
			for (i in seq_along(scene$objects)) {
				nclipplanes <- nclipplanes + (scene$objects[[i]]$type == "clipplanes")
				nlights <- nlights + (scene$objects[[i]]$type == "light")
			}
			if (is.null(vertexShader))
				vertexShader <- readLines(system.file("shaders/rgl_vertex.glsl", package = "rgl"))
			
			if (is.null(fragmentShader))
				fragmentShader <- readLines(system.file("shaders/rgl_fragment.glsl", package = "rgl"))
		}
		
		defines <- ctx$eval(subst(
			'rglwidgetClass.getDefines(%id%, "%type%", %flags%,
      %nclipplanes%, %nlights%, %normals%, %pointSize%,
      "%textype%", "%texmode%", %texenvmap%, %antialias%)', 
			id = id, 
			type = obj$type, 
			flags = obj$flags, 
			nclipplanes = nclipplanes, 
			nlights = nlights, 
			normals = if (is.null(obj$normals)) "undefined" else 1,
			pointSize = pointSize,
			textype = textype,
			texmode = texmode,
			texenvmap = tolower(texenvmap),
			antialias = tolower(antialias)
		))
		
		result <- structure(list(vertexShader = vertexShader,
									 fragmentShader = fragmentShader,
									 defines = defines), class = "rglshaders")
		if (is.na(useJavascript)) {
			result1$vertexShader <- summary(result1$vertexShader)
			result1$fragmentShader <- summary(result1$fragmentShader)
			if (!isTRUE(all.equal(result, result1)))
			  stop("differences in shaders by method")
		}
	}
  result
}

print.rglshaders <- function(x, ...) {
  cat(x$defines, sep = "\n")
	if (inherits(x$vertexShader, "rglShader"))
		x$vertexShader <- summary(x$vertexShader)
  cat(x$vertexShader, sep = "\n")
  cat("\n")
  cat(x$defines, sep = "\n" )
  if (inherits(x$fragmentShader, "rglShader"))
  	x$fragmentShader <- summary(x$fragmentShader)
  cat(x$fragmentShader, sep = "\n")
  invisible(x)
}