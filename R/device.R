##
## R source file
## This file is part of rgl
##
## $Id: device.R,v 1.3 2004/03/03 22:09:44 dadler Exp $
##

##
## ===[ SECTION: device management ]==========================================
##


##
## open device
##
##

rgl.open <- function() {

  ret <- .C( symbol.C("rgl_dev_open"), success=FALSE, PACKAGE="rgl" )

  if (! ret$success)
    stop("failed")

}


##
## close device
##
##

rgl.close <- function() {

  ret <- .C( symbol.C("rgl_dev_close"), success=FALSE, PACKAGE="rgl" )

  if (! ret$success)
    stop("no device opened.")

}


## 
## get current device
##
##

rgl.cur <- function() {

  ret <- .C( symbol.C("rgl_dev_getcurrent"), 
    success=FALSE, 
    id=as.integer(0), 
    PACKAGE="rgl"
  )

  if (! ret$success)
    stop("rgl_dev_getcurrent")

  return(ret$id)

}


##
## set current device
##
##

rgl.set <- function(which) {

  idata <- c( as.integer(which) )

  ret <- .C( symbol.C("rgl_dev_setcurrent"), 
    success=FALSE, 
    idata,
    PACKAGE="rgl"
  )

  if (! ret$success)
    stop("no device opened with id", which)
}



##
## export image
##
##

rgl.snapshot <- function( filename, fmt="png" )
{
  idata <- as.integer(rgl.enum.pixfmt(fmt))

  ret <- .C( symbol.C("rgl_snapshot"),
    success=FALSE,
    idata,
    as.character(filename),
    PACKAGE="rgl"
  )

  if (! ret$success)
    print("failed")
}

