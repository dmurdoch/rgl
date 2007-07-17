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
  dll <- "rgl"
  
  if ( .Platform$OS.type == "unix" ) {
    unixos <- system("uname",intern=TRUE)
    if ( unixos == "Darwin" ) {
    
      # Sys.putenv was renamed to Sys.setenv in R 2.5.0
      if ( as.numeric(R.version$minor) < 5 )
          Sys.setenv <- Sys.putenv
          
      # For MacOS X we have to remove /usr/X11R6/lib from the DYLD_LIBRARY_PATH
      # because it would override Apple's OpenGL framework
      Sys.setenv("DYLD_LIBRARY_PATH"=gsub("/usr/X11R6/lib","",Sys.getenv("DYLD_LIBRARY_PATH")))
      if ( .Platform$GUI == "AQUA" && 
            file.exists(system.file("libs",.Platform$r_arch, "aglrgl.so", lib.loc=lib, package = pkg))) {
          dll <- "aglrgl"
          initValue <- 1
      }
    }
  } 
  
  if ( .Platform$OS.type == "windows" ) {
    frame <- getWindowsHandle("Frame")    
    ## getWindowsHandle was numeric pre-2.6.0 
    if ( is.numeric(frame) ) {
    	if (frame ) initValue <- getWindowsHandle("Console")
    } else
    	if ( !is.null(frame) ) initValue <- getWindowsHandle("Console")
  } 
  
  useDynLib <- function(dll, entries) {
      dll <- library.dynam(dll, pkg, lib.loc=lib)
      names <- entries
      if (length(names(entries))) {
  	  rename <- names(entries) != ""
  	  names[rename] <- names(entries)[rename]
      }
      for (i in seq(along=entries)) 
      	  assign(names[i], getNativeSymbolInfo(entries[i], PACKAGE = dll),
      	         envir = environment(.onLoad))
  }
          
  entries <- c("rgl_init", "rgl_dev_open", "rgl_dev_close",
  	 "rgl_dev_getcurrent", "rgl_dev_setcurrent", "rgl_snapshot",
  	 "rgl_postscript", "rgl_material", "rgl_getmaterial",
  	 "rgl_getcolorcount", "rgl_dev_bringtotop", "rgl_clear",
  	 "rgl_pop", "rgl_id_count", "rgl_ids", "rgl_viewpoint",
  	 "rgl_bg", "rgl_bbox", "rgl_light", "rgl_primitive",
  	 "rgl_surface", "rgl_spheres", "rgl_texts", "rgl_sprites",
  	 "rgl_user2window", "rgl_window2user", "rgl_selectstate",
	 "rgl_setselectstate", rgl_par3d="par3d", "rgl_quit")
	 
  useDynLib(dll, entries)
	 
  ret <- rgl.init(initValue)
  
  if (!ret) {
    warning("error in rgl_init")
  }
  
}

rgl.init <- function(initValue = 0) .Call( rgl_init, 
    initValue )

##
## exit-point
##
##

.onUnload <- function(libpath)
{ 
  # shutdown
  
  ret <- .C( rgl_quit, success=FALSE )
  
}

