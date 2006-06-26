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

	bbox <- par3d("bbox")
	scale <- c(bbox[2]-bbox[1], bbox[4]-bbox[3], bbox[6]-bbox[5])
	scale <- ifelse(scale <= 0, 1, scale)

	avgscale <- sqrt(sum(scale^2)/3)
        scale <- c(x,y,z)*avgscale/scale
    }
    par3d(scale = scale)
}
