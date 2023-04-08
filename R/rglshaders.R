print.rglShader <- function(x, ...) {
	if (x[1] == "")
		print("<default>", ...)
	else
		print("<custom>", ...)
}

summary.rglShader <- function(object, ...) {
	if (object[1] == "")
		defaultShaders[[attr(object, "type")]]
	else
		unclass(object[1])
}

defaultShaders <- list(vertex = readLines(file.path(system.file("shaders/rgl_vertex.glsl", package = "rgl"))),
											 fragment = readLines(file.path(system.file("shaders/rgl_fragment.glsl", package = "rgl"))))