##
## R source file
## This file is part of rgl
##
## $Id: device.R,v 1.2 2003/06/04 07:46:44 dadler Exp $
##

##
## ===[ SECTION: device management ]==========================================
##


##
## open device
##
##

rgl.open <- function() {

  ret <- .C( symbol.C("rgl_dev_open"), success=FALSE )

  if (! ret$success)
    stop("failed")

}


##
## close device
##
##

rgl.close <- function() {

  ret <- .C( symbol.C("rgl_dev_close"), success=FALSE )

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

rgl.set <- function(which) {

  idata <- c( as.integer(which) )

  ret <- .C( symbol.C("rgl_dev_setcurrent"), 
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

rgl.snapshot <- function( filename, fmt="png" )
{
  idata <- as.integer(rgl.enum.pixfmt(fmt))

  ret <- .C( symbol.C("rgl_snapshot"),
    success=FALSE,
    idata,
    as.character(filename)
  )

  if (! ret$success)
    print("failed")
}
