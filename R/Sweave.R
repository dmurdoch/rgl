##
## Sweave device
##
##

rgl.Sweave <- function(name, width, height, options, ...) {
  if (length(hook <- getHook("on.rgl.close"))) {
    # test is for compatibility with R < 3.0.0
    if (is.list(hook)) hook <- hook[[1]]  
    dev <- environment(hook)$dev
    set3d(dev)
  } else {
    wr <- c(0, 0, width*options$resolution, height*options$resolution)
    open3d(windowRect=wr)
    if (is.null(delay <- options$delay)) delay <- 0.1
    Sys.sleep(as.numeric(delay))
    wrnew <- par3d("windowRect")
    if (wr[3] - wr[1] != wrnew[3] - wrnew[1] ||
        wr[4] - wr[2] != wrnew[4] - wrnew[2])
      stop("rgl window creation error; try reducing resolution, width or height")
    dev <- cur3d()
  } 
  
  snapshotDone <- FALSE
  
  # stayOpen is used below in rgl.Sweave.off
  stayOpen <- isTRUE(options$stayopen)
  
  type <- options$outputtype
  if (is.null(type)) type <- "png"
  
  setHook("on.rgl.close", action="replace", function(remove=TRUE) {
    prev.dev <- cur3d()
    on.exit(set3d(prev.dev))
    
    if (!snapshotDone) {
      set3d(dev)
      switch(type,
             png = snapshot3d(filename=paste(name, "png", sep=".")),
             pdf = rgl.postscript(filename=paste(name, "pdf", sep="."), fmt="pdf"),
             eps = rgl.postscript(filename=paste(name, "eps", sep="."), fmt="eps"),
             stop(gettextf("Unrecognized rgl outputtype: '%s'", type), domain = NA)
      )
      snapshotDone <<- TRUE
    }
    
    if (remove)
      setHook("on.rgl.close", action="replace", NULL)
  })
}

rgl.Sweave.off <- function() {
  if (length(hook <- getHook("on.rgl.close"))) {
    if (is.list(hook)) hook <- hook[[1]] # test is for R pre-3.0.0 compatibility
    stayOpen <- environment(hook)$stayOpen
    if (stayOpen) hook(FALSE)
    else close3d()
  }
}

##
## Sweave snapshot
##
##

Sweave.snapshot <- function() {
  if (length(hook <- getHook("on.rgl.close"))) {
    if (is.list(hook)) hook <- hook[[1]] # test is for R pre-3.0.0 compatibility
    hook(remove = FALSE)
  }
}
