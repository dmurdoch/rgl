cone3d <- function(base,tip,rad,n=30,draw.base=TRUE,...) {
  ax <- tip-base
  if (ax[1]!=0) {
    p1 <- c(-ax[2]/ax[1],1,0)
    p1 <- p1/sqrt(sum(p1^2))
    if (p1[1]!=0) {
      p2 <- c(-p1[2]/p1[1],1,0)
      p2[3] <- -sum(p2*ax)
      p2 <- p2/sqrt(sum(p2^2))
    } else {
      p2 <- c(0,0,1)
    }
  } else if (ax[2]!=0) {
    p1 <- c(0,-ax[3]/ax[2],1)
    p1 <- p1/sqrt(sum(p1^2))
    if (p1[1]!=0) {
      p2 <- c(0,-p1[3]/p1[2],1)
      p2[3] <- -sum(p2*ax)
      p2 <- p2/sqrt(sum(p2^2))
    } else {
      p2 <- c(1,0,0)
    }
  } else {
    p1 <- c(0,1,0); p2 <- c(1,0,0)
  }
  degvec <- seq(0,2*pi,length=n)
  ecoord2 <- function(theta) {
    base+rad*(cos(theta)*p1+sin(theta)*p2)
  }
  v <- cbind(sapply(degvec,ecoord2),tip)
  i <- rbind(1:n,c(2:n,1),rep(n+1,n))
  if (draw.base) {
    v <- cbind(v,base)
    i <- cbind(i,rbind(1:n,c(2:n,1),rep(n+2,n)))
  }
  triangles3d(v[1,i],v[2,i],v[3,i])
}

ellipsoid3d <- function(a=2,b=3,c=1,n=30,ctr=c(0,0,0),...) {
 degvec <- seq(0,2*pi,length=n)
 ecoord2 <- function(p) {
   c(a*cos(p[1])*sin(p[2]),b*sin(p[1])*sin(p[2]),c*cos(p[2])) }
 v <- apply(expand.grid(degvec,degvec),1,ecoord2)
 e <- expand.grid(1:(n-1),1:n)
 i1 <- apply(e,1,function(z)z[1]+n*(z[2]-1))
 i2 <- i1+1
 i3 <- (i1+n-1) %% n^2 + 1
 i4 <- (i2+n-1) %% n^2 + 1
 i <- rbind(i1,i3,i2,i4)
 quads3d(v[1,i],v[2,i],v[3,i],...)
}

clear3d()
ellipsoid3d(ctr=c(2,2,2),col="red",alpha=0.4)
cone3d(base=c(-2,-2,-2),rad=0.5,tip=c(-3,0,-4),col="blue",front="lines",back="lines")
shade3d(translate3d(cube3d(),3,-2,3,col="purple")
