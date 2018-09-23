shapelist3d <- function(shapes,x=0,y=NULL,z=NULL,size=1,matrix=NULL,override=TRUE, ..., plot=TRUE) {
    # This function gets an element with recycling
    e <- function(x, i) x[[ (i-1) %% length(x) + 1 ]]
    
    xyz <- xyz.coords(x, y, z, recycle = TRUE)
    x <- xyz$x
    y <- xyz$y
    if (length(y) == 0) y <- 0
    z <- xyz$z
    if (length(z) == 0) z <- 0
    
    if (inherits(shapes, "shape3d")) shapes <- list(shapes)

    material <- list(...)
    
    if (!is.null(matrix)) {
	if (!is.list(matrix)) matrix <- list(matrix)
	len <- length(matrix)
    } else len <- 0
    
    len <- max(len, length(x), length(shapes), length(size), length(override))
    if (length(material)) len <- max(len, sapply(material, length))
    
    result <- vector("list", len)
    class(result) <- c("shapelist3d", "shape3d")

    for (i in seq_len(len)) {
	if (is.null(matrix)) this <- e(shapes, i)
	else this <- rotate3d(e(shapes,i), matrix=e(matrix,i))
	thissize <- e(size, i)
	this <- translate3d(scale3d(this, thissize, thissize, thissize), e(x,i), e(y,i), e(z,i))
	thismaterial <- lapply(material, function(item) e(item,i))
	if (!e(override,i))
	    thismaterial[names(this$material)] <- this$material
	this$material[names(thismaterial)] <- thismaterial
	result[[i]] <- this
    }
    if (plot) {
    	shade3d(result)
        lowlevel(result)
    } else
    	invisible(result)
}

dot3d.shapelist3d <- function(x, override = TRUE, ...) {
    .check3d()
    save <- par3d(skipRedraw = TRUE)
    on.exit(par3d(save))
    
    invisible(unlist(sapply( x, function(item) dot3d(item, override=override, ...) ) ) )
}

wire3d.shapelist3d <- function(x, override = TRUE, ...) {
    .check3d()
    save <- par3d(skipRedraw = TRUE)
    on.exit(par3d(save))
    
    invisible(unlist(sapply( x, function(item) wire3d(item, override=override, ...) ) ) )
}


shade3d.shapelist3d <- function(x, override = TRUE, ...) {
    .check3d()
    save <- par3d(skipRedraw = TRUE)
    on.exit(par3d(save))
    
    invisible(unlist(sapply( x, function(item) shade3d(item, override=override, ...) ) ) )
}

translate3d.shapelist3d <- function ( obj, x, y, z, ... ) {
  structure(lapply( obj, function(item) translate3d(item, x, y, z, ...) ),
            class = class(obj))
}  

rotate3d.shapelist3d <- function ( obj,angle,x,y,z,matrix, ... ) {
  structure(lapply( obj, function(item) rotate3d(item, x,y,z,matrix,...) ),
            class = class(obj))
}  

scale3d.shapelist3d <- function ( obj, x, y, z, ... ) {
  structure(lapply( obj, function(item) scale3d(item, x,y,z,...) ),
            class = class(obj))
}

addNormals.shapelist3d <- function ( x, ... ) {
  structure(lapply( x, function(item) addNormals(item, ...) ),
            class = class(x))
}

print.shapelist3d <- function(x, prefix = "", ...) {
  cat(prefix, " shapelist3d object with ", length(x), " items:\n", sep = "")
  for (i in seq_along(x))
    print(x[[i]], prefix = paste0(prefix, "[[", i, "]]"))
}
