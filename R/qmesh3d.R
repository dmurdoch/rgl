#
# R 3d object : qmesh3d
#

qmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL ) {
  if (homogeneous == TRUE)
    vrows <- 4
  else
    vrows <- 3
  object <- list(
    vb=matrix(vertices,nrow=vrows),
    ib=matrix(indices,nrow=4),
    primitivetype="quad",
    homogeneous=homogeneous,
    material=material
  ) 
  class(object) <- "qmesh3d" 
  return( object )
}

# rendering support

dot3d.qmesh3d <- function ( x, override = TRUE, ... ) {
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
  
  do.call("quads3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                   y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                   z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                              material))
}

# transformation support

translate3d.qmesh3d <- function ( obj, x, y, z, ... ) {
  obj$vb <- t(translate3d(t(obj$vb), x, y, z))
  return(obj)                            
}  

rotate3d.qmesh3d <- function ( obj,angle,x,y,z,matrix, ... ) {
  obj$vb <- t(rotate3d(t(obj$vb), angle, x, y, z, matrix))
  return(obj)                            
}  

scale3d.qmesh3d <- function ( obj, x, y, z, ... ) {
  obj$vb <- t(scale3d(t(obj$vb), x, y, z))
  return(obj)
}
