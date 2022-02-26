setUserShaders <- function(ids, vertexShader = NULL, fragmentShader = NULL,
			   attributes = NULL, uniforms = NULL,
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
    scene$objects[[id]] <- obj
  }
  scene
}

getShaders <- function(id, scene = scene3d(minimal), minimal = TRUE) {
  obj <- scene$objects[[as.character(id)]]
  vertexShader <- obj$vertexShader
  fragmentShader <- obj$fragmentShader
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
  
    nclipplanes <- 0
    nlights <- 0
    for (i in seq_along(scene$objects)) {
      nclipplanes <- nclipplanes + (scene$objects[[i]]$type == "clipplanes")
      nlights <- nlights + (scene$objects[[i]]$type == "light")
    }
    if (is.null(vertexShader))
      vertexShader <- ctx$eval(subst(
        'rglwidgetClass.makeVertexShader(%id%, "%type%", %flags%, %nclipplanes%, %normals%, %pointSize%)', 
        id = id, 
        type = obj$type, 
        flags = obj$flags, 
        nclipplanes = nclipplanes,
        normals = if (is.null(obj$normals)) "undefined" else 1,
        pointSize = pointSize 
      ))
    
    if (is.null(fragmentShader))
      fragmentShader <- ctx$eval(subst(
        'rglwidgetClass.makeFragmentShader(%id%, "%type%", %flags%, %nclipplanes%, %nlights%, "%textype%", %antialias%)', 
        id = id, 
        type = obj$type, 
        flags = obj$flags, 
        nclipplanes = nclipplanes, 
        nlights = nlights, 
        textype = textype, 
        antialias = tolower(antialias)))
  }
  
  structure(list(vertexShader = vertexShader,
            fragmentShader = fragmentShader), class = "rglshaders")
}

print.rglshaders <- function(x, ...) {
  cat(x$vertexShader)
  cat("\n")
  cat(x$fragmentShader)
  invisible(x)
}