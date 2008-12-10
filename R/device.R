##
## R source file
## This file is part of rgl
##
## $Id$
##

##
## ===[ SECTION: device management ]==========================================
##


##
## open device
##
##

rgl.open <- function() {

  ret <- .C( rgl_dev_open, success=FALSE )

  if (! ret$success)
    stop("rgl.open failed")

}


##
## close device
##
##

rgl.close <- function() {

  ret <- .C( rgl_dev_close, success=FALSE )

  if (! ret$success)
    stop("no device opened.")

}


## 
## get current device
##
##

rgl.cur <- function() {

  ret <- .C( rgl_dev_getcurrent, 
    success=FALSE, 
    id=as.integer(0)
  )

  if (! ret$success)
    stop("rgl_dev_getcurrent")

  return(ret$id)

}


##
## set current device
##
##

rgl.set <- function(which, silent = FALSE) {

  idata <- c( as.integer(which), as.integer(silent) )

  ret <- .C( rgl_dev_setcurrent, 
    success=FALSE, 
    idata
  )

  if (! ret$success)
    stop("no device opened with id", which)
}



##
## export image
##
##

rgl.snapshot <- function( filename, fmt="png", top=TRUE )
{
  if (top) rgl.bringtotop()
  
  idata <- as.integer(rgl.enum.pixfmt(fmt))

  ret <- .C( rgl_snapshot,
    success=FALSE,
    idata,
    as.character(filename)
  )

  if (! ret$success)
    print("failed")
}

##
## export postscript image
##
##

rgl.postscript <- function( filename, fmt="eps", drawText=TRUE )
{
  idata <- as.integer(c(rgl.enum.gl2ps(fmt), as.logical(drawText)))

  ret <- .C( rgl_postscript,
    success=FALSE,
    idata,
    as.character(filename)
  )

  if (! ret$success)
    print("failed")
}

##
## read image
##
##

rgl.pixels <- function(component = c("red", "green", "blue"), viewport = par3d("viewport"), top=TRUE )
{
  if (top) rgl.bringtotop()
  
  compnum <- as.integer(sapply(component, rgl.enum.pixelcomponent))
  stopifnot(length(viewport) == 4)
  ll <- as.integer(viewport[1:2])
  size <- as.integer(viewport[3:4])
  result <- array(NA_real_, dim=c(size[1], size[2], length(component)))
  dimnames(result) <- list(NULL, NULL, component)
  for (i in seq_along(compnum)) {
    ret <- .C( rgl_pixels,
      success=FALSE,
      ll, size, compnum[i],
      values = single(size[1]*size[2]))
 
    if (! ret$success)
      stop("Error reading component", component[i])
    result[,,i] <- ret$values
  }
  if (length(component) > 1) return(result)
  else return(result[,,1])
}
