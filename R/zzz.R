##
## R source file
## This file is part of rgl
##
## $Id: zzz.R,v 1.2 2003/03/25 04:13:56 dadler Exp $
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
