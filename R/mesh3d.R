#
# triangle mesh object
#

tmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL,
                     texcoords=NULL,
                     meshColor = c("vertices", "edges", "faces", "legacy")) {

  if (missing(meshColor) 
      && !is.null(material) 
      && !is.null(material$meshColor)) {
    meshColor <- material$meshColor
    material$meshColor <- NULL
  }
  meshColor <- match.arg(meshColor)
  
  if (homogeneous == TRUE)
    vrows <- 4
  else
    vrows <- 3
  
  nvertex <- length(vertices)/vrows
  if ( !is.null(normals) ) {
    normals <- xyz.coords(normals, recycle=TRUE)
    x <- rep(normals$x, len=nvertex)
    y <- rep(normals$y, len=nvertex)
    z <- rep(normals$z, len=nvertex)
    normals <- rgl.vertex(x,y,z)
  }
  if ( !is.null(texcoords) ) {
    texcoords <- xy.coords(texcoords, recycle=TRUE)
    x <- rep(texcoords$x, len=nvertex)
    y <- rep(texcoords$y, len=nvertex)
    texcoords <- rbind(x,y)
  }
  object <- list(
    vb=matrix(vertices,nrow=vrows),
    it=matrix(indices,nrow=3),
    material=.getMaterialArgs(material = material),
    normals=normals,
    texcoords=texcoords,
    meshColor = meshColor
  ) 
  
  if (!homogeneous) object$vb <- rbind(object$vb, 1)
  
  class(object) <- c("mesh3d", "shape3d")
  return( object )
}

#
# R 3d object : quad mesh
#

qmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL,
                     texcoords=NULL,
                     meshColor = c("vertices", "edges", "faces", "legacy")) {

  if (missing(meshColor) 
      && !is.null(material) 
      && !is.null(material$meshColor)) {
    meshColor <- material$meshColor
    material$meshColor <- NULL
  }  
  meshColor <- match.arg(meshColor)
  
  if (homogeneous == TRUE)
    vrows <- 4
  else
    vrows <- 3    
  nvertex <- length(vertices)/vrows
  if ( !is.null(normals) ) {
    normals <- xyz.coords(normals, recycle=TRUE)
    x <- rep(normals$x, len=nvertex)
    y <- rep(normals$y, len=nvertex)
    z <- rep(normals$z, len=nvertex)
    normals <- rgl.vertex(x,y,z)
  }
  if ( !is.null(texcoords) ) {
    texcoords <- xy.coords(texcoords, recycle=TRUE)
    x <- rep(texcoords$x, len=nvertex)
    y <- rep(texcoords$y, len=nvertex)
    texcoords <- rbind(x,y)
  }  
  object <- list(
    vb=matrix(vertices,nrow=vrows),
    ib=matrix(indices,nrow=4),
    material=.getMaterialArgs(material = material),
    normals=normals,
    texcoords=texcoords,
    meshColor = meshColor
  ) 
  
  if (!homogeneous) object$vb <- rbind(object$vb, 1)
  
  class(object) <- c("mesh3d", "shape3d")
  return( object )
}

as.mesh3d <- function(x, ...) UseMethod("as.mesh3d")

as.mesh3d.deldir <- function(x, col = "gray", coords = c("x", "y", "z"), 
			     smooth = TRUE, normals = NULL, texcoords = NULL,
			     ...) {
  if (!requireNamespace("deldir"))
    stop("The ", sQuote("deldir"), " package is required.")
  if (!identical(sort(coords), c("x", "y", "z")))
    stop(sQuote("coords"), " should be a permutation of c('x', 'y', 'z')")
  if (!all(coords %in% names(x$summary)))
    stop("The 'deldir' object needs x, y, and z coordinates.")
  if (smooth && !is.null(normals)) {
    warning("'smooth' ignored as 'normals' was specified.")
    smooth <- FALSE
  }
  pointnames <- as.numeric(rownames(x$summary))
  points <- matrix(NA, max(pointnames), 3)
  points[pointnames, ] <- as.matrix(x$summary[, coords])
  points <- t(points)
  triangs <- do.call(rbind, deldir::triang.list(x))

  if (!is.null(texcoords))
    texcoords <- texcoords[triangs$ptNum, ]
  material <- .getMaterialArgs(...)
  material$color <- col
  result <- tmesh3d(points, triangs$ptNum, homogeneous = FALSE,
  	  normals = normals, texcoords = texcoords,
  	  material = material)
  if (smooth)
    result <- addNormals(result)
  result
}

