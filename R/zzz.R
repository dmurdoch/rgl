##
## R source file
## This file is part of rgl
##
## $Id: zzz.R,v 1.4 2003/06/04 07:46:44 dadler Exp $
##

##
## ===[ SECTION: package entry/exit point ]===================================
##

##
## unload DLL
## 

.rgl.unload.dll <- function()
{
  # unload dll
  
  dyn.unload( system.file( "libs", paste( "rgl", .Platform$dynlib.ext, sep=""), package="rgl" ) )
    
  # fix .DynLibs() string
    
  libs <- .dynLibs()

  index <- match("rgl",libs)
  
  if ( !is.na(index) ) {
    libs <- libs[-index]
    .dynLibs(libs)
  }
}

##
## entry-point
##
##

.First.lib <- function(lib, pkg)
{
  # For MacOS X we have to remove /usr/X11R6/lib from the DYLD_LIBRARY_PATH
  # because it would override Apple's OpenGL framework
  Sys.putenv("DYLD_LIBRARY_PATH"=sub("/usr/X11R6/lib","",Sys.getenv("DYLD_LIBRARY_PATH")))

  # load shared library
  
  library.dynam( "rgl", pkg, lib)
  
  ret <- .C( symbol.C("rgl_init"), 
    success=FALSE 
  )
  
  if (!ret$success) {
    .rgl.unload.dll() 
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
  
  ret <- .C( symbol.C("rgl_quit"), 
    success=FALSE, 
  )
  
  .rgl.unload.dll()
}

