
axis3d <- function(side=1:3,at,lim,labels,arrow=FALSE,arrow.type=c("arrow","cone"),
                     x,y,z,lwd=1,
                     alen=0.05,awid=0.01,...) {
  ## wishlist: ticktypes, labels in margins, ticks,
  ## choice of which side to put axes on (front/back/etc.)
  if ((!missing(at) || !missing(labels) || !missing(lim)) &&
      length(side)>1)
    warning("at/labels/lim will be identical for all axes")
  arrow.type <- match.arg(arrow.type)
  bbox <- par3d("bbox")
  if (missing(x)) x <- bbox[1]
  if (missing(y)) y <- bbox[3]
  if (missing(z)) z <- bbox[5]
  ## mgp <- par("mgp")  ## turns on 2D graphics window! not used yet ...
  if (missing(lim)) lim <- NULL
  if (missing(at)) at <- NULL
  if (missing(labels)) labels <- "auto"
  tmpf <- function(s) {
    if (is.null(lim)) {
      if (is.null(at)) lim1 <- bbox[2*s+c(-1,0)] else
      lim1 <- range(at)
    } else lim1 <- lim
    if (is.null(at)) {
      at1 <- pretty(lim1)
      at1 <- at1[at1>=min(lim1) & at1<=max(lim1)]
    } else at1 <- at
    if (identical(labels,"auto")) labels1 <- as.character(at1) else labels1 <- labels
    diffs <- bbox[c(2,4,6)]-bbox[c(1,3,5)]
    switch(s,
           ## x (side==1)
         {lines3d(lim1,rep(y,2),rep(z,2),size=lwd,...)
          if (!is.null(labels1))
            text3d(at1,y,z,labels1,...)
          if (arrow) {
            if (arrow.type=="arrow") { triangles3d(lim1[2]+c(0,1,0)*alen*diffs[1],
                         y+c(-1,0,1)*awid*diffs[2],
                         z+c(-1,0,1)*awid*diffs[3],lit=FALSE,...)
            } else {
              cone3d(base=c(lim1[2],y,z),tip=c(lim1[2]+alen*diffs[1],y,z),
                       rad=awid*diffs[2],lit=FALSE,...)
            }}},
           ## y (side==2)
         {lines3d(rep(x,2),lim1,rep(z,2),size=lwd,...)
          if (!is.null(labels1))
            text3d(x,at1,z,labels1,...)
          if (arrow) {
            if (arrow.type=="arrow") { triangles3d(x+c(-1,0,1)*awid*diffs[1],
                         lim1[2]+c(0,1,0)*alen*diffs[2],
                         z+c(-1,0,1)*awid*diffs[3],lit=FALSE,...)
            } else {
              cone3d(base=c(x,lim1[2],z),tip=c(x,lim1[2]+alen*diffs[2],z),
                       rad=awid*diffs[1],lit=FALSE,...)
            }}},             
           ## z (side==3)
         { lines3d(rep(x,2),rep(y,2),size=lwd,lim1,...)
           if (!is.null(labels1))
             text3d(x,y,at1,labels1,...)
           if (arrow) {
             if (arrow.type=="arrow") { triangles3d(x+c(-1,0,1)*awid*diffs[1],
                   y+c(-1,0,1)*awid*diffs[2],
                   lim1[2]+c(0,1,0)*alen*diffs[3],lit=FALSE,...)
             } else {
               cone3d(base=c(x,y,lim1[2]),tip=c(x,y,lim1[2]+alen*diffs[2]),
                        rad=awid*diffs[1],lit=FALSE,...)
             }}})
  }
  invisible(sapply(side,tmpf))
}


