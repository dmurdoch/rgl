##
## R source file
## This file is part of rgl
##
##

##
## ===[ SECTION: device management ]==========================================
##

rgl.useNULL <- function() {
  if (noOpenGL)
    return(TRUE)
  opt <- getOption("rgl.useNULL", Sys.getenv("RGL_USE_NULL"))
  if (is.logical(opt)) return(opt)
  opt <- as.character(opt)
  if (nchar(opt)) {
    opt <- pmatch(tolower(opt), c("yes", "true"), nomatch=3)
    return(c(TRUE, TRUE, FALSE)[opt])
  }
  FALSE
}

##
## open device
##
##

rgl.open <- function(useNULL = rgl.useNULL()) {

  .Defunct("open3d")

}


##
## close device
##
##

rgl.close <- function() {
  .Defunct("close3d")
}

## 
## get all devices
##
##

rgl.dev.list <- function() 
  .Call( rgl_dev_list )


##
## set current device
##
##

rgl.set <- function(which, silent = FALSE) {
  .Defunct("set3d")
}



##
## export image
##
##

rgl.snapshot <- function( filename, fmt="png", top=TRUE ) {
  if (top) rgl.bringtotop()
  
  idata <- as.integer(rgl.enum.pixfmt(fmt))
  if (length(filename) != 1)
    stop("filename is length ", length(filename))
  filename <- normalizePath(filename, mustWork = FALSE)
  ret <- .C( rgl_snapshot,
    success=FALSE,
    idata,
    filename
  )

  if (! ret$success)
    warning("'rgl.snapshot' failed")
  
  invisible(filename)
}

##
## export postscript image
##
##

rgl.postscript <- function( filename, fmt="eps", drawText=TRUE ) {
  idata <- as.integer(c(rgl.enum.gl2ps(fmt), as.logical(drawText)))
  if (length(filename) != 1)
    stop("filename is length ", length(filename))
  ret <- .C( rgl_postscript,
    success=FALSE,
    idata,
    normalizePath(filename, mustWork = FALSE, winslash = "/")
  )

  if (! ret$success)
    warning("Postscript conversion failed")
}

##
## read image
##
##

rgl.pixels <- function(component = c("red", "green", "blue"), viewport = par3d("viewport"), top=TRUE ) {
  if (top) rgl.bringtotop()
  
  compnum <- as.integer(sapply(component, rgl.enum.pixelcomponent))
  stopifnot(length(viewport) == 4)
  ll <- as.integer(viewport[1:2])
  stopifnot(all(!is.na(ll)), all(ll >= 0))
  size <- as.integer(viewport[3:4])
  stopifnot(all(!is.na(size), all(size >= 0)))
  result <- array(NA_real_, dim=c(size[1], size[2], length(component)))
  dimnames(result) <- list(NULL, NULL, component)
  if (length(result) > 0)
    for (i in seq_along(compnum)) {
      ret <- .C( rgl_pixels,
        success=FALSE,
        ll, size, compnum[i],
        values = double(size[1]*size[2]))
 
      if (! ret$success)
        warning(gettextf("Error reading component '%s'", component[i]), domain = NA)
      result[,,i] <- ret$values
    }
  if (length(component) > 1) return(result)
  else return(result[,,1])
}
