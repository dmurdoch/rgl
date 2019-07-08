clipMesh3d <- function(mesh, fn, bound = 0, greater = TRUE,
                            attribute = "vertices") {
  stopifnot(inherits(mesh, "mesh3d"))
  # First, convert quads to triangles
  if (!is.null(mesh$ib)) {
    nquads <- ncol(mesh$ib)
    mesh$it <- cbind(mesh$it, 
                     matrix(mesh$ib[rep(4*(seq_len(nquads) - 1), each = 6) + 
                              rep(c(1, 2, 3, 1, 3, 4), nquads)], nrow = 3))
    mesh$ib <- NULL
  }

  attribute <- match.arg(attribute, c("vertices", "normals", "texcoords", "index"), several.ok = TRUE)
  if (is.numeric(fn))
    values <- fn
  else {
    arg <- NULL
    for (a in attribute) 
      arg <- cbind(arg, 
                   switch(a,
                          vertices = t(mesh$vb[1:3,])/mesh$vb[4,],
                          normals = if (nrow(mesh$normals) == 4)
                            t(mesh$normals[1:3,])/mesh$normals[4,]
                          else
                            t(mesh$normals),
                          texcoords = t(mesh$texcoords),
                          index = seq_len(ncol(mesh$vb))))
    values <- fn(arg) - bound
  }
  if (!greater)
    values <- -values
  
  if (length(values) != ncol(mesh$vb))
    stop("'fn' should give one value per vertex")
  
  if (anyNA(values))
    stop("'fn' should not include NA values")
  
  # Now, set all w values to 1
  mesh$vb <- t( cbind(t(mesh$vb[1:3,])/mesh$vb[4,], 1))
  if (!is.null(mesh$normals) && nrow(mesh$normals) == 4)
    mesh$normals <- t(t(mesh$normals[1:3,])/mesh$normals[4,])
  
  newVertices <- integer()
  getNewVertex <- function(good, bad) {
    names <- paste0(good, "_", bad)
    new <- which(!(names %in% names(newVertices)))
    if (length(new)) {
      goodvals <- values[good[new]]
      badvals <- values[bad[new]]
      alphas <- goodvals/(goodvals - badvals)
      newverts <- t((1 - alphas)*t(mesh$vb[, good[new]]) + alphas*t(mesh$vb[, bad[new]]))
      newvertnums <- seq_len(ncol(newverts)) + ncol(mesh$vb)
      if (!is.null(mesh$normals)) 
        mesh$normals <<- cbind(mesh$normals, t((1 - alphas)*t(mesh$normals[, good[new]]) +
                                             alphas*t(mesh$normals[, bad[new]])))
      if (!is.null(mesh$texcoords))
        mesh$texcoords <<- cbind(mesh$texcoords, t((1 - alphas)*t(mesh$texcoords[, good[new]]) +
                                             alphas*t(mesh$texcoords[, bad[new]])))
      if (!is.null(mesh$material)) {
        if (!is.null(mesh$material$color) && length(mesh$material$color) == ncol(mesh$vb)) {
          rgb <- col2rgb(mesh$material$color)
          newrgb <- (1 - alphas)*rgb[, good[new]] + alphas*rgb[, bad[new]]
          mesh$material$color <<- c(mesh$material$color, 
                                   rgb(newrgb["red",], newrgb["green",], newrgb["blue",], maxColorValue = 255))
        }
        if (!is.null(mesh$material$alpha) && length(mesh$material$alpha) == ncol(mesh$vb))
          mesh$material$alpha <<- c(mesh$material$alpha,
                                    (1-alphas)*mesh$material$alpha[good[new]] +
                                        alphas*mesh$material$alpha[bad[new]])
        
      }
      mesh$vb <<- cbind(mesh$vb, newverts)
      newVertices[names[new]] <<- newvertnums
    }
    newVertices[names]
  }
  keep <- values >= 0
  keept <- matrix(keep[mesh$it], nrow = 3)
  counts <- colSums(keept)  # Number of vertices to keep for each triangle
  singles <- which(counts == 1)
  if (length(singles)) {
    theseTriangles <- mesh$it[, singles, drop = FALSE]
    goodRow <- apply(keept[, singles, drop = FALSE], 2, function(col) which(col))
    allcols <- seq_len(ncol(theseTriangles))
    goodVertex <- theseTriangles[cbind(goodRow, allcols)]
    badVertex1 <- theseTriangles[cbind(goodRow %% 3 + 1, allcols)]
    badVertex2 <- theseTriangles[cbind((goodRow + 1) %% 3 + 1, allcols)]
    mesh$it[cbind(goodRow %% 3 + 1, singles)] <- 
      getNewVertex(goodVertex, badVertex1)
    mesh$it[cbind((goodRow + 1) %% 3 + 1, singles)] <-
      getNewVertex(goodVertex, badVertex2)
  }
  doubles <- which(counts == 2)
  if (length(doubles)) {
    theseTriangles <- mesh$it[, doubles, drop = FALSE]
    badRow <- apply(keept[, doubles, drop = FALSE], 2, function(col) which(!col))
    allcols <- seq_len(ncol(theseTriangles))
    badVertex <- theseTriangles[cbind(badRow, allcols)]
    goodVertex1 <- theseTriangles[cbind(badRow %% 3 + 1, allcols)]
    goodVertex2 <- theseTriangles[cbind((badRow + 1) %% 3 + 1, allcols)]
    newVertex1 <- getNewVertex(goodVertex1, badVertex)
    newVertex2 <- getNewVertex(goodVertex2, badVertex)
    mesh$it[cbind(badRow, doubles)] <- newVertex1
    mesh$it <- cbind(mesh$it, rbind(newVertex1, goodVertex2, newVertex2))
  }
  zeros <- which(counts == 0)
  if (length(zeros))
    mesh$it <- mesh$it[, -zeros]
  mesh
}

