# rgl-demo: subdivision surfaces
# author: Daniel Adler
# notes: demo contains preview material of r3d, a generic 3D interface for R
# $Id: subdivision.r,v 1.4 2004/09/03 13:51:06 dadler Exp $
  
# 3d meshes
  
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

dot3d.qmesh3d <- function ( x, ... ) points3d(x$vb[1,]/x$vb[4,],x$vb[2,]/x$vb[4,],x$vb[3,]/x$vb[4,], ... )
wire3d.qmesh3d <- function ( x, ... ) quads3d(x$vb[1,x$ib]/x$vb[4,x$ib],x$vb[2,x$ib]/x$vb[4,x$ib],x$vb[3,x$ib]/x$vb[4,x$ib], front="lines", back="lines", ... )
shade3d.qmesh3d <- function ( x, ... ) quads3d(x$vb[1,x$ib]/x$vb[4,x$ib],x$vb[2,x$ib]/x$vb[4,x$ib],x$vb[3,x$ib]/x$vb[4,x$ib], ... )

cube3d.vb <- c(
  -1.0, -1.0, -1.0, 1.0,
   1.0, -1.0, -1.0, 1.0,
  -1.0,  1.0, -1.0, 1.0,
   1.0,  1.0, -1.0, 1.0,
  -1.0, -1.0,  1.0, 1.0,
   1.0, -1.0,  1.0, 1.0,
  -1.0,  1.0,  1.0, 1.0,
   1.0,  1.0,  1.0, 1.0
)

cube3d.ib <- c(
  1, 3, 4, 2,
  3, 7, 8, 4,
  2, 4, 8, 6,
  1, 5, 7, 3,
  1, 2, 6, 5,
  5, 6, 8, 7      
)
  
cube3d <- function()
  return( qmesh3d( cube3d.vb, cube3d.ib ) )

o3d.vb <- c(   
    -1.5, -1.5, -0.5, 1.0,   # 1
    -0.5, -1.5, -0.5, 1.0,   # 2
     0.5, -1.5, -0.5, 1.0,   # 3
     1.5, -1.5, -0.5, 1.0,   # 4

    -1.5, -0.5, -0.5, 1.0,   # 5
    -0.5, -0.5, -0.5, 1.0,   # 6
     0.5, -0.5, -0.5, 1.0,   # 7
     1.5, -0.5, -0.5, 1.0,   # 8

    -1.5,  0.5, -0.5, 1.0,   # 9
    -0.5,  0.5, -0.5, 1.0,   # 10
     0.5,  0.5, -0.5, 1.0,   # 11
     1.5,  0.5, -0.5, 1.0,   # 12
     
    -1.5,  1.5, -0.5, 1.0,   # 13 
    -0.5,  1.5, -0.5, 1.0,   # 14
     0.5,  1.5, -0.5, 1.0,   # 15
     1.5,  1.5, -0.5, 1.0,   # 16

     
    -1.5, -1.5,  0.5, 1.0,   # 17
    -0.5, -1.5,  0.5, 1.0,   # 18
     0.5, -1.5,  0.5, 1.0,   # 19
     1.5, -1.5,  0.5, 1.0,   # 20

    -1.5, -0.5,  0.5, 1.0,   # 21
    -0.5, -0.5,  0.5, 1.0,   # 22
     0.5, -0.5,  0.5, 1.0,   # 23 
     1.5, -0.5,  0.5, 1.0,   # 24

    -1.5,  0.5,  0.5, 1.0,   # 25
    -0.5,  0.5,  0.5, 1.0,   # 26
     0.5,  0.5,  0.5, 1.0,   # 27
     1.5,  0.5,  0.5, 1.0,   # 28
     
    -1.5,  1.5,  0.5, 1.0,   # 29
    -0.5,  1.5,  0.5, 1.0,   # 30
     0.5,  1.5,  0.5, 1.0,   # 31
     1.5,  1.5,  0.5, 1.0    # 32         
)

