as.triangles3d <- function(obj, ...) 
  UseMethod("as.triangles3d")

as.triangles3d.shapelist3d <- function(obj, ...) {
  structure(do.call(rbind, lapply(obj, as.triangles3d, ...)),
            class = "triangles3d")
}

as.triangles3d.mesh3d <- function(obj, ...) {
  indices <- NULL
  if (!is.null(obj$it)) {
    indices <- c(obj$it)
    xyz <- t(obj$vb[1:3, indices])/obj$vb[4,indices]
  } else
    xyz <- NULL
  if (!is.null(obj$ib)) {
    newindices <- c(obj$ib[1:3,], obj$ib[c(1,3,4),])
    xyz <- rbind(xyz, t(obj$vb[1:3, newindices])/obj$vb[4, newindices])
    indices <- c(indices, newindices)
  }
  structure(xyz, class = "triangles3d", indices = indices)
}

as.triangles3d.triangles3d <- function(obj, ...)
  obj

as.triangles3d.default <- function(obj, ...) {
  if (is.matrix(obj)) {
    # Assume object is a quads3d object
    nrows <- nrow(obj)
    stopifnot(nrows %% 4 == 0)
    nquads <- nrows/4
    indices <- rep(4*(seq_len(nquads) - 1), each = 6) + rep(c(1, 2, 3, 1, 3, 4), nquads)
    structure(obj[indices,], class = "triangles3d", indices = indices)
  } else
    stop("Do not know how to convert object of class ", paste(class(obj), collapse=","))
}

as.triangles3d.rglId <- function(obj, 
                                 attribute = c("vertices", "normals", "texcoords",
                                               "colors"),
                                 subscene = NA,
                                 ...) {
  attribute <- match.arg(attribute)
  ids <- rgl.ids(subscene = subscene)
  ids <- ids[ids$id %in% obj,]
  result <- NULL
  for (i in seq_len(nrow(ids))) {
    id <- ids[i, "id"]
    nvert <- rgl.attrib.count(id, "vertices")
    attrib <- rgl.attrib(id, attribute)
    if (nrow(attrib)) {
      if (nrow(attrib) < nvert)
        attrib <- apply(attrib, 2, function(col) rep(col, len = nvert))
      type <- ids[i, "type"]
      result <- rbind(result, switch(as.character(type),
        triangles =,              
        planes = attrib,
        quads = {
          nquads <- nrow(attrib)/4
          attrib[4*rep(seq_len(nquads) - 1, each = 6) + c(1,2,3,1,3,4),,drop=FALSE]
        },
        surface = {
          dim <- rgl.attrib(id, "dim")
          ul <- rep(2:dim[1], dim[2]-1) + dim[1]*rep(0:(dim[2]-2), each=dim[1]-1) 
          if (rgl.attrib(id, "flags")["flipped",]) 
            indices <- c(rbind(c(ul-1, ul-1+dim[1]),
                               c(ul, ul), 
                               c(ul-1+dim[1], ul+dim[1])))
          else
            indices <- c(rbind(c(ul, ul), 
                               c(ul-1, ul-1+dim[1]),
                               c(ul-1+dim[1], ul+dim[1])))

          attrib[indices,,drop = FALSE]
        }, 
        NULL))
    }
  }
  result
}
