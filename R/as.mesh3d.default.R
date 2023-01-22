as.mesh3d.default <- function(x, y = NULL, z = NULL,
                              type = c("triangles", "quads", "segments", "points"),
                              smooth = FALSE, 
                              tolerance = sqrt(.Machine$double.eps),
                              notEqual = NULL,
                              merge = TRUE,
                              ..., 
                              triangles) {
  if (missing(x)) {
    x <- rglId(ids3d()$id)
    return(as.mesh3d(x, ...))
  }
  verts <- rgl.vertex(x, y, z)
  if (!missing(triangles)) {
    warning("Argument 'triangles' is deprecated; please use 'type' instead.")
    if (missing(type)) {
      if (triangles)
        type <- "triangles"
      else
        type <- "quads"
    }
  }
  type <- match.arg(type, several.ok = TRUE)
  pcs <- c(triangles = 3, quads = 4, segments = 2, points = 1)
  nvert <- ncol(verts)
  okay <- FALSE
  for (i in seq_along(type)) {
    if (nvert %% pcs[type[i]] == 0) {
      okay <- TRUE
      break
    }
  }
  if (okay) type <- type[i]
  else stop("Wrong number of vertices")
    
  indices <- matrix(seq_len(nvert), nrow = pcs[type])
  if (merge) {
    if (!is.null(notEqual)) {
      dim <- dim(notEqual)
      if (length(dim) != 2 || dim[1] != nvert || dim[2] != nvert)
        stop("'notEqual' should be a ", nvert, " by ", nvert, " logical matrix.")
      notEqual <- notEqual | t(notEqual) # Make it symmetric
    } else
      notEqual <- matrix(FALSE, nvert, nvert)
    o <- order(verts[1,], verts[2,], verts[3,])
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

  mesh <- mesh3d(vertices = rbind(verts[,keep, drop = FALSE], 1), points = if (type == "points") indices, 
                  triangles = if (type == "triangles") indices,
                  quads = if (type == "quads") indices,
                  segments = if (type == "segments") indices,
                  material = list(...))
  if (smooth && type != "points")
    mesh <- addNormals(mesh)
  mesh
}

as.mesh3d.rglId <- function(x, type = NA, subscene = NA, 
                            ...) {
  local_t <- function(x) {
    if (!is.null(x)) t(x)
  }
  
  colorByFaces <- function(mesh) {
    constColumns <- function(m)
      all(apply(m, 2, function(col) length(unique(col))) == 1)
          
    # See if we can use meshColor = "faces"
    if (!is.null(mesh$material) && !is.null(mesh$meshColor)
        && mesh$meshColor == "vertices") {
      cols <- mesh$material$color
      alpha <- mesh$material$alpha
      texcoords <- mesh$texcoords
      if (length(cols) == 1 && length(alpha) == 1 && is.null(texcoords)) {
        mesh$meshColor <- "faces"
        return(mesh)
      }
      if (length(cols) == 1)
        cols <- rep(cols, length.out = ncol(mesh$vb))
      if (length(alpha) == 1)
        alpha <- rep(alpha, length.out = ncol(mesh$vb))
      prev <- 0
      newcols <- NULL
      newalpha <- NULL
      newtexcoords <- NULL
      
      if (!is.null(mesh$ip)) {
        inds <- mesh$ip
        newcols <- cols[inds]
        newalpha <- alpha[inds]
      }
      if (!is.null(mesh$is)) {
        inds <- as.numeric(mesh$is) 
        cols <- matrix(cols[inds], nrow = 2)
        alpha <- matrix(alpha[inds], nrow = 2)
        if (!constColumns(cols) || !constColumns(alpha))
          return(mesh)
        newcols <- c(newcols, cols[1,])
        newalpha <- c(newalpha, alpha[1,])
      }
      if (!is.null(mesh$it)) {
        inds <- as.numeric(mesh$it)
        cols <- matrix(cols[inds], nrow = 3)
        alpha <- matrix(alpha[inds], nrow = 3)
        if (!constColumns(cols) || !constColumns(alpha))
          return(mesh)
        if (!is.null(texcoords)) {
          tex1 <- matrix(texcoords[1, inds], nrow = 3)
          tex2 <- matrix(texcoords[2, inds], nrow = 3)
          if (!constColumns(tex1) || !constColumns(tex2))
            return(mesh)
        }
        newcols <- c(newcols, cols[1,])
        newalpha <- c(newalpha, alpha[1,])
        if (!is.null(texcoords))
          newtexcoords <- cbind(newtexcoords, rbind(tex1[1,], tex2[1,]))
      }
      if (!is.null(mesh$ib)) {
        inds <- as.numeric(mesh$ib)
        cols <- matrix(cols[inds], nrow = 3)
        alpha <- matrix(alpha[inds], nrow = 3)
        tex1 <- matrix(texcoords[1, inds], nrow = 3)
        tex2 <- matrix(texcoords[2, inds], nrow = 3)
        if (!constColumns(cols) || !constColumns(alpha) ||
            !constColumns(tex1) || !constColumns(tex2))
          return(mesh)
        newcols <- c(newcols, cols[1,])
        newalpha <- c(newalpha, alpha[1,])
        newtexcoords <- cbind(newtexcoords, rbind(tex1[1,], tex2[1,]))
      }
      mesh$meshColor <- "faces"
      mesh$material$color <- if (length(unique(newcols)) == 1)
                               newcols[1]
                             else
                               newcols
      mesh$material$alpha <- if (length(unique(newalpha)) == 1)
                               newalpha[1]
                             else
                               newalpha
      mesh$texcoords <- newtexcoords
    }
    mesh
  }
  
  mergeMaterials <- function(oldmat, newmat, n, type) {
    if (length(newmat$color) == 1)
      newmat$color <- rep(newmat$color, length.out = n)
    if (length(newmat$alpha) == 1)
      newmat$alpha <- rep(newmat$alpha, length.out = n)
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
    verts <- expandVertices(id)
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
          normals <- rbind(normals, expandNormals(id))
        }  
        vertices <- cbind(vertices, local_t(verts))
        if (rgl.attrib.count(id,"texcoords"))
          texcoords <- rbind(texcoords, expandTexcoords(id))
        else
          texcoords <- rbind(texcoords, matrix(NA, ncol = 2, nrow = nvert))
        mat <- expandMaterial(id, nvert)
        
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
  vertices <- x$vertices
  if (is.null(indices <- x$indices))
    if (x$type == "surface") {
      dim <- x$dim
      ul <- rep(2:dim[1], dim[2]-1) + dim[1]*rep(0:(dim[2]-2), each=dim[1]-1)
      if (x$flipped)
        indices <- rbind(c(ul-1, ul-1+dim[1]),
                         c(ul, ul),
                         c(ul-1+dim[1], ul+dim[1]))
      else
        indices <- rbind(c(ul, ul),
                         c(ul-1, ul-1+dim[1]),
                         c(ul-1+dim[1], ul+dim[1]))
    } else
      indices <- seq_len(NROW(vertices))
  material <- x$material
  if (length(indices))
    switch(x$type,
      points = mesh3d(x = vertices,
                      normals = x$normals,
                      texcoords = x$texcoords,
                      points = indices,
                      material = x$material),
      linestrip = {
        indices <- as.numeric(rbind(indices[-length(indices)],
                                    indices[-1]))
        mesh3d(x = vertices,
               segments = indices,
               material = x$material)
      }, 
      lines = mesh3d(x = vertices,
                        normals = x$normals,
                        texcoords = x$texcoords,
                        segments = indices,
                        material = x$material),
      surface =,
      triangles = mesh3d(x = vertices,
                         normals = x$normals,
                         texcoords = x$texcoords,
                         triangles = indices,
                         material = x$material),
      quads = mesh3d(x = vertices,
                     normals = x$normals,
                     texcoords = x$texcoords,
                     quads = indices,
                     material = x$material),
        NULL
      )
  else
    NULL
}

as.mesh3d.rglsubscene <- function(x, rglscene, transform = diag(4), simplify = TRUE, ...) {
  outmeshes <- list()
  objects <- rglscene$objects
  for (i in x$objects) {
    m <- as.mesh3d(objects[[as.character(i)]])
    if (!is.null(m))
      outmeshes <- c(outmeshes, list(rotate3d(m, matrix = transform)))
  }
  for (i in seq_along(x$subscenes)) {
    child <- x$subscenes[[i]]
    outmeshes <- c(outmeshes, as.mesh3d(child, rglscene, transform %*% child$par3d$userMatrix, simplify = FALSE))
  }
  if (simplify && length(outmeshes) == 1)
    outmeshes[[1]]
  else if (length(outmeshes))
    shapelist3d(outmeshes, plot = FALSE)
  else
    NULL
}

as.mesh3d.rglscene <- function(x, ...) {
  result <- as.mesh3d(x$rootSubscene, rglscene = x, ...)
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
