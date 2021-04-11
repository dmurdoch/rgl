as.tmesh3d <- function(mesh) {
  if (!is.null(mesh$ib)) {
    nquads <- ncol(mesh$ib)
    mesh$it <- cbind(mesh$it, 
                     matrix(mesh$ib[rep(4*(seq_len(nquads) - 1), each = 6) + 
                                      rep(c(1, 2, 3, 1, 3, 4), nquads)], nrow = 3))
    mesh$ib <- NULL
  }
  mesh
}

.getVertexFn <- function(fn, envir) {
  if (is.character(fn))
    fn <- switch(fn, 
                 x = function(xyz) xyz[,1],
                 y = function(xyz) xyz[,2],
                 z = function(xyz) xyz[,3],
                 get(fn, envir = envir, mode = "function"))
  # Accept functions that take x, y, z as parameters
  if (all(c("x", "y", "z") %in% names(formals(fn)))) {
    oldfn <- fn
    fn <- function(xyz) oldfn(x = xyz[,1], y = xyz[,2], z = xyz[,3])
  }
  fn
}

clipMesh3d <- function(mesh, fn = "z", bound = 0, greater = TRUE,
                       minVertices = 0, plot = FALSE, keepValues = FALSE) {
  stopifnot(inherits(mesh, "mesh3d"))
  # First, convert quads to triangles
  mesh <- as.tmesh3d(mesh)
  nverts <- ncol(mesh$vb)
  oldnverts <- nverts - 1
  while (nverts < minVertices && oldnverts < nverts && !is.numeric(fn)) {
    oldnverts <- nverts
    mesh <- subdivision3d(mesh, deform = FALSE, normalize = TRUE)
    nverts <- ncol(mesh$vb)
  }
  if (is.null(fn))
    fn <- mesh$values
  if (is.null(fn))
    stop("'fn' can only be NULL if 'mesh' contains values")
  if (is.numeric(fn)) 
    values <- fn
  else {
    fn <- .getVertexFn(fn, parent.frame())
    verts <- asEuclidean(t(mesh$vb))
    values <- fn(verts)
  }
  # The bound might be infinite, which messes up the arithmetic.
  # Force it to a finite value
  r <- range(values)
  delta <- max(abs(r))
  if (bound < r[1])
    bound <- r[1] - delta
  else if (bound > r[2])
    bound <- r[2] + delta
  
  values <- values - bound
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
          newrgb <- (1 - alphas)*rgb[, good[new],drop = FALSE] + alphas*rgb[, bad[new], drop = FALSE]
          mesh$material$color <<- c(mesh$material$color, 
                                   rgb(newrgb["red",], newrgb["green",], newrgb["blue",], maxColorValue = 255))
        }
        if (!is.null(mesh$material$alpha) && length(mesh$material$alpha) == ncol(mesh$vb))
          mesh$material$alpha <<- c(mesh$material$alpha,
                                    (1-alphas)*mesh$material$alpha[good[new]] +
                                        alphas*mesh$material$alpha[bad[new]])
        
      }
      values <<- c(values, rep(0, ncol(newverts)))
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
  if (plot)
    shade3d(mesh)
  else {
    if (keepValues) {
      if (!greater) values <- -values
      mesh$values <- values + bound
    }
    cleanMesh3d(mesh)
  }
}

cleanMesh3d <- function(mesh, onlyFinite = TRUE, allUsed = TRUE, rejoin = FALSE) {
  if (rejoin) {
    ntriangs <- ncol(mesh$it)
    oldntriangs <- ntriangs + 1
    while (ntriangs < oldntriangs) {
      oldntriangs <- ntriangs
      mesh <- rejoinMesh3d(mesh)
      ntriangs <- ncol(mesh$it)
    }    
  }
  nold <- ncol(mesh$vb)
  keep <- TRUE
  if (onlyFinite)
    keep <- keep & apply(mesh$vb, 2, function(col) all(is.finite(col)))
  if (allUsed)
    keep <- keep & (seq_len(nold) %in% c(mesh$it, mesh$ib))
  if (!all(keep)) {
    oldnums <- which(keep)
    newnums <- rep(NA, nold)
    nnew <- sum(keep)
    newnums[oldnums] <- seq_len(nnew)
    mesh$vb <- mesh$vb[,oldnums]
    if (!is.null(mesh$it)) {
      newcols <- newnums[mesh$it]
      dim(newcols) <- dim(mesh$it)
      keep <- apply(newcols, 2, function(col) all(!is.na(col)))
      mesh$it <- newcols[,keep]
    }
    if (!is.null(mesh$ib)) {
      newcols <- newnums[mesh$ib]
      dim(newcols) <- dim(mesh$ib)
      keep <- apply(newcols, 2, function(col) all(!is.na(col)))
      mesh$ib <- newcols[,keep]
    }
    if (!is.null(mesh$normals)) 
      mesh$normals <- mesh$normals[, oldnums]
    if (!is.null(mesh$texcoords)) 
      mesh$texcoords <- mesh$texcoords[, oldnums]
    if (!is.null(mesh$meshColor) && mesh$meshColor == "vertices" 
        && !is.null(mesh$material) 
        && length(mesh$material$color) == nold)
      mesh$material$color <- mesh$material$color[oldnums]
    if (!is.null(mesh$values))
      mesh$values <- mesh$values[oldnums]
  }
  mesh
}

