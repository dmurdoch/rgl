plot3d <- function(x, ...) UseMethod("plot3d")


plot3d.default <- function(x, y = NULL, z = NULL, 
        xlab = NULL, ylab = NULL, zlab = NULL, type = 'p', 
        col = material3d("color")[1], size = material3d("size"), 
        radius = avgscale*size/20, add = FALSE, aspect = !add, ...)
{
    if (!add) clear3d()
    skip <- par3d(skipRedraw=TRUE)
    on.exit(par3d(skip))
     	
    xlabel <- if (!missing(x)) deparse(substitute(x))
    ylabel <- if (!missing(y)) deparse(substitute(y))
    zlabel <- if (!missing(z)) deparse(substitute(z))
 
    xyz <- xyz.coords(x,y,z, xlab=xlabel, ylab=ylabel, zlab=zlabel, recycle=TRUE)
    x <- xyz$x
    y <- xyz$y
    z <- xyz$z

    if (is.null(xlab)) xlab <- xyz$xlab
    if (is.null(ylab)) ylab <- xyz$ylab
    if (is.null(zlab)) zlab <- xyz$zlab

    if (type == "s" && missing(radius)) {
	avgscale <- sqrt(sum(c(diff(range(x,na.rm=TRUE)), 
                               diff(range(y,na.rm=TRUE)), 
                               diff(range(z,na.rm=TRUE)))^2/3))
    }
    result <- c( data=switch(type,
		p = points3d(x, y, z, color=col, size=size, ...),
	        s = spheres3d(x, y, z, radius=radius, color=col, ...),
		l = lines3d(x, y, z, color=col, size=size, ...),
		h = segments3d(rep(x,rep(2,length(x))),
					   rep(y,rep(2,length(y))),
					   rbind(rep(0,length(z)),z),
					   color = rep(col, rep(2,length(col))), size=size, ...),
	# this is a hack to plot invisible segments
        n = if (!add) segments3d(rep(range(x), c(2,2)),
                                 rep(range(y), c(2,2)),
                                 rep(range(z), c(2,2))))
	)
    if (!add) result <- c(result, decorate3d(xlab=xlab, ylab=ylab, zlab=zlab, aspect = aspect, ...))
    invisible(result)
}

plot3d.qmesh3d <- function(x, xlab = "x", ylab = "y", zlab = "z", type = c("shade", "wire", "dots"),
	add = FALSE, ...)
{
    if (!add) clear3d()
    skip <- par3d(skipRedraw=TRUE)
    on.exit(par3d(skip))
    
    if (missing(xlab) && !is.null(x$xlab)) xlab <- x$xlab
    if (missing(ylab) && !is.null(x$ylab)) ylab <- x$ylab
    if (missing(zlab) && !is.null(x$zlab)) zlab <- x$zlab
    
    result <- switch(match.arg(type),
    	shade = shade3d(x, ...),
    	wire = wire3d(x, ...),
    	dots = dot3d(x, ...))
    
    if (!add) result <- c(result, decorate3d(xlab = xlab, ylab = ylab, zlab = zlab, ...))
    invisible(result)
}

decorate3d <- function(xlim = ranges$xlim, ylim = ranges$ylim, zlim = ranges$zlim, 
	xlab = "x", ylab = "y", zlab = "z", 
	box = TRUE, axes = TRUE, main = NULL, sub = NULL,
	top = TRUE, aspect = FALSE, ...) {

    if (is.logical(aspect)) {
    	autoscale <- aspect
    	aspect <- c(1,1,1)
    } else autoscale <- TRUE	

    ranges <- .getRanges()
    
    result <- numeric(0)

    if (!missing(xlim) | !missing(ylim) | !missing(zlim)) {
        ind <- c(1,1,2,2)
        result <- c(result, strut=segments3d(xlim[ind], ylim[ind], zlim[ind]))
    }
    
    if (axes) result <- c(result, axes=axes3d())
    if (box) result <- c(result, box=box3d())
    result <- c(result, title3d(xlab = xlab, ylab = ylab, zlab = zlab, 
	    main = main, sub = sub))
   
    if (autoscale) aspect3d(aspect)
    
    if (top) rgl.bringtotop()
    
    invisible(result)
}
