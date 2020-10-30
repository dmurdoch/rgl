
contourLines3d <- function(obj, ...) 
  UseMethod("contourLines3d")

contourLines3d.rglId <- function(obj, ...) 
  contourLines3d(as.mesh3d(obj), ...)
  
contourLines3d.mesh3d <- function(obj, fn = "z", nlevels = 10, levels = NULL, 
                                  minVertices = 0, plot = TRUE, ... ) {
  obj <- as.tmesh3d(obj)
  nverts <- ncol(obj$vb)
  oldnverts <- nverts - 1
  while (nverts < minVertices && oldnverts < nverts) {
    oldnverts <- nverts
    obj <- subdivision3d(obj, deform = FALSE, normalize = TRUE)
    nverts <- ncol(obj$vb)
  }
  verts <- asEuclidean(t(obj$vb))
  if (is.null(fn))
    fn <- obj$values
  if (is.null(fn))
    stop("'fn' can only be NULL if 'obj' contains values")
  if (is.character(fn))
    fn <- structure(as.list(fn), names = fn)
  else if (is.function(fn) || is.numeric(fn)) 
    fn <- list(fn)
  funnames <- names(fn)
  if (is.null(funnames))
    funnames <- seq_along(fn)
    
  result <- data.frame(x = numeric(), y = numeric(), z = numeric(), fn = funnames[0], level = numeric())
  
  for (i in seq_along(fn)) {
    if (is.numeric(fn[[i]]))
      values <- fn[[i]]
    else {
      fun <- .getVertexFn(fn[[i]], parent.env())
      values <- fun(verts)
    }
    if (is.null(levels))
      levs <- pretty(range(values, na.rm = TRUE), nlevels)
    else
      levs <- levels
    for (lev in levs) {
      greater <- matrix(values[as.numeric(obj$it)] > lev, nrow = 3)
      counts <- colSums(greater)
      crossings <- which(counts %in% 1:2)
      if (length(crossings)) {
        greater <- greater[,crossings, drop = FALSE]
        counts <- counts[crossings]
        # Find the single vertex on one side of the contour
        # line (v1), and the other two on the other side
        # (v2, v3)
        r1 <- ifelse(counts == 1, 
                     apply(greater, 2, which.max),
                     apply(greater, 2, which.min))
        v1 <- obj$it[cbind(r1, crossings)]
        r2 <- r1 %% 3 + 1
        v2 <- obj$it[cbind(r2, crossings)]
        r3 <- (r1 + 1) %% 3 + 1
        v3 <- obj$it[cbind(r3, crossings)]
        p1 <- (lev - values[v2])/(values[v1] - values[v2])
        i1 <- p1*verts[v1,] + (1 - p1)*verts[v2,]
        p2 <- (lev - values[v3])/(values[v1] - values[v3])
        i2 <- p2*verts[v1,] + (1 - p2)*verts[v3,] 
        xyz <- matrix(t(cbind(i1, i2)), ncol = 3, byrow = TRUE)
        result <- rbind(result, data.frame(x = xyz[,1], y = xyz[,2], z = xyz[,3], fn = funnames[i], level = lev))
      }
    }
  }
  if (plot)
    segments3d(result, ...)
  else
    result
}
