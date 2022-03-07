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

  in_pkgload_loadall <- function() {
    caller <- deparse(sys.call(-4))
    isNamespaceLoaded("pkgload") && grepl("load_all", caller)
  }
  
  getDir <- function(useNULL) {
    if (in_pkgload_loadall()) {
      dir <- if (useNULL) "inst/useNULL" else "src"
    } else {
      dir <- if (useNULL) "useNULL" else "libs"
      if (nchar(.Platform$r_arch))
        dir <- paste0(dir, "/", .Platform$r_arch)
    }
    dir
  }
    
  getDynlib <- function(dir)
    system.file(paste0(dir, "/rgl", .Platform$dynlib.ext), 
                package = pkg, lib.loc = lib,
                mustWork = TRUE)
  
  # OS-specific 
  initValue <- 0  
  
  onlyNULL <- noOpenGL || rgl.useNULL()
  
  useNULL <- onlyNULL && !noOpenGL && .Platform$OS.type != "windows"
  dir <- getDir(useNULL)
  
  unixos <- "none"
  if (.Platform$OS.type == "unix") {
    unixos <- system("uname", intern=TRUE)
    if (!length(unixos))
      unixos <- "unknown"    
  }
  
  dll <- try(dyn.load(dynlib <- getDynlib(dir)))
  if (inherits(dll, "try-error")) {
    warning(paste("\tLoading rgl's DLL failed.", 
    	       if (unixos == "Darwin" && !onlyNULL) {
    	         paste("\n\tThis build of rgl depends on XQuartz, which failed to load.\n",
    	           "See the discussion in https://stackoverflow.com/a/66127391/2554330")
             }),
         call. = FALSE)
    if (!onlyNULL) {
      dir <- getDir(TRUE)
      warning("Trying without OpenGL...", call. = FALSE)
      noOpenGL <<- TRUE
      dll <- try(dyn.load(dynlib <- getDynlib(dir)))
    }
    if (inherits(dll, "try-error"))
      stop("Loading failed.")
  }
  routines <- getDLLRegisteredRoutines(dll, addNames = FALSE)
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
    if (requireNamespace("extrafont", quietly = TRUE))
      suppressWarnings(
        rglExtrafonts(sans = c("rglHelvetica", "Arial"), 
                      serif = c("Times", "Times New Roman"), 
                      mono = c("Courier", "Courier New")))
  }
  
  register_compare_proxy()
  
  .rglEnv$subsceneList <- NULL

  # Workaround for incompatibility with quartz device
  # By default only run this if we'll be using the X11 display on macOS
  # and we're not on R.app.  options("rgl.startQuartz") can 
  # override this.
  # Then we need to start quartz() before starting rgl.
  # See https://github.com/dmurdoch/rgl/issues/27
  if (getOption("rgl.startQuartz", 
           !onlyNULL &&
           interactive() &&
           unixos == "Darwin" && 
           !(.Platform$GUI %in% c("AQUA", "RStudio"))) &&
         exists("quartz", getNamespace("grDevices"))) {
    grDevices::quartz()
    dev.off()
  }
  
  ret <- rgl.init(initValue, onlyNULL)
  
  if (!ret) {
    warning("'rgl.init' failed, running with 'rgl.useNULL = TRUE'.", call. = FALSE)
    options(rgl.useNULL = TRUE)
    rgl.init(initValue, TRUE)	
  }

  if (!rgl.useNULL()) 
    setGraphicsDelay(unixos = unixos)
  
  # Are we running in reprex::reprex?  If so, do
  # the knitr setup so our output appears there.
  
  if (in_reprex()) {
    setupKnitr(autoprint = TRUE)
  }
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
  unregisterShinyHandlers()

  # shutdown
  .C( rgl_quit, success=FALSE )
  
}

in_reprex <- function() 
  !is.null(getOption("reprex.current_venue"))
