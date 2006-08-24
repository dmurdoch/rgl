persp3d <- function(x, ...) UseMethod("persp3d")


persp3d.default <-
function (x = seq(0, 1, len = nrow(z)), y = seq(0, 1, len = ncol(z)),
    z, xlim = range(x), ylim = range(y), zlim = range(z, na.rm = TRUE),
    xlab = NULL, ylab = NULL, zlab = NULL, add = FALSE, aspect = !add, ...)
{
    if (!add) clear3d()
    skip <- par3d(skipRedraw=TRUE)
    on.exit(par3d(skip))
    
    if (is.null(xlab))
        xlab <- if (!missing(x)) deparse(substitute(x)) else "X"
    if (is.null(ylab))
        ylab <- if (!missing(y)) deparse(substitute(y)) else "Y"
    if (is.null(zlab))
        zlab <- if (!missing(z)) deparse(substitute(z)) else "Z"
    ## labcex is disregarded since we do NOT yet put  ANY labels...
    if (missing(z)) {
        if (!missing(x)) {
            if (is.list(x)) {
                z <- x$z
                y <- x$y
                x <- x$x
            }
            else {
                z <- x
                x <- seq(0, 1, len = nrow(z))
            }
        }
        else stop("no 'z' matrix specified")
    }
    else if (is.list(x)) {
        y <- x$y
        x <- x$x
    }
    if (any(diff(x) <= 0) || any(diff(y) <= 0))
        stop("increasing 'x' and 'y' values expected")
        
    result <- c(surface=surface3d(x,y,z,...))
    
    result <- c(result, decorate3d(xlim = xlim, ylim = ylim, zlim = zlim, 
               xlab = xlab, ylab = ylab, zlab = zlab, aspect = aspect, ...))
    invisible(result)
}
