as.mesh3d.default <- function(x, y = NULL, z = NULL, 
                              triangles = length(x) %% 3 == 0,   
                              smooth = FALSE, 
                              tolerance = sqrt(.Machine$double.eps),
                              notEqual = NULL,
                              merge = TRUE,
                              ...) {
  if (missing(x)) {
    x <- rglId(ids3d()$id)
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
    } else
      notEqual <- matrix(FALSE, nvert, nvert)
    o <- order(x, y, z)
    i1 <- seq_len(nvert)[o]
    for (i in seq_len(nvert)[-1]) {
      if (isTRUE(all.equal(verts[,i1[i-1]], verts[,i1[i]], tolerance = tolerance))
          && (!isTRUE(notEqual[i1[i-1], i1[i]]))) {
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
  
  colorByFaces <- function(mesh) {
    # See if we can use meshColor = "faces"
    if (is.null(mesh$ip) && is.null(mesh$is) && is.null(mesh$ib)
        && !is.null(mesh$material) && !is.null(mesh$meshColor)
        && mesh$meshColor == "vertices") {
      cols <- mesh$material$color
      if (length(cols) == 1)
        cols <- rep(cols, len = ncol(mesh$vb))
      cols <- matrix(cols[mesh$it], nrow = 3)
      alpha <- mesh$material$alpha
      if (length(alpha) == 1)
        alpha <- rep(alpha, len = ncol(mesh$vb))
      alpha <- matrix(alpha[mesh$it], nrow = 3)
      if (all(apply(cols, 2, function(col) length(unique(col))) == 1) &&
          all(apply(alpha, 2, function(a) length(unique(a))) == 1)) {
        mesh$meshColor <- "faces"
        mesh$material$color <- cols[1,]
        mesh$material$alpha <- alpha[1,]
      }
    }
    mesh
  }
  
  mergeMaterials <- function(oldmat, newmat, n, type) {
    if (length(newmat$color) == 1)
      newmat$color <- rep(newmat$color, len = n)
    if (length(newmat$alpha) == 1)
      newmat$alpha <- rep(newmat$alpha, len = n)
    # meshColor isn't a material property, but put it here
    # for now...
    newmat$meshColor <- "vertices"
    if (is.null(oldmat))
      result <- newmat
    else {
      cols <- c(oldmat$color, newmat$color)
      oldmat$color <- newmat$color <- NULL
      alpha <- c(oldmat$alpha, newmat$alpha)
      oldmat$alpha <- newmat$alpha <- NULL
      same <- all.equal(oldmat, newmat)
      if (!isTRUE(same))
        warning(same, "\nOnly last material used")
      result <- newmat
      result$color <- cols
      result$alpha <- alpha
      result$meshColor <- "vertices"
    }
    result
  }

  ids <- ids3d(subscene = subscene)
  ids <- ids[ids$id %in% x,]
  # Parts will be drawn in order ip, is, it, ib,
  # so sort that way now
  ordered <- c(points = 1, lines = 2, linestrip = 3,
               triangles = 4, planes = 5, quads = 6, 
               surface = 7)
  if (!is.na(type))
    ids <- ids[ids$type %in% type,]
  ids <- ids[order(ordered[ids$type]),]
  ip <- NULL
  is <- NULL
  it <- NULL
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
      prev <- length(vertices)/3
      inds <- switch(as.character(type),
                     points = seq_len(nvert) + prev,
                     lines = # from segments3d
                       matrix(1:nvert + prev, nrow = 2),
                     linestrip = # from lines3d
                       rbind(seq_len(nvert - 1), 
                             seq_len(nvert - 1) + 1) + prev,
                     triangles =,
                     planes = matrix(1:nvert + prev, nrow = 3),
                     quads = {
                       nquads <- nvert/4
                       matrix(4*rep(seq_len(nquads) - 1, each = 6) + c(1,2,3,1,3,4) + prev, nrow = 3)
                     },
                     surface = {
                       dim <- rgl.attrib(id, "dim")
                       ul <- rep(2:dim[1], dim[2]-1) + dim[1]*rep(0:(dim[2]-2), each=dim[1]-1) + prev
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
      if (length(inds)) {
        if (type == "points") {
          ip <- c(ip, inds)
          normals <- rbind(normals, matrix(NA, ncol = 3, nrow = nvert))
        } else if (type %in% c("lines", "linestrip")) {
          is <- cbind(is, inds)
          normals <- rbind(normals, matrix(NA, ncol = 3, nrow = nvert))
        } else {
          it <- cbind(it, inds)
          normals <- rbind(normals, rgl.attrib(id, "normals"))
        }  
        vertices <- cbind(vertices, local_t(rgl.attrib(id, "vertices")))
        if (rgl.attrib.count(id,"texcoords"))
          texcoords <- rbind(texcoords, rgl.attrib(id, "texcoords"))
        else
          texcoords <- rbind(texcoords, matrix(NA, ncol = 2, nrow = nvert))
        mat <- rgl.getmaterial(nvert, id = id)
        
        material <- mergeMaterials(material, mat, nvert, type)
      }
    }
  }
  if (length(vertices)) {
    if (length(unique(material$color)) == 1)
      material$color <- material$color[1]
    if (length(unique(material$alpha)) == 1)
      material$alpha <- material$alpha[1]
    meshColor <- material$meshColor
    material$meshColor <- NULL
    colorByFaces(mesh3d(vertices = vertices, 
                        points = ip, segments = is, triangles = it, 
                        material = material, normals = normals, 
                        texcoords = if (any(!is.na(texcoords))) texcoords, 
                        meshColor = meshColor))
  }
}

as.mesh3d.rglobject <- function(x, ...) {
  local_t <- function(x) {
    if (!is.null(x)) t(x)
  }
  indices <- NULL
  vertices <- NULL
  normals <- NULL
  texcoords <- NULL
  verts <- x$vertices
  nvert <- NROW(verts)
  if (!is.null(verts)) {
    type <- x$type
    inds <- switch(as.character(type),
                     triangles =,
                     planes = matrix(1:nvert, nrow = 3),
                     quads = {
                       nquads <- nvert/4
                       matrix(4*rep(seq_len(nquads) - 1, each = 6) + c(1,2,3,1,3,4), nrow = 3)
                     },
                     surface = {
                       dim <- x$dim
                       ul <- rep(2:dim[1], dim[2]-1) + dim[1]*rep(0:(dim[2]-2), each=dim[1]-1)
                       if (x$flipped)
                         rbind(c(ul-1, ul-1+dim[1]),
                               c(ul, ul),
                               c(ul-1+dim[1], ul+dim[1]))
                       else
                         rbind(c(ul, ul),
                               c(ul-1, ul-1+dim[1]),
                               c(ul-1+dim[1], ul+dim[1]))
                     },
                     NULL)
      if (length(inds)) {
        indices <- inds
        vertices <- local_t(x$vertices)
        normals <- x$normals
        texcoords <- x$texcoords
        material <- x$material
      }
    }
  if (length(vertices))
    tmesh3d(vertices, indices, homogeneous = FALSE, material = material,
            normals = normals, texcoords = texcoords)
}

mergeVertices <- function(mesh, notEqual = NULL, attribute = "vertices",
                          tolerance = sqrt(.Machine$double.eps)) {

  dropNormals <- function(mesh) {
    if (is.null(mesh$normals))
      return(FALSE)
    
    normals <- mesh$normals
    v <- with(mesh, rbind(vb[1,]/vb[4,], vb[2,]/vb[4,], vb[3,]/vb[4,]))
    it <- mesh$it
    if (!is.null(it))
      for (i in seq_len(ncol(it))) {
        normal <- xprod( v[, it[1, i]] - v[, it[3, i]], 
                         v[, it[2, i]] - v[, it[1, i]])
        normal <- normal/sqrt(sum(normal^2))
        for (j in 1:3) {
          normij <- normals[, it[j, i]]
          normij <- normij/sqrt(sum(normij^2))
          same <- all.equal(normal, normij, tolerance = tolerance,
                            check.attributes = FALSE)
          if (!isTRUE(same)) 
            return(FALSE)
        }
      }
    ib <- mesh$ib
    if (!is.null(ib)) 
      for (i in seq_len(ncol(ib))) {
        norm1 <- xprod( v[, it[1, i]] - v[, it[3, i]], 
                        v[, it[2, i]] - v[, it[1, i]])
        norm1 <- norm1/sqrt(sum(norm1^2))
        norm2 <- xprod( v[, it[2, i]] - v[, it[4, i]], 
                        v[, it[3, i]] - v[, it[2, i]])
        norm2 <- norm1/sqrt(sum(norm2^2))
        for (j in 1:4) {
          normij <- normals[, it[j, i]]
          normij <- normij/sqrt(sum(normij^2))
          same1 <- all.equal(norm1, normij, tolerance = tolerance,
                             check.attributes = FALSE)
          same2 <- all.equal(norm2, normij, tolerance = tolerance,
                             check.attributes = FALSE)
          if (!isTRUE(same1) || !isTRUE(same2)) 
            return(FALSE)
        }
      }      
    TRUE
  }
  
  if (dropNormals(mesh))
    mesh$normals <- NULL
  
  if (is.null(mesh$vb))
    return(mesh)
  nvert <- ncol(mesh$vb)
  if (!is.null(notEqual)) {
    dim <- dim(notEqual)
    if (length(dim) != 2 || dim[1] != nvert || dim[2] != nvert)
      stop("'notEqual' should be a ", nvert, " by ", nvert, " logical matrix.")
    notEqual <- notEqual | t(notEqual) # Make it symmetric
  } else
    notEqual <- matrix(FALSE, nvert, nvert)
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
  if ("colors" %in% attribute &&
      !is.null(mesh$meshColor) && mesh$meshColor == "vertices" &&
      !is.null(mesh$material) && !is.null(colors <- mesh$material$color))
      verts <- cbind(verts, t(col2rgb(colors)))
  
  if (!is.null(texcoords <- mesh$texcoords) && "texcoords" %in% attribute)
    verts <- cbind(verts, t(texcoords))
  
  o <- do.call(order, as.data.frame(verts))
  indices <- c(mesh$ip, mesh$is, mesh$it, mesh$ib)
  i1 <- seq_len(nvert)[o]
  for (i in seq_len(nvert)[-1]) {
    if (isTRUE(all.equal(verts[i1[i-1],], verts[i1[i],], tolerance = tolerance))
        && (!isTRUE(notEqual[i1[i-1], i1[i]]))) {
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
  
  if (np <- length(mesh$ip))
    mesh$ip <- indices[seq_len(np)]
  if (ns <- length(mesh$is))
    mesh$is <- matrix(indices[seq_len(ns) + np])
  if (nt <- length(mesh$it)) 
    mesh$it <- matrix(indices[seq_len(nt) + np + ns], nrow = 3)
  if (nq <- length(mesh$ib)) 
    mesh$ib <- matrix(indices[seq_len(nq) + np + ns + nt], nrow = 4)
  mesh
}
