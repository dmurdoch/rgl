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

hook_webgl <- local({
  commonParts <- TRUE
  reuse <- TRUE
  function (before, options, envir) 
  {
    if (before) {
      newwindow <- options$rgl.newwindow
      if (!is.null(newwindow) && newwindow) 
      	open3d()
      if (!is.null(options$rgl.keepopen))
      	warning("rgl.keepopen has been replaced by rgl.newwindow")
      return()
    } else if (rgl.cur() == 0)
      return()    
    	
    if (requireNamespace("knitr")) { # Should we stop if there is no knitr?
                                     # We only use it in this test.
      out_type <- knitr::opts_knit$get("out.format")
      if (!length(intersect(out_type, c("markdown", "html"))))       
        stop("'hook_webgl' is for HTML only.  Use 'hook_rgl' instead.")
    }  
    name <- tempfile("webgl", tmpdir = ".", fileext = ".html")
    on.exit(unlink(name))
    retina <- options$fig.retina
    if (!is.numeric(retina)) retina <- 1 # It might be FALSE or maybe NULL
    dpi <- options$dpi / retina  # should not consider Retina displays (knitr #901)
    margin <- options$rgl.margin
    if (is.null(margin)) margin <- 100
    par3d(windowRect = margin + dpi * c(0, 0, options$fig.width, 
                                           options$fig.height))
    Sys.sleep(.05) # need time to respond to window size change
    
    prefix <- gsub('[^[:alnum:]]', '_', options$label) # identifier for JS, better be alnum
    prefix <- sub('^([^[:alpha:]])', '_\\1', prefix) # should start with letters or _
    res <- writeWebGL(dir = dirname(name), 
                    filename = name, 
                    snapshot = !rgl.useNULL(),
                    template = NULL, 
                    prefix = prefix, 
                    commonParts = commonParts,
                    reuse = reuse)
    commonParts <<- FALSE
    reuse <<- attr(res, "reuse")
    res <- readLines(name)
    res = res[!grepl('^\\s*$', res)] # remove blank lines
    paste(gsub('^\\s+', '', res), collapse = '\n') # no indentation at all (for Pandoc)
  }
})

hook_rgl <- function(before, options, envir) {
  if (before) {
    newwindow <- options$rgl.newwindow
    if (!is.null(newwindow) && newwindow) 
      open3d()
    if (!is.null(options$rgl.keepopen))       
      warning("rgl.keepopen has been replaced by rgl.newwindow")
    return()
  } else if (rgl.cur() == 0)
    return()
	
  if (!requireNamespace("knitr")) 
    stop("'hook_rgl' requires the 'knitr' package.")

  name <- knitr::fig_path('', options)
  margin <- options$rgl.margin
  if (is.null(margin)) margin <- 100
  par3d(windowRect = margin + options$dpi * c(0, 0, options$fig.width, options$fig.height))
  Sys.sleep(.05) # need time to respond to window size change

  dir <- knitr::opts_knit$get('base_dir')
  if (is.character(dir)) {
    if (!file_test('-d', dir)) dir.create(dir, recursive = TRUE)
    owd <- setwd(dir)
    on.exit(setwd(owd))
  }
  save_rgl(name, options$dev)
  if (!isTRUE(options$rgl.keepopen))
    rgl.close()
  options$fig.num = 1L  # only one figure in total
  knitr::hook_plot_custom(before, options, envir)
}

save_rgl <- function(name, devices) {
  if (!file_test('-d', dirname(name))) dir.create(dirname(name), recursive = TRUE)
  # support 3 formats: eps, pdf and png (default)
  for (dev in devices) switch(
    dev,
    eps =,
    postscript = rgl.postscript(paste0(name, '.eps'), fmt = 'eps'),
    pdf = rgl.postscript(paste0(name, '.pdf'), fmt = 'pdf'),
    rgl.snapshot(paste0(name, '.png'), fmt = 'png')
  )
}

setupKnitr <- function() {
  if (requireNamespace("knitr")) {
    knitr::knit_hooks$set(webgl = hook_webgl)
    knitr::knit_hooks$set(rgl = hook_rgl)
    environment(hook_webgl)$commonParts <- TRUE
    environment(hook_webgl)$reuse <- TRUE
  }
}
