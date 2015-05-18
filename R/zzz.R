##
## R source file
## This file is part of rgl
##
## $Id$
##

##
## ===[ SECTION: package entry/exit point ]===================================
##

##
## entry-point
##
##

.onLoad <- function(lib, pkg)
{
  # OS-specific 
  initValue <- 0  
  
  dynlib <- "rgl"
  
  onlyNULL <- rgl.useNULL()
  
  if ( .Platform$OS.type == "unix" ) {
    unixos <- system("uname",intern=TRUE)
    if ( unixos == "Darwin" ) {
          
      # For MacOS X we have to remove /usr/X11R6/lib from the DYLD_LIBRARY_PATH
      # because it would override Apple's OpenGL framework
      Sys.setenv("DYLD_LIBRARY_PATH"=gsub("/usr/X11R6/lib","",Sys.getenv("DYLD_LIBRARY_PATH")))
      if ( .Platform$GUI == "AQUA" && 
            file.exists(system.file("libs",.Platform$r_arch, "aglrgl.so", lib.loc=lib, package = pkg))) {
          initValue <- 1
          dynlib <- "aglrgl"
      }
    }
  } 
  dll <- library.dynam(dynlib, pkg, lib)

  routines <- getDLLRegisteredRoutines(dynlib, addNames = FALSE)
  ns <- asNamespace(pkg)
  for(i in 1:4)
    lapply(routines[[i]],
      function(sym) assign(sym$name, sym, envir = ns))
      
  if ( .Platform$OS.type == "windows" && !onlyNULL) {
    frame <- getWindowsHandle("Frame")    
    ## getWindowsHandle was numeric pre-2.6.0 
    if ( !is.null(frame) ) initValue <- getWindowsHandle("Console")
  } 
 
  if (onlyNULL) {
    rglFonts(serif = rep("serif", 4), sans = rep("sans", 4), mono = rep("mono", 4), symbol = rep("symbol", 4))
  } else if ( .Platform$OS.type == "windows" ) {
    rglFonts(serif = rglFont(c("times.ttf", "timesbd.ttf", "timesi.ttf", "timesbi.ttf")),
             sans = rglFont(c("arial.ttf", "arialbd.ttf", "ariali.ttf", "arialbi.ttf")),
             mono = rglFont(c("cour.ttf", "courbd.ttf", "couri.ttf", "courbi.ttf")),
             symbol = rglFont(rep("symbol.ttf", 4)))
  } else {
    rglFonts(serif = rep(system.file("fonts/FreeSerif.ttf", package="rgl"), 4),
             sans  = rep(system.file("fonts/FreeSans.ttf", package="rgl"), 4),
             mono  = rep(system.file("fonts/FreeMono.ttf", package="rgl"), 4),
             symbol = rep(system.file("fonts/FreeSerif.ttf", package="rgl"), 4))
  }
  
  .rglEnv$subsceneList <- NULL
	 
  ret <- rgl.init(initValue, onlyNULL)
  
  if (!ret) {
    warning("Error in 'rgl_init'")
  }
  
}

rgl.init <- function(initValue = 0, onlyNULL = FALSE) .Call( rgl_init, 
    initValue, onlyNULL, environment(rgl.init) )

##
## exit-point
##
##

.onUnload <- function(libpath)
{ 
  # shutdown
  
  ret <- .C( rgl_quit, success=FALSE )
  
}

