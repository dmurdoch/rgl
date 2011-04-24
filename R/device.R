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

  if (length(hook <- getHook("on.rgl.close"))) hook()
  
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

##
## Sweave device
##
##

rgl.Sweave <- function(name, width, height, options, ...) {

  # The 2.13.0 release called dev.off(), not rgl.Sweave.off()
  
  if (getRversion() == "2.13.0" && version$status == "") {
  
    postscript(tempfile()) # make dev.off() happy
    if (length(getHook("on.rgl.close"))) rgl.Sweave.off() # to close the previous chunk
  
  }
  
  if (length(hook <- getHook("on.rgl.close"))) {
    dev <- environment(hook)$dev
    rgl.set(dev)
  } else {
    wr <- c(0, 0, width*options$resolution, height*options$resolution)
    open3d(windowRect=wr)
    if (is.null(delay <- options$delay)) delay <- 0.1
    Sys.sleep(as.numeric(delay))
    wrnew <- par3d("windowRect")
    if (wr[3] - wr[1] != wrnew[3] - wrnew[1] || 
        wr[4] - wr[2] != wrnew[4] - wrnew[2])
      stop("rgl window creation error.  Try reducing resolution, width or height.")
    dev <- rgl.cur()
  } 
  
  snapshotDone <- FALSE
  
  stayOpen <- isTRUE(options$stayopen)
  
  type <- options$outputtype
  if (is.null(type)) type <- "png"
  
  setHook("on.rgl.close", action="replace", function(remove=TRUE) {
    prev.dev <- rgl.cur()
    on.exit(rgl.set(prev.dev))
    
    if (!snapshotDone) {
      rgl.set(dev)
      switch(type,
        png = rgl.snapshot(filename=paste(name, "png", sep=".")),
        pdf = rgl.postscript(filename=paste(name, "pdf", sep="."), fmt="pdf"),
        eps = rgl.postscript(filename=paste(name, "eps", sep="."), fmt="eps"),
        stop("Unrecognized rgl outputtype: ", type)
      )
      snapshotDone <<- TRUE
    }
    
    if (remove)
      setHook("on.rgl.close", action="replace", NULL)
  })
}

rgl.Sweave.off <- function() {
  if (length(hook <- getHook("on.rgl.close"))) {
    stayOpen <- environment(hook)$stayOpen
    if (stayOpen) hook(FALSE)
    else rgl.close()
  }
}
  
##
## Sweave snapshot
## 
##

Sweave.snapshot <- function() {
  if (length(hook <- getHook("on.rgl.close"))) hook(remove = FALSE)
}

