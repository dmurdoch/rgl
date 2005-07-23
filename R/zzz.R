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

.First.lib <- function(lib, pkg)
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
	
  # load shared library
  
  library.dynam( "rgl", pkg, lib)
  
  ret <- .C( symbol.C("rgl_init"), 
    success=FALSE , 
    PACKAGE="rgl"
  )
  
  if (!ret$success) {
    stop("error rgl_init")
  }
  
}


##
## exit-point
##
##

.Last.lib <- function(libpath)
{ 
  # shutdown
  
  ret <- .C( symbol.C("rgl_quit"), success=FALSE, PACKAGE="rgl" )
  
  # unload shared library

  library.dynam.unload("rgl",libpath=system.file(package="rgl"))
}