o3d.ib <- c(
    1,  5,  6,  2,    
    2,  6,  7,  3,    
    3,  7,  8,  4,
    
    5,  9, 10,  6,    
    7, 11, 12,  8,
    
    9, 13, 14, 10,
   10, 14, 15, 11,
   11, 15, 16, 12,
   
   17, 18, 22, 21,
   18, 19, 23, 22,
   19, 20, 24, 23,
   
   21, 22, 26, 25,
   23, 24, 28, 27,
   
   25, 26, 30, 29,
   26, 27, 31, 30,
   27, 28, 32, 31,
   
    1,  2, 18, 17,
    2,  3, 19, 18,
    3,  4, 20, 19,
    
    6, 22, 23,  7,
   10, 11, 27, 26,
   
   13, 29, 30, 14,
   14, 30, 31, 15,
   15, 31, 32, 16,
   
   17, 21,  5,  1,
   21, 25,  9,  5,
   25, 29, 13,  9,
   
    4,  8, 24, 20,
    8, 12, 28, 24,
   12, 16, 32, 28,
   
    6, 10, 26, 22,
    7, 23, 27, 11  
)

o3d <- qmesh3d( o3d.vb, o3d.ib )  
  
  
  
  
#
# subdivision3d
#

dragpoint <- function( mesh, vb=mesh$vb, ib=mesh$ib )
{
  nv <- dim(vb)[2]
  nq <- dim(ib)[2]
  out <- matrix( nrow=4, ncol=nv )
  out[] <- 0
  for ( i in 1:nq ) {
    for (j in 1:4 ) {
      iprev <- ib[((j-2)%%4) + 1, i]
      ithis <- ib[j,i]
      inext <- ib[ (j%%4)    + 1, i]
      out[ ,ithis ] <- out[ , ithis ] + vb[,iprev] + vb[,ithis] + vb[,inext]
    }
  }
  mesh$dp <- out
  return(mesh)
}
  
  
surfacepoint <- function( mesh, vb=mesh$vb, ib=mesh$ib, dp=mesh$dp )
{
  nv  <- dim(vb)[2]
  nq  <- dim(ib)[2]
  
  sp <- matrix( nrow=4, ncol=nq )
  sp[] <- 0
  for ( i in 1:nq )
    for ( j in 1:4 ) 
      sp[,i] <- sp[,i] + vb[,ib[j,i]] # + dp[,ib[j,i]] # %*% c(1,1,1,1)
  
  mesh$sp <- sp
  
  return(mesh)
}
  
edgemap <- function( size ) {
  data<-vector( mode="numeric", length=( size*(size+1) )/2 )
  data[] <- -1
  return(data)
}

edgeindex <- function( from, to, size, row=min(from,to), col=max(from,to) )
  return( row*size - ( row*(row+1) )/2 - (size-col) )

edgepoint <- function(mesh, vb=mesh$vb, ib=mesh$ib, sp=mesh$sp, dp=mesh$dp )
{ 
  nv <- dim(vb)[2]
  nq <- dim(ib)[2]
  ep <- matrix( nrow=4, ncol=(nv*(nv+1))/2 )
  ep[] <- 0
  em <- edgemap( nv )
  nc <- 0
  for ( i in 1:nq ) {
    for ( j in 1:4 ) { 
      from <- ib[j,i] 
      to   <- ib[(j%%4) + 1,i]
      mindex <- edgeindex(from, to, nv)      
      vindex <- em[mindex]
      if (vindex == -1 ) {        
        nc <- nc + 1
        vindex <- nc
        em[ mindex ] <- vindex
      } 
      ep[ , vindex ] <- ep[ ,vindex] + sp[,i] + vb[,from] +  vb[,to]
    }
  }
  mesh$ep <- ep[,1:nc]
  mesh$em <- em
  return( mesh )
}


genindex <- function (mesh, ib=mesh$ib, vb=mesh$vb, em=mesh$em )
{
  nv <- dim(vb)[2]
  nq <- dim(ib)[2]
  outvb <- matrix( 
    data=c(mesh$dp, mesh$sp, mesh$ep),
    nrow=4,
    byrow=F
  )     
  outib <- matrix( nrow=4, ncol=nq*4 )
  
  for( i in 1:nq ) {     
    for (j in 1:4 ) {

      iprev <- ib[((j-2)%%4) + 1, i]
      ithis <- ib[j,i]
      inext <- ib[ (j%%4)    + 1, i]
      
      outib[, (i-1)*4+j ] <- c( 
        ithis, 
        nv + nq + em[edgeindex(ithis,inext,nv)],
        nv +  i,
        nv + nq + em[edgeindex(iprev,ithis,nv)]
      )
    }
  } 
  mesh$outib <- outib
  mesh$outvb <- outvb
  return(mesh)
}

