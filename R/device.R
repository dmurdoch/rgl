##
## R source file
## This file is part of rgl
##
## $Id: device.R,v 1.1 2003/03/25 00:13:21 dadler Exp $
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
## device system shutdown
## 
##

rgl.quit <- function() {

  detach("package:rgl")

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
