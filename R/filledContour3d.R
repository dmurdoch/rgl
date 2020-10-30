filledContour3d <- function(obj, ...)
  UseMethod("filledContour3d")

filledContour3d.rglId <- function(obj, ...) {
  mesh <- as.mesh3d(obj)
  filledContour3d(mesh, ...)
}

filledContour3d.mesh3d <- function(obj, fn = "z",
    nlevels = 20,
    levels = pretty(range(values), nlevels),
    color.palette = function(n) hcl.colors(n, "YlOrRd", rev = TRUE),
    col = color.palette(length(levels) - 1),
    minVertices = 0,
    plot = TRUE, 
    keepValues = FALSE, ...) {
  nverts <- ncol(obj$vb)
  oldnverts <- nverts - 1
  while (nverts < minVertices && oldnverts < nverts) {
    oldnverts <- nverts
    mesh <- subdivision3d(obj, deform = FALSE, normalize = TRUE)
    nverts <- ncol(obj$vb)
  }
  if (is.null(fn))
    fn <- obj$values
  if (is.null(fn))
    stop("'fn' can only be NULL if 'obj' contains values.")
  verts <- asEuclidean(t(obj$vb))
  if (is.numeric(fn))
    values <- fn
  else {
    fn <- .getVertexFn(fn, parent.frame())
    values <- fn(verts)
  }
  if (is.null(obj$material))
    obj$material <- list()
  obj$material$color <- NA
  obj$values <- values
  result <- list()
  for (i in seq_along(col)) {
    obj <- clipMesh3d(obj, NULL, bound = levels[i], keepValues = TRUE)
    strip <- clipMesh3d(obj, NULL, bound = levels[i+1], greater = FALSE, keepValues = keepValues && !plot)
    strip$material$color <- col[i]
    result[[i]] <- strip
  }
  result <- shapelist3d(result, plot = FALSE)
  if (plot)
    shade3d(result, ...)
  else
    result
}