subdivideLines <- function(x) {
  nverts <- nrow(x$vertices)
  newverts <- nverts
  indices <- rbind(seq_len(nverts), NA, NA)
  finite <- apply(x$vertices, 1, function(row) all(is.finite(row)))
  type <- x$type
  if (type == "lines") {
    for (j in 2*seq_len(nverts %/% 2)) {
      i <- j - 1
      if (finite[i] && finite[j]) {
        for (attr in c("vertices", "normals", "colors")) {
          if (!is.null(x[[attr]]) && nrow(x[[attr]]) > 1) {
            new <- (x[[attr]][i,] + x[[attr]][j,])/2
            while (nrow(x[[attr]]) < newverts + 2) 
              x[[attr]] <- rbind(x[[attr]], x[[attr]])
            x[[attr]][newverts + 1,] <- new
            x[[attr]][newverts + 2,] <- new
          }
        }
        indices[2, i] <- newverts + 1
        indices[3, i] <- newverts <- newverts + 2
      }
    }
  } else if (x$type == "linestrip") {
    for (j in seq_len(nverts)[-1]) {
      i <- j - 1
      if (finite[i] && finite[j]) {
        for (attr in c("vertices", "normals", "colors")) {
          if (!is.null(x[[attr]]) && nrow(x[[attr]]) > 1) {
            new <- (x[[attr]][i,] + x[[attr]][j,])/2
            while (nrow(x[[attr]]) < newverts + 1) 
              x[[attr]] <- rbind(x[[attr]], x[[attr]])
            x[[attr]][newverts + 1,] <- new
          }
        }
        indices[2, i] <- newverts <- newverts + 1
      }
    }
  }
  if (nverts < newverts) {
    indices <- c(indices)
    indices <- indices[!is.na(indices)]
    for (attr in c("vertices", "normals", "colors")) 
      if (!is.null(x[[attr]]) && nrow(x[[attr]]) > 1) 
        x[[attr]] <- x[[attr]][indices,,drop = FALSE]
  }
  x
}

# Undo subdivision for triangles
rejoinMesh3d <- function(x, tol = 1.e-6) {
  ntriangs <- ncol(x$it)
  if (ntriangs < 4)
    return(x)
  vals <- if (nrow(x$vb) == 4) asEuclidean(t(x$vb)) else t(x$vb)
  if (!is.null(x$normals))
    vals <- cbind(vals, if(nrow(x$normals) == 4) asEuclidean(t(x$normals)) else t(x$normals))
  if (!is.null(x$texcoords))
    vals <- cbind(vals, t(x$texcoords))
  indices <- seq_len(ntriangs)
  for (j in seq_len(ntriangs)[-(1:3)]) {
    i <- j - (3:0)
    verts <- c(x$it[,i])
    if ( !any(is.na(indices[i]))
      && verts[2] == verts[6]
      && verts[3] == verts[8]
      && verts[5] == verts[9]
      && verts[6] == verts[11]
      && verts[8] == verts[10]
      && verts[9] == verts[12] 
      && !(verts[1] %in% verts[-1]) 
      && !(verts[4] %in% verts[-4])
      && !(verts[7] %in% verts[-7])) {
        v1 <- verts[c(1,4,7,2,3,5)]
        diffs <- c(vals[v1[1],] - vals[v1[2],],
                   vals[v1[1],] - vals[v1[3],],
                   vals[v1[2],] - vals[v1[3],])
        use <- !is.na(diffs) & diffs > tol
        if (any(use)) {
          p <- c(vals[v1[1],] - vals[v1[4],],
                 vals[v1[1],] - vals[v1[5],],
                 vals[v1[2],] - vals[v1[6],])[use]/diffs[use]
          if (max(abs(p - 0.5)) < tol) {
            # Found one!
            indices[i[-1]] <- NA
            x$it[,i[1]] <- c(v1[1], v1[2], v1[3])
          }
        }
    }
  }
  indices <- indices[!is.na(indices)]
  x$it <- x$it[,indices]
  x
}

