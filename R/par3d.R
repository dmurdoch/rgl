.Par3d <- c("antialias", "FOV", "ignoreExtent", "listeners",
	   "mouseMode", "observer", 
	   "modelMatrix", "projMatrix", "skipRedraw", "userMatrix", 
	   "scale", "viewport", "zoom", "bbox", "windowRect",
           "family", "font", "cex", "useFreeType", "fontname",
	   "maxClipPlanes", "glVersion"
	   )
	   
.Par3d.readonly <- c( 
	   "antialias", "observer",
	   "modelMatrix", "projMatrix",
	   "bbox", "fontname",
	   "maxClipPlanes", "glVersion"
	   )

par3d <- function (..., no.readonly = FALSE, dev = rgl.cur(), subscene = currentSubscene3d(dev))
{
    single <- FALSE
    args <- list(...)
    if (!length(args))
	args <- as.list(if (no.readonly)
                        .Par3d[-match(.Par3d.readonly, .Par3d)]
        else .Par3d)
    else {
	if (is.null(names(args)) && all(unlist(lapply(args, is.character))))
	    args <- as.list(unlist(args))
	if (length(args) == 1) {
	    if (is.list(args[[1]]) | is.null(args[[1]]))
		args <- args[[1]]
	    else
		if(is.null(names(args)))
		    single <- TRUE
	}
    }
    if ("dev" %in% names(args)) {
        if (!missing(dev) && dev != args[["dev"]]) stop("'dev' specified inconsistently")
        dev <- args[["dev"]]
        args[["dev"]] <- NULL
    }
    if ("subscene" %in% names(args)) {
        if (!missing(subscene) && subscene != args[["subscene"]]) stop("'subscene' specified inconsistently")
        subscene <- args[["subscene"]]
        args[["subscene"]] <- NULL
    }
    dev <- as.integer(dev)
    if (!dev) dev <- open3d()
    subscene <- as.integer(subscene)
     
    if ("userMatrix" %in% names(args)) {
        m <- args$userMatrix
        svd <- svd(m[1:3, 1:3])
        m[1:3, 1:3] <- svd$u %*% t(svd$v)
        theta <- atan2(-m[1,3], m[1,1])
	m <-  m %*% rotationMatrix(theta, 0,1,0)
	svd <- svd(m[1:3, 1:3])
	m[1:3,1:3] <- svd$u %*% t(svd$v)	
	phi <- atan2(-m[2,3], m[3,3])
	args$.position <- c(theta, phi)*180/pi
    }
    value <-
        if (single) .Call(rgl_par3d, dev, subscene, args)[[1]] 
        else .Call(rgl_par3d, dev, subscene, args)

    if(!is.null(names(args))) invisible(value) else value
}

