plot3d <- function(x, ...) UseMethod("plot3d")


plot3d.default <- function(x, y = NULL, z = NULL, 
        xlab = NULL, ylab = NULL, zlab = NULL, type = 'p', 
        col = material3d("color")[1], size = material3d("size"), 
        lwd = material3d("lwd"),
        radius = avgscale*size/60, add = FALSE, aspect = !add, ...)
{
    if (!add) next3d()
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
		l = lines3d(x, y, z, color=col, lwd=lwd, ...),
		h = segments3d(rep(x,rep(2,length(x))),
					   rep(y,rep(2,length(y))),
					   rbind(rep(0,length(z)),z),
					   color = rep(col, rep(2,length(col))), lwd=lwd, ...),
	# this is a hack to plot invisible segments
        n = if (!add) segments3d(rep(range(x, na.rm=TRUE), c(2,2)),
                                 rep(range(y, na.rm=TRUE), c(2,2)),
                                 rep(range(z, na.rm=TRUE), c(2,2))))
	)
    if (!add) result <- c(result, decorate3d(xlab=xlab, ylab=ylab, zlab=zlab, aspect = aspect, ...))
    invisible(result)
}

plot3d.mesh3d <- function(x, xlab = "x", ylab = "y", zlab = "z", type = c("shade", "wire", "dots"),
	add = FALSE, ...)
{
    if (!add) next3d()
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
	top = TRUE, aspect = FALSE, expand = 1.03, ...) {

    if (is.logical(aspect)) {
    	autoscale <- aspect
    	aspect <- c(1,1,1)
    } else autoscale <- TRUE	
    
    result <- numeric(0)    
    ranges <- .getRanges()    
    if (!missing(xlim) | !missing(ylim) | !missing(zlim)) {
        ind <- c(1,1,2,2)
        result <- c(result, strut=segments3d(xlim[ind], ylim[ind], zlim[ind]))
    }
    
    if (autoscale) aspect3d(aspect)
    
    if (axes) result <- c(result, axes=axes3d(box=box, expand=expand))
    result <- c(result, title3d(xlab = xlab, ylab = ylab, zlab = zlab, 
	    main = main, sub = sub))
    
    if (top) rgl.bringtotop()
    
    invisible(result)
}

plot3d.function <- function(x, xlim = c(0,1), ylim = c(0,1), zlim = NULL, 
    slim = NULL, tlim = NULL, n = 101,
    xvals = seq.int(min(xlim), max(xlim), length.out = n[1]), 
    yvals = seq.int(min(ylim), max(ylim), length.out = n[2]), 
    svals = seq.int(min(slim), max(slim), length.out = n[1]), 
    tvals = seq.int(min(tlim), max(tlim), length.out = n[2]),
    xlab = "x", ylab = "y", zlab = "z", col = "gray",
    otherargs = list(), ...) {
    f <- x
    n <- rep(n, length.out = 2)
    parametric <- !is.null(slim) || !is.null(tlim)
    if (!parametric) {
	nx <- length(xvals)
	ny <- length(yvals)
	xvals <- matrix(xvals, nx, ny)
	yvals <- matrix(yvals, nx, ny, byrow = TRUE)
	zvals <- do.call(f, c(list(c(xvals), c(yvals)), otherargs))
	dim(zvals) <- dim(xvals)
    } else {
	if (is.null(slim)) slim <- c(0,1)
	if (is.null(tlim)) tlim <- c(0,1)
	ns <- length(svals)
	nt <- length(tvals)
	svals <- matrix(svals, ns, nt)
	tvals <- matrix(tvals, ns, nt, byrow = TRUE)

	allvals <- do.call(f, c(list(c(svals), c(tvals)), otherargs))
	xvals <- matrix(allvals[,1], ns, nt)
	yvals <- matrix(allvals[,2], ns, nt)
	zvals <- matrix(allvals[,3], ns, nt)
    }
    truncate <- function(vals, range) {
	vals[vals < min(range) | vals > max(range)] <- NA
	vals
    }
    if (!parametric || !missing(xlim)) 
	xvals <- truncate(xvals, xlim)
    if (!parametric || !missing(ylim))
	yvals <- truncate(yvals, ylim)
    if (!is.null(zlim))
	zvals <- truncate(zvals, zlim)
	
    if (is.function(col)) {
	zmin <- min(zvals, na.rm = TRUE)
	zscale <- 1/(max(zvals, na.rm = TRUE) - zmin)
	colfn <- colorRamp(col(100))
	colrgba <- colfn(c((zvals - zmin)*zscale))
	colrgba[is.na(colrgba)] <- 0
	col <- rgb(colrgba, maxColorValue = 255)
	dim(col) <- dim(zvals)
    }
	
    persp3d(xvals, yvals, zvals, col = col, 
    	    xlab = xlab, ylab = ylab, zlab = zlab, ...)
}
