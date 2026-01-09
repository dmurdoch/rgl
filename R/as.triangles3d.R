as.triangles3d <- function(obj, ...) 
  UseMethod("as.triangles3d")

as.triangles3d.mesh3d <- function(obj, attribute = c("vertices", "normals", "texcoords",
                                                     "colors"),
                                  ...) {
  indices <- NULL
  if (!is.null(obj$it)) {
    indices <- c(obj$it)
  } 
  if (!is.null(obj$ib)) {
    indices <- c(indices, c(obj$ib[1:3,], obj$ib[c(1,3,4),]))
  }
  if (!is.null(indices)) 
    switch(match.arg(attribute),
           vertices = t(obj$vb[1:3, indices])/obj$vb[4,indices],
           normals  = if (!is.null(obj$normals))
             if (nrow(obj$normals) == 4)
               t(obj$normals[1:3, indices]/obj$normals[4,indices])
             else
               t(obj$normals[, indices]),
           texcoords = if (!is.null(obj$texcoords))
             t(obj$texcoords[, indices]),
           colors = if (!is.null(obj$material) && !is.null(obj$material$color)) {
             col <- t(col2rgb(rep(obj$material$color, length.out = max(indices))))
             alpha <- if (is.null(obj$material$alpha)) 1
             else obj$material$alpha
             alpha <- rep(alpha, length.out = max(indices))
             cbind(col, alpha)[indices,]
           })
}

as.triangles3d.rglId <- function(obj, 
                                 attribute = c("vertices", "normals", "texcoords",
                                               "colors"),
                                 subscene = NA,
                                 ...) {
  attribute <- match.arg(attribute)
  ids <- ids3d(subscene = subscene)
  ids <- ids[ids$id %in% obj,]
  result <- NULL
  for (i in seq_len(nrow(ids))) {
    id <- ids[i, "id"]
    nvert <- getExpandedNverts(id)
    attrib <- expandAttrib(id, attribute)
    if (nrow(attrib)) {
      if (nrow(attrib) < nvert)
        attrib <- apply(attrib, 2, function(col) rep(col, length.out = nvert))
      type <- ids[i, "type"]
      result <- rbind(result, switch(as.character(type),
        triangles =,              
        planes = attrib,
        surface =,
        quads = {
          nquads <- nrow(attrib)/4
          attrib[4*rep(seq_len(nquads) - 1, each = 6) + c(1,2,3,1,3,4),,drop=FALSE]
        }, 
        NULL))
    }
  }
  result
}
