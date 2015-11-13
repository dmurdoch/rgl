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
    if (is.list(hook)) hook <- hook[[1]]  # test is for compatibility with R < 3.0.0
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
      stop("rgl window creation error; try reducing resolution, width or height")
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
    else rgl.close()
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

##
## knitr hook functions
##
##

hook_webgl <- function(before, options, envir) {
  rglwidgetCheck()
  rglwidget::.hook_webgl(before, options, envir)
}

hook_rgl <- function(before, options, envir) {
  rglwidgetCheck()
  rglwidget::.hook_rgl(before, options, envir)
}

setupKnitr <- function() {
  rglwidgetCheck()
  rglwidget::.setupKnitr()
}