rejoinLines3d <- function(x, tol = 1.e-6) {
  nverts <- nrow(x$vertices)
  indices <- seq_len(nverts)
  finite <- apply(x$vertices, 1, function(row) all(is.finite(row)))
  type <- x$type
  hasattrs <- character()
  for (attr in c("vertices", "normals", "colors")) 
    if (!is.null(x[[attr]]) && nrow(x[[attr]]) > 1) 
      hasattrs <- c(hasattrs, attr)
  if (type == "lines") {
    for (j in 2*seq_len(nverts %/% 2)[-1]) {
      i <- j - (3:0)
      if (all(finite[i])) {
        attrs <- matrix(numeric(), nrow = 4, ncol = 0)
        for (attr in hasattrs) 
          attrs <- cbind(attrs, x[[attr]][i,])
        diff <- attrs[4,] - attrs[1,]
        use <- !is.na(diff) & abs(diff) > tol
        p <- c((attrs[2,use] - attrs[1,use])/diff[use],
               (attrs[3,use] - attrs[1,use])/diff[use])
        if (all(!is.na(p) & p >= 0 & p <= 1)
            && diff(range(p)) < tol) {
          # pts 2 & 3 are equal and are exactly between
          # pts 1 & 4.  Merge them into 3,4.
          for (attr in hasattrs) 
            x[[attr]][i[3],] <- x[[attr]][i[1],]
          indices[i[1:2]] <- NA  
        }
      }
    }
  } else if (type == "linestrip") {
    for (j in seq_len(nverts)[-(1:2)]) {
      i <- j - (2:0)
      if (all(finite[i])) {
        attrs <- matrix(numeric(), nrow = 3, ncol = 0)
        for (attr in hasattrs) 
          attrs <- cbind(attrs, x[[attr]][i,])
        diff <- attrs[3,] - attrs[1,]
        use <- !is.na(diff) & abs(diff) > tol
        p <- (attrs[2,use] - attrs[1,use])/diff[use]
        if (all(!is.na(p) & p >= 0 & p <= 1)
            && diff(range(p)) < tol) {
          # pt 2 is exactly between
          # pts 1 & 3.  Move 1 there.
          for (attr in hasattrs) 
            x[[attr]][i[2],] <- x[[attr]][i[1],]
          indices[i[1]] <- NA  
        }
      }
    }
  }
  if (anyNA(indices)) {
    indices <- indices[!is.na(indices)]
    for (attr in hasattrs)
      x[[attr]] <- x[[attr]][indices,]
  }
  x
}

