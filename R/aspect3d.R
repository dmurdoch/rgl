aspect3d <- function(x, y = NULL, z = NULL) {
    if (is.character(x) && pmatch(x, "iso") == 1) {
    	scale <- c(1,1,1)
    } else {
	if (is.null(y)) {
	    x <- rep(x, len=3)
	    z <- x[3]
	    y <- x[2]
	    x <- x[1]
	}
        for (i in 1:5) { # To handle spheres, repeat this 
  	    bbox <- .getRanges()
	    scale <- c(diff(bbox$xlim), diff(bbox$ylim), diff(bbox$zlim))
	    scale <- ifelse(scale <= 0, 1, scale)

	    avgscale <- sqrt(sum(scale^2)/3)
            scale <- c(x,y,z)*avgscale/scale
            oldscale <- par3d(scale = scale)$scale
            if (isTRUE(all.equal(scale, oldscale)))
            	break
        }
    }
    par3d(scale = scale)
}
