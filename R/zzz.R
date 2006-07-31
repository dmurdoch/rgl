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
  
  if ( .Platform$OS.type == "unix" ) {
    unixos <- system("uname",intern=TRUE)
    if ( unixos == "Darwin" ) {
      # For MacOS X we have to remove /usr/X11R6/lib from the DYLD_LIBRARY_PATH
      # because it would override Apple's OpenGL framework
      Sys.putenv("DYLD_LIBRARY_PATH"=gsub("/usr/X11R6/lib","",Sys.getenv("DYLD_LIBRARY_PATH")))      
    }
  } 
  
  mdiHandle <- 0
  
  if ( .Platform$OS.type == "windows" ) {
    if ( getWindowsHandle("Frame") ) mdiHandle <- getWindowsHandle("Console")
  } 
  
  	
  ret <- .C( "rgl_init", 
    success=FALSE ,
    as.integer(mdiHandle),
    PACKAGE="rgl"
  )
  
  if (!ret$success) {
    warning("error in rgl_init")
  }
  
}


##
## exit-point
##
##

.onUnload <- function(libpath)
{ 
  # shutdown
  
  ret <- .C( "rgl_quit", success=FALSE, PACKAGE="rgl" )
  
}

