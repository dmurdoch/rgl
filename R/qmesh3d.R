#
# R 3d object : qmesh3d
#

qmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL ) {
  if (homogeneous == TRUE)
    vrows <- 4
  else
    vrows <- 3
  if ( !is.null(normals) ) {
    normals <- xyz.coords(normals, recycle=TRUE)
    nvertex <- length(vertices)/vrows
    x <- rep(normals$x, len=nvertex)
    y <- rep(normals$y, len=nvertex)
    z <- rep(normals$z, len=nvertex)
    normals <- rgl.vertex(x,y,z)
  }
  object <- list(
    vb=matrix(vertices,nrow=vrows),
    ib=matrix(indices,nrow=4),
    primitivetype="quad",
    material=material,
    normals=normals
  ) 
  
  if (!homogeneous) object$vb <- rbind(object$vb, 1)
  
  class(object) <- c("qmesh3d", "mesh3d", "shape3d")
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
  
wire3d.qmesh3d <- function ( x, override = TRUE, ... ) {
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
  
  do.call("quads3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                   y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                   z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                              material))
}

shade3d.qmesh3d <- function ( x, override = TRUE, ... ) {
  if ( override ) {
    material <- x$material
    if (is.null(material)) material <- list()    
    material[names(list(...))] <- list(...)
  } else {
    material <- list(...)
    material[names(x$material)] <- x$material
  }
  if ( is.null(x$normals) ) 
    do.call("quads3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                     y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                     z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                                material))
  else
    do.call("quads3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                     y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                     z = x$vb[3,x$ib]/x$vb[4,x$ib],
                                     normals = t(x$normals[,x$ib])), 
                                material))                                
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
    else
      obj$normals <- rotate3d(t(obj$normals), angle, x, y, z, t(solve(matrix)))
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

