filledContour3d <- function(obj, ...)
  UseMethod("filledContour3d")

filledContour3d.rglId <- function(obj, plot = TRUE, replace = plot, ...) {
  mesh <- as.mesh3d(obj)
  result <- filledContour3d(mesh, plot = plot, ...)
  if (replace)
    pop3d(id = obj)
  result
}

if (getRversion() < "3.6.0") {
  hcl.colors <- function(n, ...) grDevices::cm.colors(n)
} else
  hcl.colors <- grDevices::hcl.colors

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
    obj <- subdivision3d(obj, deform = FALSE, normalize = TRUE)
    nverts <- ncol(obj$vb)
  }
  
  if (is.null(fn))
    fn <- obj$values
  if (is.null(fn))
    stop("'fn' can only be NULL if 'obj' contains values.")
  
  if (length(levels) < 2)
    stop("Must have at least 2 levels.")
  
  reverse <- levels[1] > levels[2]
  
  if (any((levels[-length(levels)] > levels[-1]) != reverse))
      stop("Levels must be monotone increasing or decreasing")

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
  strips <- seq_along(col)
  if (reverse) strips <- rev(strips)
  for (i in strips) {
    r <- range(levels[c(i, i+1)])
    obj <- clipMesh3d(obj, NULL, bound = r[1], keepValues = TRUE)
    strip <- clipMesh3d(obj, NULL, bound = r[2], greater = FALSE, keepValues = keepValues && !plot)
    strip$material$color <- col[i]
    result[[i]] <- cleanMesh3d(strip, rejoin = TRUE)
  }
  result <- do.call(merge, result)
  if (plot)
    shade3d(result, ...)
  else
    result
}
