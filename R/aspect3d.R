aspect3d <- function(x, y = NULL, z = NULL) {
    if (is.character(x) && pmatch(x, "iso") == 1) {
    	scale <- diag(4)
    } else {
	if (is.null(y)) {
	    z <- x[3]
	    y <- x[2]
	    x <- x[1]
	}

	bbox <- par3d("bbox")
	scalex <- bbox[2]-bbox[1]
	scaley <- bbox[4]-bbox[3]
	scalez <- bbox[6]-bbox[5]

	avgscale <- sqrt((scalex^2 + scaley^2 + scalez^2)/3)
        scale <- scaleMatrix(x*avgscale/scalex, y*avgscale/scaley, z*avgscale/scalez)
    }
    s <- svd(par3d("userMatrix"))
    
    par3d(userMatrix = s$u %*% t(s$v) %*% scale)    
}
