
##
## bring device to top
##
##

rgl.bringtotop <- function(stay = FALSE) {

  if (!.Platform$OS=="window" && stay) warning("stay only works on Windows")
  ret <- .C( symbol.C("rgl_dev_bringtotop"), success=FALSE, as.logical(stay), 
             PACKAGE="rgl" )

  if (! ret$success)
    stop("failed")

}
