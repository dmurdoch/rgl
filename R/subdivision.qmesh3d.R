# 
# subdivision.qmesh3d
#
# an *efficient* algorithm for subdivision of qmesh3d objects
# using addition operations and homogenous coordinates 
# by Daniel Adler 
#
# $Id$
# 

edgemap <- function( size ) {
  data<-vector( mode="numeric", length=( size*(size+1) )/2 )
  data[] <- -1
  return(data)
}

edgeindex <- function( from, to, size, row=min(from,to), col=max(from,to) )
  return( row*size - ( row*(row+1) )/2 - (size-col) )

divide.qmesh3d <- function (mesh,vb=mesh$vb, ib=mesh$ib ) {
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

normalize.qmesh3d <- function (mesh) {
  mesh$vb[1,] <- mesh$vb[1,]/mesh$vb[4,]
  mesh$vb[2,] <- mesh$vb[2,]/mesh$vb[4,]
  mesh$vb[3,] <- mesh$vb[3,]/mesh$vb[4,]
  mesh$vb[4,] <- 1
  return (mesh)
}

deform.qmesh3d <- function( mesh, vb=mesh$vb, ib=mesh$ib )
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
  mesh$vb <- out
  return(mesh)
}

subdivision3d.qmesh3d <- function(mesh,depth=1,normalize=FALSE,deform=TRUE) {
  if (depth) {
    mesh <- divide.qmesh3d(mesh)
    if (normalize)
      mesh <- normalize.qmesh3d(mesh)
    if (deform)
      mesh <- deform.qmesh3d(mesh)      
    mesh<-subdivision3d.qmesh3d(mesh,depth-1,normalize,deform)
  }
  return(mesh)  
}

