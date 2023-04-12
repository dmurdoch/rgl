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

getShaderFlags <- function(id, subscene = currentSubscene3d()) {
	stopifnot(length(id) == 1, length(subscene) == 1)
	flags <- logical(20)
	ret <- .C( rgl_getShaderFlags,
											success = FALSE,
											id = as.integer(id),
											sub = as.integer(subscene),
											flags = flags)
	if (!ret$success)
		stop("getShaderFlags failed")
	flags <- ret$flags
	names(flags) <- c(	
		"fat_lines",
		"fixed_quads",
		"fixed_size",
		"has_fog",
		"has_normals",
		"has_texture",
		"is_brush",
		"is_lines",
		"is_lit",
		"is_points",
		"is_transparent",
		"is_twosided",
		"needs_vnormal",
		"rotating",
		"round_points",
		"sprites_3d",
		"is_smooth",
		"depth_sort",
		"is_subscene",
		"is_clipplanes")
	flags
}
