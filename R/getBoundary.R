getBoundary <- function(mesh, sorted = FALSE) {
  if (!inherits(mesh, "mesh3d"))
    stop(deparse(substitute(mesh)), " is not a mesh3d object.")
  edges <- NULL
  if (length(mesh$it))
    edges <- cbind(edges, mesh$it[1:2,],  mesh$it[2:3,], mesh$it[c(3,1),])
  if (length(mesh$ib))
    edges <- cbind(edges, mesh$ib[1:2,], mesh$ib[2:3,], mesh$ib[3:4,], mesh$ib[c(4,1)])
  if (ncol(edges)) {
    # undirect the edges
    uedges <- t(apply(edges, 2, sort))
    dup <- duplicated(uedges) | duplicated(uedges, fromLast = TRUE)
    edges <- edges[,!dup,drop=FALSE]
    if (sorted) {
      order <- rep(NA, ncol(edges))
      order[1] <- 1
      for (i in seq_len(length(order) - 1)) {
        j <- which(edges[1,] == edges[2, order[i]])
        j <- setdiff(j, order[1:i])
        if (length(j))
          order[i+1] <- j[1]
        else
          order[i+1] <- setdiff(1:length(order), order[1:i])
      }
      edges <- edges[, order, drop = FALSE]
    }
    result <- mesh3d(vertices = mesh$vb, segments = edges)
    cleanMesh3d(result)
  }
}