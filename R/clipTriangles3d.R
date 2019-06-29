clipTriangles3d <- function(triangles, fn, bound = 0, greater = TRUE, 
                            attributes = NULL) {
  isMesh <- FALSE
  if (inherits(triangles, "shape3d") || !is.numeric(triangles)) {
    shape <- triangles
    triangles <- as.triangles3d(triangles)
    if (inherits(shape, "mesh3d")) {
      isMesh <- TRUE
      if (!is.null(attributes))
        warning("'attributes' ignored for mesh objects")
      attributes <- attr(triangles, "indices")
    }
  }
  
  # triangles is 3m x 3:  each row is a point, triplets of rows are triangles
  stopifnot(is.numeric(triangles), 
            length(dim <- dim(triangles)) == 2, 
            dim[1] %% 3 == 0)
  if (is.function(fn)) {
    values <- fn(triangles)
    if (length(values) != nrow(triangles))
      stop("'fn' should return one value per vertex")
  } else {
    stopifnot(length(fn) == nrow(triangles))
    values <- fn
  }
  has_attributes <- !is.null(attributes)
  if (has_attributes) 
    if (is.null(nrow(attributes)))
      stopifnot(length(attributes) == nrow(triangles))
    else
      stopifnot(nrow(attributes) == nrow(triangles))
  values <- matrix(values - bound, 3)
  # values is m x 3:  each column is the fn value at one point
  # of a triangle
  if (!greater) 
    values <- -values
  keep <- values >= 0
  
  # counts is m vector counting number of points to keep in each triangle
  counts <- colSums(keep)
  # singles is set to all the columns of triangles where exactly one
  # point in the triangle is kept, say s x 3
  singles <- triangles[rep(counts == 1, each = 3),, drop = FALSE]
  if (has_attributes)
    index1 <- seq_len(nrow(triangles))[rep(counts == 1, each = 3)]
  if (length(singles)) {
    # theseValues is a subset of values where only one vertex is kept
    theseValues <- values[, counts == 1]
    s <- seq_len(ncol(theseValues))
    index <- 3*col(theseValues) + 1:3 - 3
    # good is the index of the vertex to keep, bad are those to fix
    good <- apply(theseValues, 2, function(col) which(col >= 0))
    bad <- apply(theseValues, 2, function(col) which(col < 0))
    goodvals <- theseValues[cbind(good, s)]
    for (i in 1:2) {
      badvals <- theseValues[cbind(bad[i,], s)]
      alphas <- goodvals/(goodvals - badvals)
      singles[index[cbind(bad[i,], s)], ] <-
          (1 - alphas)*singles[index[cbind(good, s)], ] +
          alphas *singles[index[cbind(bad[i,], s)], ]
    }
  }
  doubles <- doubles2 <- triangles[rep(counts == 2, each = 3),, drop = FALSE]
  if (has_attributes)
    index2a <- index2b <- seq_len(nrow(triangles))[rep(counts == 2, each = 3)]
  if (length(doubles)) {
    # theseValues is a subset of values where two vertices are kept
    theseValues <- values[, counts == 2]
    s <- seq_len(ncol(theseValues))
    index <- 3*col(theseValues) + 1:3 - 3
    # good is the index of the vertex to keep, bad are those to fix
    good <- apply(theseValues, 2, function(col) which(col >= 0))
    bad <- apply(theseValues, 2, function(col) which(col < 0))
    badvals <- theseValues[cbind(bad, s)]
    newvert <- list()
    for (i in 1:2) {
      goodvals <- theseValues[cbind(good[i,], s)]
      alphas <- goodvals/(goodvals - badvals)

      newvert[[i]] <- 
          (1-alphas)*doubles[index[cbind(good[i,], s)],] +
             alphas *doubles[index[cbind(bad, s)],]
    }
    doubles[index[cbind(bad, s)],] <- newvert[[1]]
    doubles2[index[cbind(good[1,], s)],] <- newvert[[1]]
    doubles2[index[cbind(bad, s)],] <- newvert[[2]]
  }
  # Finally add all the rows of triangles where the whole
  # triangle is kept
  result <- rbind(singles, doubles, doubles2, 
        triangles[rep(counts == 3, each = 3),, drop = FALSE])
  if (has_attributes) {
    index3 <- seq_len(nrow(triangles))[rep(counts == 3, each = 3)]
    attr(result, "attributes") <-
      if (is.null(nrow(attributes)))
        attributes[c(index1, index2a, index2b, index3)]
      else
        attributes[c(index1, index2a, index2b, index3),,drop = FALSE]
  }
  if (isMesh) {
    indices <- attr(result, "attributes")
    result <- tmesh3d(t(result), homogeneous = FALSE, indices = matrix(seq_len(nrow(result)), nrow = 3))
    if (!is.null(shape$normals)) result$normals <- shape$normals[, indices]
    if (!is.null(shape$texcoords)) result$texcoords <- shape$texcoords[, indices]
    if (!is.null(shape$material)) {
      material <- shape$material
      origlen <- ncol(shape$vb)
      if (length(material$color) > 1)
        material$color <- rep(material$color, length.out = origlen)[indices]
      if (length(material$alpha) > 1)
        material$alpha <- rep(material$alpha, length.out = origlen)[indices]
      result$material <- material
    }
    result
  } else
    structure(result, class = "triangles3d")
}

# # Togliatti surface equation: f(x,y,z) = 0
# f <- function(x,y,z){
# w <- 1
# 64*(x-w)*
# (x^4-4*x^3*w-10*x^2*y^2-4*x^2*w^2+16*x*w^3-20*x*y^2*w+5*y^4+16*w^4-20*y^2*w^2) -
# 5*sqrt(5-sqrt(5))*(2*z-sqrt(5-sqrt(5))*w)*(4*(x^2+y^2-z^2)+(1+3*sqrt(5))*w^2)^2
# }
# # make grid
# nx <- 220; ny <- 220; nz <- 220
# x <- seq(-5, 5, length=nx)
# y <- seq(-5, 5, length=ny)
# z <- seq(-4, 4, length=nz)
# g <- expand.grid(x=x, y=y, z=z)
# # calculate voxel
# voxel <- array(with(g, f(x,y,z)), dim = c(nx,ny,nz))
# 
# # compute isosurface
# surf <- computeContour3d(voxel, maxvol=max(voxel), level=0, x=x, y=y, z=z)
# 
# fn <- function(x) {
#   rowSums(x^2)
# }
# 
# drawScene.rgl(makeTriangles(clipTriangles3d(surf, fn, bound = 4.8^2, 
#                                          greater = FALSE), 
#                             smooth = TRUE))
