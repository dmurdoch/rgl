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

# translation support

translate3d.qmesh3d <- function ( x, tx, ty, tz ) {
  for ( i in 1:(dim(x$vb)[2]) ) {
  x$vb[,i] <- matrix( 
    data=c( 1, 0, 0,tx,
            0, 1, 0,ty,
            0, 0, 1,tz,
            0, 0, 0, 1 ), nrow=4, ncol=4, byrow=TRUE) %*%  x$vb[,i] 
  }
  return(x)                            
}  

