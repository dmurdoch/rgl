
##
## bring device to top
##
##

rgl.bringtotop <- function(stay = FALSE) {

  if (!.Platform$OS=="window" && stay) warning("stay only works on Windows")
  ret <- .C( rgl_dev_bringtotop, success=FALSE, as.logical(stay) )

  if (! ret$success)
    stop("failed")

}