as.mesh3d.triSht <-
as.mesh3d.tri <- function(x, z, col = "gray", 
                          coords = c("x", "y", "z"), 
                          smooth = TRUE, normals = NULL, texcoords = NULL,
                          ...) {
  if (inherits(x, "tri")) 
    triangles <- tripack::triangles
  else if (inherits(x, "triSht")) {
    triangles <- interp::triangles
  }
  if (!identical(sort(coords), c("x", "y", "z")))
    stop(sQuote("coords"), " should be a permutation of c('x', 'y', 'z')")
  if (!is.numeric(z) || length(z) != x$n)
    stop("z should be a numeric vector with one entry per node of x")
  if (smooth && !is.null(normals)) {
    warning("'smooth' ignored as 'normals' was specified.")
    smooth <- FALSE
  }
  points <- rbind(x$x, x$y, z)
  rownames(points) <- c("x", "y", "z")
  points <- points[coords,]
  
  triangs <- t(triangles(x)[, 1:3])
  if (inherits(x, "tri") && x$nc) {
    constraintIndex <- min(x$lc)
    keep <- apply(triangs, 2, function(col) any(col < constraintIndex))
    triangs <- triangs[, keep]
  }
  
  if (!is.null(texcoords))
    texcoords <- texcoords[triangs, ]
  material <- .getMaterialArgs(...)
  material$color <- col
  result <- tmesh3d(points, triangs, homogeneous = FALSE,
                    normals = normals, texcoords = texcoords,
                    material = material)
  if (smooth)
    result <- addNormals(result)
  result  
}

# rendering support

dot3d.mesh3d <- function(x, ..., front = "points", back = "points")
  shade3d.mesh3d(x, ..., front = front, back = back)

dot3d.qmesh3d <- dot3d.mesh3d   # for back-compatibility

wire3d.mesh3d <- function(x, ..., front = "lines", back = "lines")
  shade3d.mesh3d(x, ..., front = front, back = back)

allowedMeshColor <- function(meshColor, modes) {
  meshColor != "edges" || 
    (modes[1] == modes[2] && modes[1] == "lines")
}

shade3d.mesh3d <- function ( x, override = TRUE, 
                             meshColor = c("vertices", "edges", "faces", "legacy"), ...,
                             front = "filled", back = "filled") {
  argMaterial <- c(list(front = front, back = back), .getMaterialArgs(...))
  xHasColor <- !is.null(x$material) && !is.null(x$material$color)
  hasMeshColor <- !missing(meshColor)
  if ( override ) {
    material <- x$material
    if (is.null(material)) material <- list()    
    material[names(argMaterial)] <- argMaterial
    if (hasMeshColor || is.null(x$meshColor))
      meshColor <- match.arg(meshColor)
    else
      meshColor <- x$meshColor
  } else {
    material <- argMaterial
    material[names(x$material)] <- x$material
    if (is.null(x$meshColor))
      meshColor <- match.arg(meshColor)
    else
      meshColor <- x$meshColor
  }
  modes <- c(front, back)
  if (!allowedMeshColor(meshColor, modes))
    stop("'meshColor = ", meshColor, "' not supported.")
  
  if (meshColor != "legacy") {
    if (is.null(material$color))
      material$color <- material3d("color")
    if (is.null(material$alpha))
      material$alpha <- material3d("alpha")
  }
  result <- integer(0)
  ntriangles <- 0
  if (!is.null(x$it)) {
    if (meshColor == "edges")
      x$it <- x$it[c(1,2,2,3,3,1),]
    ntriangles <- ncol(x$it)
    args <- c(list(x = x$vb[1,x$it]/x$vb[4,x$it],
                   y = x$vb[2,x$it]/x$vb[4,x$it],
                   z = x$vb[3,x$it]/x$vb[4,x$it]), 
                   material)
    if (!is.null(x$normals) && is.null(args$normals)) 
      args <- c(args, list(normals = t(x$normals[,x$it])))
    if (!is.null(x$texcoords) && is.null(args$texcoords))
      args <- c(args, list(texcoords = t(x$texcoords[,x$it])))
    if (meshColor != "legacy") {
      
      if (length(unique(args$color)) > 1) {
        if (!xHasColor && !hasMeshColor && getOption("rgl.meshColorWarning", FALSE))
          warning("Default coloring for meshes changed in rgl 0.100.1")
        args$color <- switch(meshColor,
          vertices = rep_len(args$color, ncol(x$vb))[x$it],
          faces = rep(args$color, each = 3)
        )
      }
      if (length(unique(args$alpha)) > 1)
        args$alpha <- switch(meshColor,
          vertices = rep_len(args$alpha, ncol(x$vb))[x$it],
          faces = rep(args$alpha, each = 3)
        )
    }
    if (meshColor == "edges") 
      fn <- segments3d
    else
      fn <- triangles3d
    result <- c(triangles = do.call(fn, args = args ))
  }
  if (!is.null(x$ib)) {
    if (meshColor == "edges")
      x$ib <- x$ib[c(1,2,2,3,3,4,4,1),]
    args <- c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                   y = x$vb[2,x$ib]/x$vb[4,x$ib],
                   z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                   material)
    if (!is.null(x$normals) && is.null(args$normals)) 
      args <- c(args, list(normals = t(x$normals[,x$ib])))
    if (!is.null(x$texcoords) && is.null(args$texcoords))
      args <- c(args, list(texcoords = t(x$texcoords[,x$ib])))
    if (meshColor != "legacy") {
      if (length(unique(args$color)) > 1) {
        nquads <- ncol(x$ib)
        args$color <- switch(meshColor,
          vertices = rep_len(args$color, ncol(x$vb))[x$ib],
          faces = {
            temp <- rep_len(args$color, ntriangles + nquads)
            rep(temp[ntriangles + seq_len(nquads)], each = 4)
          })
        args$alpha <- switch(meshColor,
          vertices = rep_len(args$alpha, ncol(x$vb))[x$ib],
          faces = {
            temp <- rep_len(args$alpha, ntriangles + nquads)
            rep(temp[ntriangles + seq_len(nquads)], each = 4)
          })
      }
    }
    if (meshColor == "edges")
      fn <- segments3d
    else
      fn <- quads3d
    result <- c(result, quads = do.call(fn, args = args ))
  }
  lowlevel(result)
}