cone3d <- function(base=c(0,0,0),tip=c(0,0,1),rad=1,n=30,draw.base=TRUE,qmesh=FALSE,
                   trans = par3d("userMatrix"), ...) {
  ax <- tip-base
  if (missing(trans) && !rgl.cur()) trans <- diag(4)
  ### is there a better way?
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
  degvec <- seq(0,2*pi,length=n+1)[-1]
  ecoord2 <- function(theta) {
    base+rad*(cos(theta)*p1+sin(theta)*p2)
  }
  i <- rbind(1:n,c(2:n,1),rep(n+1,n))
  v <- cbind(sapply(degvec,ecoord2),tip)
  if (qmesh) 
    ## minor kluge for quads -- draw tip twice
    i <- rbind(i,rep(n+1,n))
  if (draw.base) {
    v <- cbind(v,base)
    i.x <- rbind(c(2:n,1),1:n,rep(n+2,n))
    if (qmesh)  ## add base twice
      i.x <-  rbind(i.x,rep(n+2,n))
    i <- cbind(i,i.x)
  }
  if (qmesh) v <- rbind(v,rep(1,ncol(v))) ## homogeneous
  if (!qmesh)
    triangles3d(v[1,i],v[2,i],v[3,i],...)
  else
    return(rotate3d(qmesh3d(v,i,material=...), matrix=trans))
}     


ellipsoid3d <- function(rx=1,ry=1,rz=1,n=30,ctr=c(0,0,0),
                        qmesh=FALSE,
                        trans = par3d("userMatrix"),...) {
  if (missing(trans) && !rgl.cur()) trans <- diag(4)
  degvec <- seq(0,2*pi,length=n)
  ecoord2 <- function(p) {
    c(rx*cos(p[1])*sin(p[2]),ry*sin(p[1])*sin(p[2]),rz*cos(p[2])) }
  v <- apply(expand.grid(degvec,degvec),1,ecoord2)
  if (qmesh) v <- rbind(v,rep(1,ncol(v))) ## homogeneous
  e <- expand.grid(1:(n-1),1:n)
  i1 <- apply(e,1,function(z)z[1]+n*(z[2]-1))
  i2 <- i1+1
  i3 <- (i1+n-1) %% n^2 + 1
  i4 <- (i2+n-1) %% n^2 + 1
  i <- rbind(i1,i2,i4,i3)
  if (!qmesh)
    quads3d(v[1,i],v[2,i],v[3,i],...)
  else return(rotate3d(qmesh3d(v,i,material=...),matrix=trans))
}

############
clear3d()
ellipsoid3d(ctr=c(2,2,2),rx=3,ry=2,col="red",alpha=0.4)
cone3d(base=c(-2,-2,-2),rad=0.5,tip=c(-3,0,-4),col="blue",front="lines",back="lines")
shade3d(translate3d(cube3d(),3,-2,3,col="purple"))

### now with qmesh()
clear3d()
q1 <- cone3d(qmesh=TRUE,trans=diag(4))  ## the "unit cone";
                                        ## height=1,radius=1, base at (0,0,0)
shade3d(q1)
## various transformations and rotations
wire3d(translate3d(q1,3,0,0),col="green")
wire3d(translate3d(scale3d(q1,1,1,2),6,0,0),col="green")
dot3d(translate3d(q1,0,3,0),col="green")
dot3d(translate3d(scale3d(q1,2,1,1),0,6,0),col="green")
shade3d(translate3d(q1,0,0,3),col="red")
shade3d(translate3d(rotate3d(scale3d(q1,1,1,2),pi/4,0,1,0),0,0,6),col="red")

axis3d()
clear3d()

s1 <- ellipsoid3d(qmesh=TRUE,trans=diag(4))  ## the "unit sphere";
                                        ## radius=1, ctr at (0,0,0)
shade3d(s1)
## various transformations and rotations
wire3d(translate3d(s1,3,0,0),col="green")
wire3d(translate3d(scale3d(s1,1,1,2),6,0,0),col="green")
dot3d(translate3d(s1,0,3,0),col="green")
dot3d(translate3d(scale3d(s1,2,1,1),0,6,0),col="green")
shade3d(translate3d(s1,0,0,3),col="red")
shade3d(translate3d(rotate3d(scale3d(s1,1,1,2),pi/4,0,1,0),0,0,6),col="red")

axis3d()
