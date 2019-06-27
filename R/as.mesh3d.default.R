as.mesh3d.default <- function(x, y = NULL, z = NULL, 
                              triangles = length(x) %% 3 == 0,   
                              smooth = FALSE, 
                              tolerance = sqrt(.Machine$double.eps),
                              notEqual = NULL,
                              merge = TRUE,
                              ...) {
  xyz <- xyz.coords(x, y, z, recycle = TRUE)
  x <- xyz$x
  y <- xyz$y
  z <- xyz$z
  if (triangles) 
    stopifnot(length(x) %% 3 == 0)
  else
    stopifnot(length(x) %% 4 == 0)
  nvert <- length(x)
  verts <- rbind(x, y, z)
  indices <- matrix(seq_along(x), nrow = if (triangles) 3 else 4)
  
  if (merge) {
    if (!is.null(notEqual)) {
      dim <- dim(notEqual)
      if (length(dim) != 2 || dim[1] != nvert || dim[2] != nvert)
        stop("'notEqual' should be a ", nvert, " by ", nvert, " logical matrix.")
      notEqual <- notEqual | t(notEqual) # Make it symmetric
    }
    o <- order(x, y, z)
    i1 <- seq_len(nvert)[o]
    for (i in seq_len(nvert)[-1]) {
      if (isTRUE(all.equal(verts[,i1[i-1]], verts[,i1[i]], tolerance = tolerance))
          && (is.null(notEqual) || !isTRUE(notEqual[i1[i-1], i1[i]]))) {
        indices[indices == i1[i]] <- i1[i-1]
        notEqual[i1[i], ] <- notEqual[i1[i-1], ] <- notEqual[i1[i], ] | notEqual[i1[i-1], ]
        notEqual[, i1[i]] <- notEqual[, i1[i-1]] <- notEqual[i1[i], ] | notEqual[, i1[i-1]]
        i1[i] <- i1[i-1]
      }
    }
    i1 <- sort(unique(i1))
    keep <- seq_along(i1)
    for (i in keep) {
      verts[,i] <- verts[,i1[i]]
      indices[indices == i1[i]] <- i
    }
  } else
    keep <- seq_len(ncol(verts))
  if (triangles)
    mesh <- tmesh3d(verts[,keep], indices, homogeneous = FALSE,
                    material = list(...)) 
  else
    mesh <- qmesh3d(verts[,keep], indices, homogeneous = FALSE,
                    material = list(...))
  if (smooth)
    mesh <- addNormals(mesh)
  mesh
}

as.mesh3d.rglId <- function(x, subscene = NA, ...) {
  result <- as.mesh3d(as.triangles3d(x, subscene = subscene), merge = FALSE)
  if (NROW(normals <- as.triangles3d(x, "normals", subscene = subscene)))
    result$normals <- t(normals)
  if (NROW(texcoords <- as.triangles3d(x, "texcoords", subscene = subscene)))
    result$texcoords <- t(texcoords)
  result$material <- rgl.getmaterial(1, id = x)
  if (NROW(colors <- as.triangles3d(x, "colors", subscene = subscene))) {
    result$material$color <- rgb(colors[,"r"], colors[,"g"], colors[,"b"])
    if (length(unique(result$material$color)) == 1)
      result$material$color <- result$material$color[1]
    result$material$alpha <- colors[,"a"]
    if (length(unique(colors[,"a"])) == 1)
      result$material$alpha <- colors[1,"a"]
    else
      result$material$alpha <- colors[,"a"]
  }
  result
}