##
## R source file
## This file is part of rgl
##
## $Id: zzz.R,v 1.3 2003/05/14 10:58:36 dadler Exp $
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
  # For MacOS X we have to remove /usr/X11R6/lib from the DYLD_LIBRARY_PATH
  # because it would override Apple's OpenGL framework
  Sys.putenv("DYLD_LIBRARY_PATH"=sub("/usr/X11R6/lib","",Sys.getenv("DYLD_LIBRARY_PATH")))

  # load shared library
  
  library.dynam( "rgl", pkg, lib)
  
  ret <- .C( symbol.C("rgl_init"), 
    success=FALSE 
  )
  
  if (!ret$success) {
    dyn.unload( file.path( libpath, "libs", paste( "rgl", .Platform$dynlib.ext, sep="") ) )
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
  
  if (!ret$success)
    stop("error rgl_quit")
  
  # unload shared library

  dyn.unload( file.path( libpath, "libs", paste( "rgl", .Platform$dynlib.ext, sep="") ) )

  # R BUG: i must fix .Dyn.libs environment variable manually
  # the variable is used by 'library.dynam' to determine if a package is unloaded
  # workaround: find and remove the string item "rglview" from the list manually

  # .Dyn.libs <- get(".Dyn.libs", envir=NULL)
  # .Dyn.libs <- .Dyn.libs[-match( "rgl", .Dyn.libs )]
  # assign(".Dyn.libs", .Dyn.libs, envir=NULL)
}
