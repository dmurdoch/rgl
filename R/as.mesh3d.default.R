as.mesh3d.default <- function(x, y = NULL, z = NULL, 
                              triangles = length(x) %% 3 == 0,   
                              smooth = FALSE, 
                              tolerance = sqrt(.Machine$double.eps),
                              notEqual = NULL,
                              merge = TRUE,
                              ...) {
  if (missing(x)) {
    x <- rglId(rgl.ids()$id)
    return(as.mesh3d(x, ...))
  }
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

as.mesh3d.rglId <- function(x, type = NA, subscene = NA, 
                            ...) {
  local_t <- function(x) {
    if (!is.null(x)) t(x)
  }
  ids <- rgl.ids(subscene = subscene)
  ids <- ids[ids$id %in% x,]
  if (!is.na(type))
    ids <- ids[ids$type %in% type,]
  indices <- NULL
  vertices <- NULL
  normals <- NULL
  texcoords <- NULL
  material <- NULL
  for (i in seq_len(NROW(ids))) {
    id <- ids[i, "id"]
    verts <- rgl.attrib(id, "vertices")
    nvert <- NROW(verts)
    if (nvert) {
      type <- ids[i, "type"]
      inds <- switch(as.character(type),
                     triangles =,
                     planes = matrix(1:nvert, nrow = 3),
                     quads = {
                       nquads <- nvert/4
                       matrix(4*rep(seq_len(nquads) - 1, each = 6) + c(1,2,3,1,3,4), nrow = 3)
                     },
                     surface = {
                       dim <- rgl.attrib(id, "dim")
                       ul <- rep(2:dim[1], dim[2]-1) + dim[1]*rep(0:(dim[2]-2), each=dim[1]-1)
                       if (rgl.attrib(id, "flags")["flipped",])
                         rbind(c(ul-1, ul-1+dim[1]),
                                 c(ul, ul),
                                 c(ul-1+dim[1], ul+dim[1]))
                       else
                         rbind(c(ul, ul),
                                 c(ul-1, ul-1+dim[1]),
                                 c(ul-1+dim[1], ul+dim[1]))
                     },
                     NULL)
      if (NCOL(inds)) {
        indices <- cbind(indices, inds)
        vertices <- cbind(vertices, local_t(rgl.attrib(id, "vertices")))
        normals <- rbind(normals, rgl.attrib(id, "normals"))
        if (rgl.attrib.count(id,"texcoords"))
          texcoords <- rbind(texcoords, rgl.attrib(id, "texcoords"))
        mat <- rgl.getmaterial(nvert, id = id)
        if (is.null(material))
          material <- mat
        else if (!isTRUE(all.equal(mat, material)))
          warning("Only first material used")
      }
    }
  }
  if (NCOL(vertices))
    tmesh3d(vertices, indices, homogeneous = FALSE, material = material,
            normals = normals, texcoords = texcoords)
}

mergeVertices <- function(mesh, notEqual = NULL, attribute = "vertices",
                          tolerance = sqrt(.Machine$double.eps)) {
  nvert <- ncol(mesh$vb)
  if (!is.null(notEqual)) {
    dim <- dim(notEqual)
    if (length(dim) != 2 || dim[1] != nvert || dim[2] != nvert)
      stop("'notEqual' should be a ", nvert, " by ", nvert, " logical matrix.")
    notEqual <- notEqual | t(notEqual) # Make it symmetric
  }
  attribute <- match.arg(attribute, 
                          choices = c("vertices", "colors", "normals", "texcoords"),
                          several.ok = TRUE)
  verts <- matrix(numeric(), ncol = 0, nrow = nvert)
  if ("vertices" %in% attribute) 
    verts <- cbind(mesh$vb[1,]/mesh$vb[4,],
                   mesh$vb[2,]/mesh$vb[4,],
                   mesh$vb[3,]/mesh$vb[4,])
  if (!is.null(normals <- mesh$normals) && "normals" %in% attribute)
    if (nrow(normals) == 3)
      verts <- cbind(verts, t(normals))
    else
      verts <- cbind(verts, normals[1,]/normals[4,], 
                            normals[2,]/normals[4,],
                            normals[3,]/normals[4,])
  colors <- NULL
  if (!is.null(mesh$material) && !is.null(colors <- mesh$material$color)
      && "colors" %in% attribute)
      verts <- cbind(verts, t(col2rgb(colors)))
  if (!is.null(texcoords <- mesh$texcoords) && "texcoords" %in% attribute)
    verts <- cbind(verts, t(texcoords))
  
  o <- do.call(order, as.data.frame(verts))
  indices <- c(mesh$it, mesh$ib)
  i1 <- seq_len(nvert)[o]
  for (i in seq_len(nvert)[-1]) {
    if (isTRUE(all.equal(verts[i1[i-1],], verts[i1[i],], tolerance = tolerance))
        && (is.null(notEqual) || !isTRUE(notEqual[i1[i-1], i1[i]]))) {
      notEqual[i1[i], ] <- notEqual[i1[i-1], ] <- notEqual[i1[i], ] | notEqual[i1[i-1], ]
      notEqual[, i1[i]] <- notEqual[, i1[i-1]] <- notEqual[i1[i], ] | notEqual[, i1[i-1]]
      i1[i] <- i1[i-1]
    }
  }
  indices <- i1[order(o)][indices]
  keep <- sort(unique(i1))
  newvals <- numeric(nvert)
  newvals[keep] <- seq_along(keep)
  indices <- newvals[indices]
  mesh$vb <- mesh$vb[,keep]
  if (!is.null(normals))
    mesh$normals <- normals[, keep]
  if (!is.null(texcoords))
    mesh$texcoords <- texcoords[, keep]
  if (!is.null(colors))
    mesh$material$color <- colors[keep]
  
  if (ntri <- length(mesh$it)) 
    mesh$it <- matrix(indices[seq_len(ntri)], nrow = 3)
  if (length(mesh$ib)) 
    mesh$ib <- matrix(indices[seq_len(length(indices) - ntri) + ntri], nrow = 4)
  mesh
}