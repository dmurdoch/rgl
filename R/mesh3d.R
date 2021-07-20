ensureMatrix <- function(x, nrow) {
  if (!is.matrix(x))
    x <- matrix(x, nrow = nrow)
  x
}

mesh3d <- function( x, y = NULL, z = NULL, vertices, 
                    material = NULL,
                    normals = NULL, texcoords = NULL,
                    points = NULL, segments = NULL,
                    triangles = NULL, quads = NULL,
                    meshColor = c("vertices", "edges", "faces", "legacy")) {
  
  if (missing(vertices)) {
    xyz <- xyz.coords(x, y, z, recycle=TRUE)
    vertices <- rbind(xyz$x, xyz$y, xyz$z, 1) 
  } else vertices <- asHomogeneous2(vertices)
  
  # Remove dimnames
  dimnames(vertices) <- NULL

  if (missing(meshColor) 
      && !is.null(material) 
      && !is.null(material$meshColor)) {
    meshColor <- material$meshColor
    material$meshColor <- NULL
  }
  
  meshColor <- match.arg(meshColor)
  
  if (is.null(texcoords)
      && !is.null(material)
      && !is.null(material$texcoords)) {
    texcoords <- material$texcoords
    material$texcoords <- NULL
  }
  
  nvertex <- ncol(vertices)
  
  if ( !is.null(normals) ) {
    normals <- xyz.coords(normals, recycle=TRUE)
    x <- rep(normals$x, len = nvertex)
    y <- rep(normals$y, len = nvertex)
    z <- rep(normals$z, len = nvertex)
    normals <- rgl.vertex(x, y, z)
  }
  
  if ( !is.null(texcoords) ) {
    texcoords <- xy.coords(texcoords, recycle = TRUE)
    x <- rep(texcoords$x, len = nvertex)
    y <- rep(texcoords$y, len = nvertex)
    texcoords <- rbind(x, y)
  }
  
  object <- list(
    vb = vertices,
    material = .getMaterialArgs(material = material),
    normals = normals,
    texcoords = texcoords,
    meshColor = meshColor
  ) 
  
  if (!is.null(points))    object$ip <- ensureMatrix(points, 1)
  if (!is.null(segments))  object$is <- ensureMatrix(segments, 2)
  if (!is.null(triangles)) object$it <- ensureMatrix(triangles, 3)
  if (!is.null(quads))     object$ib <- ensureMatrix(quads, 4)

  register_compare_proxy()
  
  class(object) <- c("mesh3d", "shape3d")
  object
}

register_compare_proxy <- local({
  registered <- FALSE
  function() {
    if (!registered &&
        isNamespaceLoaded("waldo")) {
      if ("path" %in% names(formals(waldo::compare_proxy))) { # appeared after 0.2.5
        registerS3method("compare_proxy", "mesh3d", 
                         compare_proxy.mesh3d, 
                         envir = asNamespace("waldo"))
        registerS3method("compare_proxy", "rglscene",
                         compare_proxy.rglscene,
                         envir = asNamespace("waldo"))        
      } else {
        registerS3method("compare_proxy", "mesh3d", 
                         old_compare_proxy.mesh3d, 
                         envir = asNamespace("waldo"))
        registerS3method("compare_proxy", "rglscene",
                         old_compare_proxy.rglscene,
                         envir = asNamespace("waldo")) 
      }
      registered <<- TRUE
    }
  }
})

compare_proxy.mesh3d <- function(x, path = "x") {
  list(object = old_compare_proxy.mesh3d(x),
       path = paste0("compare_proxy(", path, ")"))
}

old_compare_proxy.mesh3d <- function(x) {
  for (n in names(x)) # Some elements are NULL, some are not there
    if (is.null(x[[n]])) x[[n]] <- NULL
  if (is.null(x$material) ||
      length(x$material$color) < 2)
    x$meshColor <- NULL  # It doesn't matter.
  for (n in c("ip", "is", "it", "ib"))
    if (!is.null(x[[n]]))
      x[[n]] <- as.numeric(x[[n]])
  x$primitivetype <- NULL # Not used since before 0.100.x
  x[sort(names(x))]
}

