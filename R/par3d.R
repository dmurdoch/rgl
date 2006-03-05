.Par3d <- c("FOV", "ignoreExtent",
	   "mouseMode", 
	   "modelMatrix", "projMatrix", "skipRedraw", "userMatrix", 
	   "viewport", "zoom", "bbox"
	   )
	   
.Par3d.readonly <- c( 
	   "modelMatrix", "projMatrix",
	   "viewport", "bbox"
	   )

par3d <- function (..., no.readonly = FALSE)
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
    value <-
        if (single) .External("par3d", args, PACKAGE = "rgl")[[1]] 
        else .External("par3d", args, PACKAGE = "rgl")
    if(!is.null(names(args))) invisible(value) else value
}