# transformation support

translate3d.mesh3d <- function ( obj, x, y, z, ... ) {
  obj$vb <- t(translate3d(t(obj$vb), x, y, z))
  return(obj)                            
}  

rotate3d.mesh3d <- function ( obj,angle,x,y,z,matrix, ... ) {
  obj$vb <- t(rotate3d(t(obj$vb), angle, x, y, z, matrix))
  if ( !is.null(obj$normals) ) {
    if ( missing(matrix) ) 
      obj$normals <- rotate3d(t(obj$normals), angle, x, y, z)
    else {
      if (nrow(matrix) == 4) matrix[4,1:3] <- 0
      if (ncol(matrix) == 4) matrix[1:3,4] <- 0
      obj$normals <- rotate3d(t(obj$normals), angle, x, y, z, t(solve(matrix)))
    }
    obj$normals <- t( obj$normals/sqrt(apply(obj$normals^2, 1, sum)) )
  }
  return(obj)                            
}  

scale3d.mesh3d <- function ( obj, x, y, z, ... ) {
  obj$vb <- t(scale3d(t(obj$vb), x, y, z))
  if ( !is.null(obj$normals) ) {
    obj$normals <- scale3d(t(obj$normals), 1/x, 1/y, 1/z)
    obj$normals <- t( obj$normals/sqrt(apply(obj$normals[,1:3]^2, 1, sum)) )
    obj$normals[4,] <- 1
  }
  return(obj)
}

# for back-compatibility
translate3d.qmesh3d <- translate3d.mesh3d
rotate3d.qmesh3d <- rotate3d.mesh3d
scale3d.qmesh3d <- scale3d.mesh3d

# for debugging
showNormals <- function(obj, scale = 1) {
  v <- obj$vb
  n <- obj$normals
  if (is.null(n)) {
    warning("No normals found.")
    return()
  }
  save <- par3d(skipRedraw = TRUE)
  on.exit(par3d(save))
  for (i in seq_len(ncol(n))) {
    p0 <- v[1:3, i]/v[4, i]
    p1 <- p0 + n[1:3, i]*scale
    if (all(is.finite(c(p0, p1))))
      arrow3d(p0, p1, type = "lines")
  }
}

print.mesh3d <- function(x, prefix = "", ...) {
  cat(prefix, " mesh3d object with ", ncol(x$vb), " vertices, ", 
      if (is.null(x$it)) 0 else ncol(x$it), " triangles and ",
      if (is.null(x$ib)) 0 else ncol(x$ib), " quads.\n", sep = "")
}

# Compare old and new meshes
all.equal.mesh3d <- function(target, current, ...) {
  mcs <- c(target$meshColor, current$meshColor)
  target$meshColor <- NULL
  current$meshColor <- NULL
  result <- all.equal.list(target, current, ...)
  if (isTRUE(result)) 
    result <- character()
  mctest <- is.null(mcs) ||
            (length(mcs) == 1 && mcs == "vertices") ||
            (length(mcs) == 2 && mcs[1] == mcs[2])
  if (!mctest)
    result <- c(result, "meshColor difference")
  if (!length(result))
    result <- TRUE
  result
}
