##
## R source file
## This file is part of rgl
##
## $Id$
##

##
## ===[ SECTION: internal ]===================================================
##

#
# rgl.range
#
# ensure value x is between low and high
#

rgl.range <- function ( x, low, high )
{
  if (length(x) > 1)
    stop( gettextf("'%s' must be a single numeric", deparse(substitute(x))), domain = NA)
  if ( ( x < low ) || ( x > high ) )
    stop( gettextf("'%s' must be a numeric in the range [%s, %s]", 
    	           deparse(substitute(x)), low, high), domain = NA)
}


#
# rgl.clamp
#
# clamp value if lower than low or higher than high
#

rgl.clamp <- function(value, low, high)
{
  if (value < low) {
    warning( gettextf("Value clamped to %s",low), domain = NA )
    result <- low
  }
  else if (value > high) {
    warning( gettextf("Value clamped to %s",high), domain = NA )
    result <- high
  }
  else {
    result <- value
  }

  return (result);
}

##
## types verification
##


#
# single field bool
#

rgl.bool <- function ( x )
{
  if (length(x) > 1)
    stop( gettextf("'%s' must be a single boolean value", deparse(substitute(x))),
          domain = NA)
}


#
# single field numeric
#

rgl.numeric <- function ( x )
{
  if (length(x) > 1)
    stop( gettextf("'%s' must be a single numeric value", deparse(substitute(x))),
          domain = NA)
}


#
# vertex data object
#

rgl.vertex <- function (x,y=NULL,z=NULL)
{
  xyz <- xyz.coords(x,y,z,recycle=TRUE)
  return ( matrix( rbind(xyz$x,xyz$y,xyz$z), nrow=3, dimnames=list( c("x","y","z"), NULL ) ) )
}

#
# texture coordinate data object
#

rgl.texcoords <- function(s,t=NULL) 
{
  xy <- xy.coords(s, t, recycle=TRUE)
  return( matrix( rbind(xy$x, xy$y), nrow=2, dimnames=list( c("s", "t"), NULL ) ) )
}

#
# obtain number of vertices
#

rgl.nvertex <- function (vertex)
{  
  return ( ncol(vertex) )
}


#
# rgl.color - single field color
#

rgl.color <- function ( color )
{
  if (length(color) > 1)
    stop( gettextf("'%s' must be a single color character string", deparse(substitute(color))), 
          domain = NA)
  else
    return (col2rgb(color))
}


#
# rgl.mcolor - multiple field colors
#

rgl.mcolor <- function ( colors )
{
  return ( col2rgb(colors) )
}


#
# if vattr > 1, recycle data
#

rgl.attr <- function (vattr, nvertex) 
{
  nvattr <- length(vattr)

  if ((nvattr > 1) && (nvattr != nvertex))
    vattr  <- rep(vattr,length.out=nvertex)
  
  return(vattr)
}
