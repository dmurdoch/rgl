plot3d <- function(x, ...) UseMethod("plot3d")

plot3d.default <- function(x, y = NULL, z = NULL, 
        xlim = ranges$xlim, ylim = ranges$ylim, zlim = ranges$zlim, 
	xlab = NULL, ylab = NULL, zlab = NULL, type = 'p', col = 'white', 
	box = TRUE, axes = TRUE, add = FALSE, main = NULL, sub = NULL,
	top = TRUE, ...)
{
    if (!add) clear3d()
    skip <- par3d(skipRedraw=TRUE,...)
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

    switch(type,
		p = points3d(x, y, z, col=col),
		l = lines3d(x, y, z, col=col),
		h = segments3d(rep(x,rep(2,length(x))),
					   rep(y,rep(2,length(y))),
					   rbind(rep(0,length(z)),z),
					   col = rep(col, rep(2,length(col)))),
	# this is a hack to plot invisible segments
        n = if (!add) segments3d(rep(range(x), c(2,2)),
                                 rep(range(y), c(2,2)),
                                 rep(range(z), c(2,2)))
	)

    ranges <- par3d('bbox')
    if (!missing(xlim)) ranges[1:2] <- xlim
    if (!missing(ylim)) ranges[3:4] <- ylim
    if (!missing(zlim)) ranges[5:6] <- zlim

    if (!missing(xlim) | !missing(ylim) | !missing(zlim)) {
	    segments3d(matrix(ranges[rep(1:6, rep(2,6))], 4, 3))
    }
    if (!add) {
    	if (axes) axes3d()
	if (box) box3d()
	title3d(xlab = xlabel, ylab = ylabel, zlab = zlabel, 
		main = main, sub = sub)
    }
    if (top) rgl.bringtotop()
}
