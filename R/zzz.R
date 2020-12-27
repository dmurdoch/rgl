##
## R source file
## This file is part of rgl
##
##

##
## ===[ SECTION: package entry/exit point ]===================================
##

##
## entry-point
##
##
  
.onLoad <- function(lib, pkg) {
  # OS-specific 
  initValue <- 0  
  
  dynlib <- "rgl"
  
  onlyNULL <- noOpenGL || rgl.useNULL()
  
  unixos <- "none"
  if (.Platform$OS.type == "unix") {
    unixos <- system("uname", intern=TRUE)
    if (!length(unixos))
      unixos <- "unknown"    
  }
  
  if ( !noOpenGL && unixos == "Darwin" ) {
    
    # For MacOS X we have to remove /usr/X11R6/lib from the DYLD_LIBRARY_PATH
    # because it would override Apple's OpenGL framework
    Sys.setenv("DYLD_LIBRARY_PATH"=gsub("/usr/X11R6/lib","",Sys.getenv("DYLD_LIBRARY_PATH")))
    X11 <- nchar(Sys.getenv("DISPLAY", "")) > 0 || nchar(Sys.which("Xorg")) > 0
    if (!X11) 
      stop("X11 not found; XQuartz (from www.xquartz.org) is required to run rgl.",
           call. = FALSE)
  }
  
  dll <- try(library.dynam(dynlib, pkg, lib))
  if (inherits(dll, "try-error"))
    stop(paste("\tLoading rgl's DLL failed.", 
    	       if (unixos == "Darwin") 
    	         "\n\tThis build of rgl depends on XQuartz, which you can download from xquartz.org."),
         call. = FALSE)

  routines <- getDLLRegisteredRoutines(dynlib, addNames = FALSE)
  ns <- asNamespace(pkg)
  for(i in 1:4)
    lapply(routines[[i]],
      function(sym) assign(sym$name, sym, envir = ns))
      
  if ( !noOpenGL && .Platform$OS.type == "windows" && !onlyNULL) {
    frame <- getWindowsHandle("Frame")  # nolint 
    ## getWindowsHandle was numeric pre-2.6.0 
    if ( !is.null(frame) ) initValue <- getWindowsHandle("Console") # nolint
  } 
 
  if (onlyNULL) {
    rglFonts(serif = rep("serif", 4), sans = rep("sans", 4), mono = rep("mono", 4), symbol = rep("symbol", 4))
  } else {
    rglFonts(serif = rep(system.file("fonts/FreeSerif.ttf", package="rgl"), 4),
             sans  = rep(system.file("fonts/FreeSans.ttf", package="rgl"), 4),
             mono  = rep(system.file("fonts/FreeMono.ttf", package="rgl"), 4),
             symbol = rep(system.file("fonts/FreeSerif.ttf", package="rgl"), 4))
  }
  
  .rglEnv$subsceneList <- NULL
	 
  ret <- rgl.init(initValue, onlyNULL)
  
  if (!ret) {
    warning("'rgl.init' failed, running with 'rgl.useNULL = TRUE'.", call. = FALSE)
    options(rgl.useNULL = TRUE)
    rgl.init(initValue, TRUE)	
  }

  if (!rgl.useNULL()) 
    setGraphicsDelay(unixos = unixos)
  
  registerInputHandler("shinyPar3d", convertShinyPar3d)
  
}

# Do we need a delay opening graphics?    
# Work around bug in MacOS Catalina:  if base plotting happens
# too quickly after first call to quartz, R crashes.
# This inserts a delay after the
# first call to the graphics device.  The default is
# no delay, unless on Catalina with no graphics device
# currently open, when a 1 second delay will be introduced.
# Use "RGL_SLOW_DEV = value" to change the delay from 
# the default to "value" seconds.  

setGraphicsDelay <- function(delay = Sys.getenv("RGL_SLOW_DEV", 0), 
                             unixos = "none") {
  if (unixos == "Darwin") {
    version <- try(numeric_version(system("uname -r", intern = TRUE)))
    if (missing(delay) &&
        !inherits(version, "try-error") && 
        !is.na(version) && 
        version >= "19.0.0" &&
        dev.cur() == 1 &&
        identical(getOption("device"), grDevices::quartz))
      delay <- Sys.getenv("RGL_SLOW_DEV", 1)
  }
  delay <- suppressWarnings(as.numeric(delay))
  if (is.na(delay))
    delay <- 1
  if (delay > 0) {
    olddev <- getOption("device")
    if (is.character(olddev)) {
      if (exists(olddev, globalenv(), mode = "function"))
        olddev <- get(olddev, envir = globalenv(), mode = "function")
      else if (exists(olddev, asNamespace("grDevices"), mode = "function"))
        olddev <- get(olddev, asNamespace("grDevices"), mode = "function")
    }
    if (is.function(olddev))
      options(device = function(...) {
        olddev(...)
        Sys.sleep(delay)
        options(device = olddev)
      })
  }
}

rgl.init <- function(initValue = 0, onlyNULL = FALSE, debug = getOption("rgl.debug", FALSE)) 
  .Call( rgl_init, 
    initValue, onlyNULL, environment(rgl.init), debug )

.onAttach <- function(libname, pkgname) {
  if (noOpenGL)
    packageStartupMessage(
      "This build of rgl does not include OpenGL functions.  Use
 rglwidget() to display results, e.g. via options(rgl.printRglwidget = TRUE).")
}

##
## exit-point
##
##

.onUnload <- function(libpath) {
  # shutdown
  
  .C( rgl_quit, success=FALSE )
  
}
