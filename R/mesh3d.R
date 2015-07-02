#
# triangle mesh object
#

tmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL,
                     texcoords=NULL) {
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
    primitivetype="triangle",
    material=material,
    normals=normals,
    texcoords=texcoords
  ) 
  
  if (!homogeneous) object$vb <- rbind(object$vb, 1)
  
  class(object) <- c("mesh3d", "shape3d")
  return( object )
}

#
# R 3d object : quad mesh
#

qmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL,
                     texcoords=NULL) {
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
    primitivetype="quad",
    material=material,
    normals=normals,
    texcoords=texcoords
  ) 
  
  if (!homogeneous) object$vb <- rbind(object$vb, 1)
  
  class(object) <- c("mesh3d", "shape3d")
  return( object )
}

# rendering support

dot3d.mesh3d <- function ( x, override = TRUE, ... ) {
  if ( override ) {
    material <- x$material
    if (is.null(material)) material <- list()
    material[names(list(...))] <- list(...)
  } else {
    material <- list(...)
    material[names(x$material)] <- x$material
  }
  
  do.call("points3d", args = c(list(x = x$vb[1,]/x$vb[4,], 
                                    y = x$vb[2,]/x$vb[4,], 
                                    z = x$vb[3,]/x$vb[4,]), 
                               material ))
}     

dot3d.qmesh3d <- dot3d.mesh3d   # for back-compatibility
  
wire3d.mesh3d <- function ( x, override = TRUE, ... ) {
  if ( override ) {
    material <- x$material
    if (is.null(material)) material <- list()    
    material[names(list(...))] <- list(...)
  } else {
    material <- list(...)
    material[names(x$material)] <- x$material
  }
  material["front"] <- "lines"
  material["back"] <- "lines"
  
  result <- integer(0)
  if (!is.null(x$it))
    result <- c(triangles = do.call("triangles3d", args = c(list(x = x$vb[1,x$it]/x$vb[4,x$it],
                                         y = x$vb[2,x$it]/x$vb[4,x$it],
                                         z = x$vb[3,x$it]/x$vb[4,x$it]), 
                                    material)))
  if (!is.null(x$ib))
    result <- c(result, quads = do.call("quads3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                     y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                     z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                                material)))
  invisible(result)
}

shade3d.mesh3d <- function ( x, override = TRUE, ... ) {
  if ( override ) {
    material <- x$material
    if (is.null(material)) material <- list()    
    material[names(list(...))] <- list(...)
  } else {
    material <- list(...)
    material[names(x$material)] <- x$material
  }
  result <- integer(0)
  skipRows <- 0
  if (!is.null(x$it)) {
    args <- c(list(x = x$vb[1,x$it]/x$vb[4,x$it],
                   y = x$vb[2,x$it]/x$vb[4,x$it],
                   z = x$vb[3,x$it]/x$vb[4,x$it]), 
                   material)
    if (!is.null(x$normals) && is.null(args$normals)) 
      args <- c(args, list(normals = t(x$normals[,x$it])))
    if (!is.null(x$texcoords) && is.null(args$texcoords))
      args <- c(args, list(texcoords = t(x$texcoords[,x$it])))
      
    result <- c(triangles = do.call("triangles3d", args = args ))
  }
  if (!is.null(x$ib)) {
    args <- c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                   y = x$vb[2,x$ib]/x$vb[4,x$ib],
                   z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                   material)
    if (!is.null(x$normals) && is.null(args$normals)) 
      args <- c(args, list(normals = t(x$normals[,x$ib])))
    if (!is.null(x$texcoords) && is.null(args$texcoords))
      args <- c(args, list(texcoords = t(x$texcoords[,x$ib])))
    
    result <- c(result, quads = do.call("quads3d", args = args ))
  }
  invisible(result)
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