subdivision3d.qmesh3d <- function( x, depth=1, ... ) {
  while( depth > 0 ) {
    x <- dragpoint( x )
    x <- surfacepoint( x )
    
    x <- edgepoint( x )
    x <- genindex( x )  
    x <- qmesh3d( x$outvb, x$outib )
    depth <- depth - 1
  }
  return(x)
}

normalize.qmesh3d <- function (mesh) {
  mesh$vb[1,] <- mesh$vb[1,]/mesh$vb[4,]
  mesh$vb[2,] <- mesh$vb[2,]/mesh$vb[4,]
  mesh$vb[3,] <- mesh$vb[3,]/mesh$vb[4,]
  mesh$vb[4,] <- 1
  return (mesh)
}

subdivide.qmesh3d <- function (mesh,ib=mesh$ib, vb=mesh$vb ) {
  nv    <- dim(vb)[2]
  nq    <- dim(ib)[2]
  nvmax <- nv + nq + ( nv*(nv+1) )/2
  newnq <- nq*4
  outvb <- matrix(data=0,nrow=4,ncol=nvmax)
  outib <- matrix(nrow=4,ncol=newnq)
  em    <- edgemap( nv )  
  
  # copy old points
  for (i in 1:nv ) {
    outvb[,i] <- vb[,i]
  }

  vcnt  <- nv + nq
  
  for (i in 1:nq ) {
    isurf <- nv + i
    for (j in 1:4 ) {
      
      iprev <- ib[((j-2)%%4) + 1, i]
      ithis <- ib[j,i]
      inext <- ib[ (j%%4)    + 1, i]
      
      # get or alloc edge-point this->next
      mindex <- edgeindex(ithis, inext, nv)
      enext <- em[mindex]
      if (enext == -1) {
        vcnt       <- vcnt + 1
        enext      <- vcnt
        em[mindex] <- enext
      }

      # get or alloc edge-point prev->this
      mindex <- edgeindex(iprev, ithis, nv)
      eprev <- em[mindex]
      if (eprev == -1) {
        vcnt       <- vcnt + 1
        eprev      <- vcnt
        em[mindex] <- eprev
      }

      # gen grid      
      outib[, (i-1)*4+j ] <- c( ithis, enext, isurf, eprev )

      # calculate surface point
      outvb[,isurf] <- outvb[,isurf] + vb[,ithis]
      
      # calculate edge point
      outvb[,enext] <- outvb[,enext] + vb[,ithis] 
      outvb[,eprev] <- outvb[,eprev] + vb[,ithis] 

    }
  }
  return ( qmesh3d(outvb[,1:vcnt], outib) )
}

subdivision3d.demo1 <- function() {  
  redcube <- cube3d( material=list(color="red") )  
}

#
# R3D - rgl implementation
# 

require(rgl)


translate3d.qmesh3d <- function ( x, tx, ty, tz ) {
  for ( i in 1:(dim(x$vb)[2]) ) {
  x$vb[,i] <- matrix( 
    data=c( 1, 0, 0,tx,
            0, 1, 0,ty,
            0, 0, 1,tz,
            0, 0, 0, 1 ), nrow=4, ncol=4, byrow=T) %*%  x$vb[,i] 
  }
  return(x)                            
}


subdivide <- function(mesh,normalize=F,depth=1) {
  if (depth) {
    mesh <- subdivide.qmesh3d(mesh)
    if (normalize)
      mesh <- normalize.qmesh3d(mesh)
    mesh <- dragpoint(mesh)      
    mesh$vb <- mesh$dp
    mesh<-subdivide(mesh,normalize,depth-1)
  }
  return(mesh)  
}

render.part <- function(x, tx,depth, func, color, ...) {
  x <- translate3d(x,tx,0,0)
  shade3d(x, color="gray30",front="lines",alpha=0.5,back="lines")
  shade3d(func(x,depth=depth, ...), alpha=0.5, color=color )
}

render.levels <- function(ty,func, ... ) {
  x <- translate3d(o3d,0,ty,0)
  render.part(x,-5.5, 0,func, "blue",   ... )
  render.part(x,-1.75,1,func, "yellow", ... )
  render.part(x, 1.75,2,func, "red",    ... )
  render.part(x, 5.5, 3,func, "green",  ... )
}

clear3d()
clear3d(type="bbox")
clear3d(type="lights")
bg3d(color="gray")
light3d()

rgl.clear()
rgl.clear(type="bbox")
rgl.clear(type="lights")
rgl.bg(color="gray")
rgl.light()
render.levels( 0, func=subdivide, normalize=F )

