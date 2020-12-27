# Support for objects from alphashape3d package

persp3d.ashape3d <- function(x, ..., add = FALSE) {
  plot3d(as.mesh3d(x, ...), add = add, ...)
}

plot3d.ashape3d <- function(x, ...) persp3d(x, ...)

reOrient <- function(vertices) {
  warned <- FALSE

  # Count how many other triangles touch each edge of this one, in order 2-3, 1-3, 1-2:
  edgeCounts <- function(index) {
    triangle <- vertices[,index]
    result <- integer(3)
    for (i in 1:3) {
      result[i] <- sum(apply(vertices, 2, function(col) all(triangle[-i] %in% col)))
    }
    result - 1
  }
  polys <- ncol(vertices)
  verts <- nrow(vertices)
  fixed <- 0L
  for (i in seq_len(polys - 1)) {
    fixed <- max(i, fixed)
    # Get all polygons touching polygon i
    thistriangle <- vertices[,i]
    if (any(is.na(thistriangle))) next
    touches <- which(matrix(vertices %in% thistriangle,nrow=3),  arr.ind = TRUE)
    if (!nrow(touches)) next
    counts <- table(touches[,2L])
    # Get col number of all polygons sharing an edge with i
    shared <- as.numeric(names(counts)[counts > 1L])
    shared <- shared[shared != i]
    if (!length(shared)) next
    otherverts <- vertices[, shared, drop=FALSE]
    
    # FIXME:  otherverts may include multiple triangles sharing the
    #         same edge, because ashape3d sometimes embeds 
    #         tetrahedrons (or larger polyhedra?) in the surfaces
    #         it produces.  It doesn't appear to be safe to just 
    #         delete these
    
    if (!warned && length(shared) > 1L && any( edgeCounts(i) > 1)) {
      warning("Surface may not be simple; smoothing may not be possible.")
      warned <- TRUE
    }
    
    shared <- shared[shared > fixed]
    if (!length(shared)) next
    
    otherverts <- vertices[, shared, drop=FALSE]
    
    for (m in seq_len(ncol(otherverts))) { # m is intersection number
      # For each vertex in i, see if it is in the shared one, and
      # if they have opposite orientations as we need
      for (j in seq_len(verts)) {
        # Where is j in the others?
        jother <- which(otherverts[,m] == vertices[j,i])
        if (!length(jother)) next
        k <- j %% verts + 1L               # k follows j
        kother <- jother  %% verts + 1L    # kother is entry following jother
        if (vertices[k, i] == otherverts[kother, m]) {
          otherverts[, m] <- rev(otherverts[, m])
          break
        }
      }
    }
    # Now move all of shared to the front
    unshared <- (fixed+1L):max(shared)
    unshared <- unshared[!(unshared %in% shared)]
    if (length(unshared))
      vertices[, (fixed+length(shared)+1L):max(shared)] <- vertices[,unshared]
    vertices[, fixed + seq_along(shared)] <- otherverts
    fixed <- fixed + length(shared)
  }
  vertices
}

as.mesh3d.ashape3d <- function(x, alpha = x$alpha[1], tri_to_keep = 2L,
                               col = "gray", smooth = FALSE,
                               normals = NULL, texcoords = NULL,
                               ...) {
  whichAlpha <- which(alpha == x$alpha)[1]
  if (!length(whichAlpha))
    stop("'alpha = ", alpha, "' not found in ", deparse(substitute(x)))
  triangles <- x$triang
  keep <- triangles[,8 + whichAlpha] %in% tri_to_keep
  triangs <- t(triangles[keep, 1:3])
  points <- t(x$x)
  if (!is.null(texcoords))
    texcoords <- texcoords[triangs, ]
  material <- .getMaterialArgs(...)
  material$color <- col
  result <- tmesh3d(points, triangs, homogeneous = FALSE,
                    normals = normals, texcoords = texcoords,
                    material = material)
  if (smooth) {
    if (is.null(normals)) {
      result$it <- reOrient(result$it)
      result <- addNormals(result)
    } else
      warning("smoothing ignored when 'normals' specified")
  }
  result 
}
