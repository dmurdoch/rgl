
##
## bring device to top
##
##

rgl.bringtotop <- function(stay = FALSE) {

  if ((.Platform$OS.type != "windows") && stay) warning("stay not implemented")
  ret <- .C( rgl_dev_bringtotop, success=FALSE, as.logical(stay) )

  if (! ret$success)
    stop("failed")

}
