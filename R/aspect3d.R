aspect3d <- function(x, y = NULL, z = NULL) {
    if (is.character(x) && pmatch(x, "iso") == 1) {
    	scale <- diag(4)
    } else {
	if (is.null(y)) {
	    x <- rep(x, len=3)
	    z <- x[3]
	    y <- x[2]
	    x <- x[1]
	}

	bbox <- par3d("bbox")
	scalex <- bbox[2]-bbox[1]
	scaley <- bbox[4]-bbox[3]
	scalez <- bbox[6]-bbox[5]
	
	if (scalex <= 0) scalex <- 1
	if (scaley <= 0) scaley <- 1
	if (scalez <= 0) scalez <- 1

	avgscale <- sqrt((scalex^2 + scaley^2 + scalez^2)/3)
        scale <- scaleMatrix(x*avgscale/scalex, y*avgscale/scaley, z*avgscale/scalez)
    }
    u <- par3d("userMatrix")
    if (any(!is.finite(u))) u <- r3dDefaults$userMatrix
    s <- svd(u)
    par3d(userMatrix = s$u %*% t(s$v) %*% scale)    
}