#
# triangle mesh object
#

tmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL,
                     texcoords = NULL,
                     meshColor = c("vertices", "edges", "faces", "legacy")) {
  
  if (missing(meshColor) && !is.null(material$meshColor))
    meshColor <- material$meshColor
  meshColor <- match.arg(meshColor)
  if (is.null(dim(vertices)))
    vertices <- matrix(vertices, nrow = if (homogeneous) 4 else 3)
  
  # For back-compatibility:
  colnames(indices) <- NULL   
  
  mesh3d(vertices = vertices, triangles = indices,
         material = material, normals = normals, texcoords = texcoords,
         meshColor = meshColor)
}

#
# R 3d object : quad mesh
#

qmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL,
                     texcoords=NULL,
                     meshColor = c("vertices", "edges", "faces", "legacy")) {
  
  if (missing(meshColor) && !is.null(material$meshColor))
    meshColor <- material$meshColor
  meshColor <- match.arg(meshColor)
  
  if (is.null(dim(vertices)))
    vertices <- matrix(vertices, nrow = if (homogeneous) 4 else 3)
  
  # For back-compatibility
  colnames(indices) <- NULL   
  
  mesh3d(vertices = vertices, quads = indices,
         material = material, normals = normals, texcoords = texcoords,
         meshColor = meshColor)
}

as.mesh3d <- function(x, ...) UseMethod("as.mesh3d")

as.mesh3d.deldir <- function(x, col = "gray", coords = c("x", "y", "z"), 
			     smooth = TRUE, normals = NULL, texcoords = NULL,
			     ...) {
  if (!requireNamespace("deldir", quietly = TRUE))
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
  result <- mesh3d(vertices = asHomogeneous2(points), triangles = triangs$ptNum,
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
  result <- mesh3d(vertices = asHomogeneous2(points), triangles = triangs,
                    normals = normals, texcoords = texcoords,
                    material = material)
  if (smooth)
    result <- addNormals(result)
  result  
}

# rendering support

dot3d.mesh3d <- function(x, ..., front = "points", back = "points")
  shade3d.mesh3d(x, ..., front = front, back = back)

wire3d.mesh3d <- function(x, ..., front = "lines", back = "lines")
  shade3d.mesh3d(x, ..., front = front, back = back)

allowedMeshColor <- function(meshColor, modes) {
  meshColor != "edges" || 
    (modes[1] == modes[2] && modes[1] == "lines")
}

shade3d.mesh3d <- function( x, override = TRUE, 
                             meshColor = c("vertices", "edges", "faces", "legacy"), 
                             texcoords = NULL, 
                             ...,
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
    if (is.null(texcoords) && !is.null(x$texcoords))
      texcoords <- t(x$texcoords)
  } else {
    material <- argMaterial
    material[names(x$material)] <- x$material
    if (is.null(x$meshColor))
      meshColor <- match.arg(meshColor)
    else
      meshColor <- x$meshColor
    if (!is.null(x$texcoords))
      texcoords <- t(x$texcoords)
  }
  normals <- x$normals
  if (!is.null(normals))
    normals <- t(normals)
  
  modes <- c(front, back)
  if (!allowedMeshColor(meshColor, modes))
    stop("'meshColor = ", meshColor, "' not supported.")
  
  if (meshColor != "legacy") {
    if (is.null(material$color))
      material$color <- material3d("color")
    if (is.null(material$alpha))
      material$alpha <- material3d("alpha")
  }
  
  vertices <- t(asEuclidean2(x$vb))
  
  result <- integer(0)
  prev <- 0
  
  doVertices <- function(vals, inds, setPrev) {
    inds <- as.numeric(inds)
    if (length(unique(vals)) > 1) {
      vals <- rep_len(vals, max(inds))
      vals[inds]
    } else
      vals
  }
  doLegacy <- function(vals, inds, setPrev) {
    inds <- as.numeric(inds) + prev
    if (setPrev)
      prev <<- prev + length(inds)
    if (length(unique(vals)) > 1)
      vals <- rep_len(vals, length(inds))
    vals
  }
  doFaces <- function(vals, inds, setPrev) {
    if (!is.matrix(inds))
      inds <- matrix(inds, nrow = 1)
    inds <- inds + prev
    if (setPrev)
      prev <<- prev + ncol(inds)
    vals <- rep_len(vals, ncol(inds))
    rep(vals, each = nrow(inds))
  }
  doEdges <- function(vals, inds, setPrev) {
    if (!is.matrix(inds)) 
      inds <- matrix(inds, nrow = 1)
    inds <- inds + prev
    if (setPrev)
      prev <<- prev + length(inds)
    newlen <- ncol(inds)
    if (nrow(inds) > 1)
      newlen <- newlen * nrow(inds) / 2
    vals <- rep_len(vals, newlen)
    if (nrow(inds) > 1)
      vals <- rep(vals, each = 2)
    vals
  }
  getArgs <- function(inds) {
    args <- c(list(x = vertices[as.numeric(inds),]), material)
    if (!is.null(texcoords))
      args$texcoords <- cbind(repfn(texcoords[,1], inds, FALSE),
                              repfn(texcoords[,2], inds, FALSE))
    if (!is.null(normals))
      args$normals <- normals[as.numeric(inds),]
    args$color <- repfn(args$color, inds, FALSE)
    args$alpha <- repfn(args$alpha, inds, TRUE)
    args
  }
  
  repfn <- switch(meshColor, 
                  vertices = doVertices,
                  legacy = doLegacy,
                  faces = doFaces,
                  doLegacy)  
  if (length(x$ip)) {
    args <- getArgs(x$ip)
    result <- c(result, points = do.call(points3d, args = args ))
  }
  
  if (length(x$is)) {
    args <- getArgs(x$is)
    result <- c(result, segments = do.call(segments3d, args = args ))
  }
  
  if (length(x$it)) {
    if (meshColor == "edges") {
      x$it <- x$it[c(1,2,2,3,3,1),]
      fn <- segments3d
    } else
      fn <- triangles3d
    args <- getArgs(x$it)
    result <- c(result, triangles = do.call(fn, args = args ))
  }

  if (length(x$ib)) {
    if (meshColor == "edges") {
      x$ib <- x$ib[c(1,2,2,3,3,4,4,1),]
      fn <- segments3d
    } else
      fn <- quads3d
    args <- getArgs(x$ib)
    result <- c(result, quads = do.call(fn, args = args ))
  }
  
  lowlevel(result)
}