clipObj3d <- function(ids, fn, bound = 0, greater = TRUE,
                      minVertices = 0,
                      replace = TRUE) {
  getValues <- function(obj) {
    verts <- obj$vertices
    nverts <- nrow(verts)
    values <- rep(NA_real_, nverts)
    finite <- apply(verts, 1, function(row) all(is.finite(row)))
    values[finite] <- fn(verts[finite,]) - bound
    if (!greater) values <- -values
    values
  }
  getKeep <- function(values) {
    !is.na(values) & values > 0
  }
  applyKeep <- function() {
    for (attr in c("vertices", "normals", "colors",
                   "texcoords", "centers", "adj"))
      if (!is.null(obj[[attr]]) &&
          nrow(obj[[attr]]) > 1) 
        obj[[attr]] <- obj[[attr]][keep,,drop = FALSE]
    for (attr in c("texts", "cex", "adj", 
                   "radii", "ids", "types", 
                   "flags", "offsets", "pos"))
      if (length(obj[[attr]]) > 1)
        obj[[attr]] <- obj[[attr]][keep] 
    obj
  }
  scene <- scene3d()
  if (missing(ids))
    ids <- names(scene$objects)
  names <- names(ids)
  ids <- as.character(ids)
  result <- integer()
  minVertices <- rep(minVertices, length.out = length(ids))
  names(minVertices) <- ids
  fn <- .getVertexFn(fn, parent.frame())
  for (id in ids) {
    obj <- scene$objects[[id]]
    type <- obj$type
    nverts <- nrow(obj$vertices)
    newid <- NA
    switch(type,
           triangles=,
           quads=,
           planes=,
           surface= {
             mesh <- as.mesh3d(obj)
             mesh <- cleanMesh3d(mesh)
             clipped <- clipMesh3d(mesh, fn, bound, greater,
                                   minVertices[id])
             clipped <- cleanMesh3d(clipped, rejoin = TRUE)
             newid <- shade3d(clipped, override = FALSE)
           }, 
           points =,
           text =,
           spheres =,
           sprites = {
             keep <- getKeep(getValues(obj))
             if (!all(keep)) {
               obj <- applyKeep()
               newid <- plot3d(obj)
             }
           },
           lines = {
             oldnverts <- nverts - 1
             while (nverts < minVertices[id] && nverts > oldnverts) {
               oldnverts <- nverts
               obj <- subdivideLines(obj)
               nverts <- nrow(obj$vertices)
             }
             values <- getValues(obj)
             keep <- getKeep(values)
             if (!all(keep)) {
               for (j in 2*seq_len(nverts %/% 2)) {
                 i <- j - 1
                 if (is.na(values[i]) || is.na(values[j])) {
                   keep[i] <- keep[j] <- FALSE
                 } else if (!keep[i] && !keep[j]) {# no change
                 } else if (!keep[i]) {
                   p <- 1 - abs(values[i])/(abs(values[i]) + values[j])
                   obj$vertices[i,] <- p*obj$vertices[i,] + (1-p)*obj$vertices[j,]
                   keep[i] <- TRUE
                 } else if (!keep[j]) {
                   p <- 1 - abs(values[j])/(abs(values[j]) + values[i])
                   obj$vertices[j,] <- p*obj$vertices[j,] + (1-p)*obj$vertices[i,]
                   keep[j] <- TRUE
                 }
               }
               obj <- applyKeep()
               obj <- rejoinLines3d(obj)
               newid <- plot3d(obj)
             }
           },
           linestrip = {
             oldnverts <- nverts - 1
             while (nverts < minVertices[id] && nverts > oldnverts) {
               oldnverts <- nverts
               obj <- subdivideLines(obj)
               nverts <- nrow(obj$vertices)
             }
             newverts <- nverts
             values <- getValues(obj)
             if (!all(values >= 0, na.rm = TRUE)) {
               hasattrs <- character()
               for (attr in c("vertices", "normals", "colors"))
                 if (!is.null(obj[[attr]]) && nrow(obj[[attr]]) > 1)
                   hasattrs <- c(hasattrs, attr)
                 indices <- rbind(seq_len(nverts), NA, NA)
                 for (j in seq_len(nverts)[-1]) {
                   i <- j - 1
                   # There are lots of cases to consider here.
                   # We could have a point that was already ignored
                   # to create a gap in the linestrip, a point
                   # that should be deleted because it is outside the
                   # range, or a point that should be kept.  These
                   # have value NA, negative, or non-negative respectively.
                   # The 9 cases are handled as follows (assuming we
                   # go through (i, j=i+1) pairs in sequence):
                   # i  j  disposition
                   # NA NA drop i, keep j
                   # NA  - drop i, keep j
                   # NA  + keep both
                   # -  NA drop i, keep j
                   # -   - drop i, keep j unless it is last
                   # -   + change i to NA (unless it's first, then drop it), insert interpolant, keep j
                   # +  NA keep both
                   # +   - keep i, insert interpolant then NA, move to j
                   # +   + keep both
                   if (is.na(values[i])) {
                     if (is.na(values[j]) || values[j] < 0) 
                       indices[1,i] <- NA
                   } else if (values[i] < 0) {
                     if (is.na(values[j]) || values[j] < 0)
                       indices[1,i] <- NA
                     else {
                       indices[2,i] <- newverts + 1
                       p <- 1 - abs(values[i])/(abs(values[i]) + values[j])
                       for (attr in hasattrs) {
                         while (nrow(obj[[attr]]) < newverts + 1)
                           obj[[attr]] <- rbind(obj[[attr]], obj[[attr]])
                         new <- p*obj[[attr]][i,] + (1-p)*obj[[attr]][j,]
                         obj[[attr]][newverts + 1,] <- new
                       }
                       newverts <- newverts + 1
                       obj$vertices[i,] <- NA
                       if (j == 2)
                         indices[1,i] <- NA
                     }
                   } else {
                     if (!is.na(values[j]) && values[j] < 0) {
                       indices[2,i] <- newverts + 1
                       indices[3,i] <- newverts + 2
                       p <- 1 - abs(values[j])/(abs(values[j]) + values[i])
                       obj$vertices <- rbind(obj$vertices, 
                                             p*obj$vertices[j,] + (1-p)*obj$vertices[i,],
                                             c(NA, NA, NA))
                       for (attr in hasattrs) {
                         while (nrow(obj[[attr]]) < newverts + 2)
                           obj[[attr]] <- rbind(obj[[attr]], obj[[attr]])
                         new <- p*obj[[attr]][j,] + (1-p)*obj[[attr]][i,]
                         obj[[attr]][newverts+1,] <- new
                         obj[[attr]][newverts+2,] <- NA
                       }
                       newverts <- newverts + 2
                       if (j == nverts)
                         indices[1,j] <- NA                   
                     }
                   }
                 }
                 indices <- c(indices)
                 indices <- indices[!is.na(indices)]
                 for (attr in hasattrs) 
                   obj[[attr]] <- obj[[attr]][indices,,drop = FALSE]
             }
             obj <- rejoinLines3d(obj)
             newid <- plot3d(obj)
           }
    )
    if (!is.na(newid)) {
      result[id] <- newid
      if (replace)
        pop3d(id = id)
    } else
      result[id] <- as.integer(id)
  }
  if (!is.null(names))
    names(result) <- names
  rglId(result)
}
