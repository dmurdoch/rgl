setUserShaders <- function(ids, vertexShader = NULL, fragmentShader = NULL,
			   attributes = NULL, uniforms = NULL, textures = NULL,
			   scene = scene3d(minimal),
			   minimal = TRUE) {
  .Deprecated("material3d", "rgl",
              msg = "Set material properties instead of using setUserShaders().")
  stopifnot(inherits(scene, "rglscene"))
  for (i in ids) {
    id <- as.character(i)
    obj <- scene$objects[[id]]
    if (!is.null(vertexShader))
      obj$material$vertex_shader <- paste(vertexShader, collapse = "\n")
    if (!is.null(fragmentShader))
      obj$material$fragment_shader <- paste(fragmentShader, collapse = "\n")
    obj$material$user_attributes <- attributes
    obj$material$user_uniforms <- uniforms
    obj$material$user_textures <- textures
    alldata <- c(obj$material$user_attributes,
                 obj$material$user_uniforms,
                 obj$material$user_textures)
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
		vertexShader <- obj$material$vertex_shader
		fragmentShader <- obj$material$fragment_shader
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

print.rglshaders <- function(x, vertex = TRUE, fragment = TRUE, simplify = TRUE, ...) {
  if (simplify) 
    processIfdef(x, vertex = vertex, fragment = fragment)
  else {
    cat(x$defines, sep = "\n")
    if (vertex) {
      shader <- x$vertexShader
      if (inherits(shader, "rglShader"))
        shader <- summary(shader)
      cat(shader, sep = "\n")
      cat("\n")
    }
    if (fragment) {
      shader <- x$fragmentShader
      if (inherits(shader, "rglShader"))
        shader <- summary(shader)
      cat(shader, sep = "\n")
    }
  }
  invisible(x)
}

# These help for debugging shaders

parseDefines <- function(code) {
  code <- readLines(textConnection(code))
  defines <- grep("^#define ", code, value = TRUE)
  defines <- strsplit(defines, " ")
  res <- new.env(parent = baseenv())
  values <- sapply(defines, function(x) assign(x[2], x[3], envir = res))
  res
}


processIfdef <- function(shaders, vertex = TRUE, fragment = TRUE) {
  defines <- parseDefines(shaders$defines)
  defined <- function(x, value = FALSE) {
    if (value)
      x %in% ls(defines)
    else
      deparse(substitute(x)) %in% ls(defines)
  }
  env <- list2env(list(defined = defined), parent = defines)
  code <- c(if (vertex) readLines(textConnection(summary(shaders$vertexShader))),
            if (fragment) readLines(textConnection(summary(shaders$fragmentShader))))
  keep <- rep(NA, length(code))
  keeping <- TRUE
  hastrue <- TRUE
  for (i in seq_along(code)) {
    keep[i] <- FALSE
    line <- code[i]
    if (grepl("^#ifdef ", line)) {
      name <- sub("^.* ", "", line)
      keeping <- c(defined(name, value = TRUE), keeping)
      names(keeping)[1] <- name
      hastrue <- c(keeping[1], hastrue)
    } else if (grepl("^#ifndef ", line)) {
      name <- sub("^.* ", "", line)
      keeping <- c(!defined(name, value = TRUE), keeping)
      names(keeping)[1] <- paste0("!", name)
      hastrue <- c(keeping[1], hastrue)
    } else if (grepl("^#else", line)) {
      keeping[1] <- !hastrue[1]
      names(keeping)[1] <- paste0("!", names(keeping)[1])
      hastrue[1] <- hastrue[1] || keeping[1]
    } else if (grepl("^#endif", line)) {
      keeping <- keeping[-1]
      hastrue <- hastrue[-1]
    } else if (grepl("^#if ", line)) {
      text <- sub("^#if ", "", line)
      expr <- parse(text = text)
      keeping <- c(eval(expr, envir = env), keeping)
      names(keeping)[1] <- text
      hastrue <- c(keeping[1], hastrue)
    } else if (grepl("^#elif ", line)) {
      text <- sub("^#elif ", "", line)
      expr <- parse(text = text)
      keeping <- c(!hastrue[1] && eval(expr, envir = env), keeping[-1])
      names(keeping)[1] <- text
      hastrue[1] <- hastrue[1] || keeping[1]
    } else if (!grepl("^#line ", line))
      keep[i] <- all(keeping) && gsub(" ", "", line) != ""
  }
  code <- c(shaders$defines, code[keep])
  cat(code, sep="\n")
  invisible(code)
}