# transformation support

translate3d.mesh3d <- function( obj, x, y, z, ... ) {
  obj$vb <- t(translate3d(t(obj$vb), x, y, z))
  return(obj)                            
}  

rotate3d.mesh3d <- function( obj,angle,x,y,z,matrix, ... ) {
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

scale3d.mesh3d <- function( obj, x, y, z, ... ) {
  obj$vb <- t(scale3d(t(obj$vb), x, y, z))
  if ( !is.null(obj$normals) ) {
    obj$normals <- scale3d(t(obj$normals), 1/x, 1/y, 1/z)
    obj$normals <- t( obj$normals/sqrt(apply(obj$normals[,1:3]^2, 1, sum)) )
    if (nrow(obj$normals) == 4)
      obj$normals[4,] <- 1
  }
  return(obj)
}

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
      paste(c(
        if (length(x$ip)) paste(length(x$ip), "points"),
        if (length(x$is)) paste(ncol(x$is), "segments"),
        if (length(x$it))  paste(ncol(x$it), "triangles"),
        if (length(x$ib))  paste(ncol(x$ib), "quads")), collapse = ", "),
      ".\n", sep = "")
}

match_names <- function(x, reference) {
  if (!is.null(x))
    structure(x[names(reference)], class = class(x))
}

# Compare old and new meshes
all.equal.mesh3d <- function(target, current, ...) {
  if (inherits(current, "mesh3d"))
    all.equal(compare_proxy.mesh3d(target), 
              compare_proxy.mesh3d(current), ...)
  else
    "'current' is not a mesh3d object"
}
