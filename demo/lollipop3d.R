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

cone3d <- function(base,tip,rad,n=30,...) {
  degvec <- seq(0,2*pi,length=n)
  ax <- tip-base
  ## what do if ax[1]==0?
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
  ecoord2 <- function(theta) {
    base+rad*(cos(theta)*p1+sin(theta)*p2)
  }
    for (i in 1:(n-1)) {
      li <- ecoord2(degvec[i])
      lj <- ecoord2(degvec[i+1])
      triangles3d(c(li[1],lj[1],tip[1]),c(li[2],lj[2],tip[2]),c(li[3],lj[3],tip[3]),...)
    }   
}

lollipop3d <- function(data.x,data.y,data.z,surf.fun,surf.n=50,
                         xlim=range(data.x),
			 ylim=range(data.y),
			 zlim=range(data.z),
                         asp=c(y=1,z=1),
			 xlab=deparse(substitute(x)),
			 ylab=deparse(substitute(y)),
			 zlab=deparse(substitute(z)),
			 axlabpos=1,
			 alpha.surf=0.4,
                         col.surf=fg,col.stem=c(fg,fg),
                         col.pt="gray",type.surf="line",ptsize,
                         lwd.stem=2,lit=TRUE,bg="white",fg="black",
                         col.axes=fg,col.axlabs=fg,
                         axis.arrow=TRUE,axis.labels=TRUE,
                         box.col=bg,
                         axes=c("lines","box")) {
  axes <- match.arg(axes)
  col.stem <- rep(col.stem,length=2)
  x.ticks <- pretty(xlim)
  x.ticks <- x.ticks[x.ticks>=min(xlim) & x.ticks<=max(xlim)]
  x.ticklabs <- if (axis.labels) as.character(x.ticks) else NULL
  y.ticks <- pretty(ylim)
  y.ticks <- y.ticks[y.ticks>=min(ylim) & y.ticks<=max(ylim)]
  y.ticklabs <- if (axis.labels) as.character(y.ticks) else NULL
  z.ticks <- pretty(zlim)
  z.ticks <- z.ticks[z.ticks>=min(zlim) & z.ticks<=max(zlim)]
  z.ticklabs <- if (axis.labels) as.character(z.ticks) else NULL
  if (!missing(surf.fun)) {
    surf.x <- seq(xlim[1],xlim[2],length=surf.n)
    surf.y <- seq(ylim[1],ylim[2],length=surf.n)
    surf.z <- outer(surf.x,surf.y,surf.fun)  ## requires surf.fun be vectorized
    z.interc <- surf.fun(data.x,data.y)
    zdiff <- diff(range(c(surf.z,data.z)))
  } else {
    z.interc <- rep(min(data.z),length(data.x))
    zdiff <- diff(range(data.z))
  }
  xdiff <- diff(xlim)
  ydiff <- diff(ylim)
  y.adj <- if (asp[1]<=0) 1 else asp[1]*xdiff/ydiff
  data.y <- y.adj*data.y
  y.ticks <- y.adj*y.ticks
  ylim <- ylim*y.adj
  ydiff <- diff(ylim)
  z.adj <- if (asp[2]<=0) 1 else asp[2]*xdiff/zdiff
  data.z <- z.adj*data.z
  if (!missing(surf.fun)) {
    surf.y <- y.adj*surf.y
    surf.z <- z.adj*surf.z
  }
  z.interc <- z.adj*z.interc
  z.ticks <- z.adj*z.ticks
  zlim <- z.adj*zlim
  clear3d("all")
  light3d()
  bg3d(color=c(bg,fg))
  if (!missing(surf.fun)) 
    surface3d(surf.x,surf.y,surf.z,alpha=alpha.surf,
                front=type.surf,back=type.surf,
                col=col.surf,lit=lit)
  if (missing(ptsize)) ptsize <- 0.02*xdiff
  ## draw points
  spheres3d(data.x,data.y,data.z,r=ptsize,lit=lit,color=col.pt)
  ## draw lollipops
  apply(cbind(data.x,data.y,data.z,z.interc),1,
        function(X) {
          lines3d(x=rep(X[1],2),
                  y=rep(X[2],2),
                  z=c(X[3],X[4]),
                  col=ifelse(X[3]>X[4],col.stem[1],
                    col.stem[2]),size=lwd.stem)
        })
  bbox <- par3d("bbox")
  if (axes=="box") {
    bbox3d(xat=x.ticks,xlab=x.ticklabs,
             yat=y.ticks,ylab=y.ticklabs,
             zat=z.ticks,zlab=z.ticklabs,lit=lit)
  } else if (axes=="lines") { ## set up axis lines
    bbox <- par3d("bbox")
    axis3d(side=1,at=x.ticks,labels=x.ticklabs,
           lim=bbox[1:2],y=bbox[3],z=bbox[5],
           col=col.axes,arrow=axis.arrow)
    axis3d(side=2,at=y.ticks,labels=y.ticklabs,
           lim=bbox[3:4],x=bbox[1],z=bbox[5],
           col=col.axes,arrow=axis.arrow)
    axis3d(side=3,at=z.ticks,labels=z.ticklabs,
           lim=bbox[5:6],x=bbox[1],y=bbox[3],
           col=col.axes,arrow=axis.arrow)
  }
  xlabpos <- sum(c(1-axlabpos,axlabpos)*bbox[1:2])
  ylabpos <- sum(c(1-axlabpos,axlabpos)*bbox[3:4])
  zlabpos <- sum(c(1-axlabpos,axlabpos)*bbox[5:6])
  text3d(xlabpos,bbox[3],bbox[5],xlab,col=col.axlabs)
  text3d(bbox[1],ylabpos,bbox[5],ylab,col=col.axlabs)
  text3d(bbox[1],bbox[3],zlabpos,zlab,col=col.axlabs)
}

x <- 1:5
y <- x*10
z <- (x+y)/20
spheres3d(x,y,z)
axis3d()
set.seed(1001)
x <- runif(30)
y <- runif(30,max=2)
dfun <- function(x,y) { 2*x+3*y+2*x*y+3*y^2 }
z <- dfun(x,y)+rnorm(30,sd=0.5)
## lollipops only
lollipop3d(x,y,z)
## lollipops plus theoretical surface
lollipop3d(x,y,z,dfun,col.pt="red",col.stem=c("red","blue"))
## lollipops plus regression fit
linmodel <- lm(z~x+y)
dfun <- function(x,y) {predict(linmodel,newdata=data.frame(x=x,y=y))}
lollipop3d(x,y,z,dfun,col.pt="red",col.stem=c("red","blue"))

####
