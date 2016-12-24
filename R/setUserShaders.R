setUserShaders <- function(ids, vertexShader = NULL, fragmentShader = NULL,
			   attributes = NULL, uniforms = NULL,
			   scene = scene3d()) {
  stopifnot(inherits(scene, "rglscene"))
  for (i in ids) {
    id <- as.character(i)
    obj <- scene$objects[[id]]
    obj$userVertexShader <- paste(vertexShader, collapse = "\n")
    obj$userFragmentShader <- paste(fragmentShader, collapse = "\n")
    obj$userAttributes <- attributes
    obj$userUniforms <- uniforms
    scene$objects[[id]] <- obj
  }
  scene
}