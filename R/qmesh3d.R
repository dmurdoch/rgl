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

dot3d.qmesh3d <- function ( x, ... ) points3d(x$vb[1,]/x$vb[4,],x$vb[2,]/x$vb[4,],x$vb[3,]/x$vb[4,], ... )
wire3d.qmesh3d <- function ( x, ... ) quads3d(x$vb[1,x$ib]/x$vb[4,x$ib],x$vb[2,x$ib]/x$vb[4,x$ib],x$vb[3,x$ib]/x$vb[4,x$ib], front="lines", back="lines", ... )
shade3d.qmesh3d <- function ( x, ... ) quads3d(x$vb[1,x$ib]/x$vb[4,x$ib],x$vb[2,x$ib]/x$vb[4,x$ib],x$vb[3,x$ib]/x$vb[4,x$ib], ... )

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
