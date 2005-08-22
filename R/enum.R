##
## R source file
## This file is part of rgl
##
## $Id$
##


##
## ===[ SECTION: enumerations ]===============================================
##

##
## FUNCTIONS
##   rgl.enum
##
## utility function translating literals to ids
##

rgl.enum   <- function ( name, ..., multi = FALSE)
{
  choices <- list( ... )
  names   <- attr(choices,"names")

  if (multi) pos <- pmatch( name, c(names, "all") )
  else pos <- pmatch( name, names )
 
  max <- length(names)

  if ( any( is.na(pos) ) )
    stop("symbolic value must be chosen from ", list(names) )
  else if ( (max+1) %in% pos )
    pos <- seq(along = names)
    
  id  <- unlist(choices[pos])
  
  if ( length(id) > 1 && !multi )
    stop("multiple choices not allowed")
 
  return( id )
}

##
## ENUM FUNCTIONS
##

rgl.enum.nodetype <- function (type)
  return ( rgl.enum( type, shapes=1, lights=2, bboxdeco=3, viewpoint=4, multi = TRUE ) )

rgl.enum.pixfmt <- function (fmt)
  return ( rgl.enum( fmt, png=0 ) )

rgl.enum.polymode <- function (mode)
  return ( rgl.enum( mode, filled=1, lines=2, points=3, culled=4) )

rgl.enum.textype <- function (textype)
  return ( rgl.enum( textype, alpha=1, luminance=2, luminance.alpha=3, rgb=4, rgba=5 ) )

rgl.enum.fogtype <- function (fogtype)
  return ( rgl.enum (fogtype, none=1, linear=2, exp=3, exp2=4) )

rgl.enum.primtype <- function (primtype)
  return ( rgl.enum( primtype, points=1, lines=2, triangles=3, quadrangles=4, linestrips=5 ) )

rgl.enum.halign <- function( halign)
  return ( rgl.enum (halign, left=-1, center=0, right=1 ) )
  
rgl.enum.texminfilter <- function (minfiltertype)
  return ( rgl.enum (minfiltertype, nearest=0, linear=1, nearest.mipmap.nearest=2, nearest.mipmap.linear=3, linear.mipmap.nearest=4, linear.mipmap.linear=5) )
  
rgl.enum.texmagfilter <- function (magfiltertype)
  return ( rgl.enum (magfiltertype, nearest=0, linear=1) )

# see GL2PS_XXX defines in ../src/gl2ps.h
rgl.enum.gl2ps <- function (postscripttype)
  return ( rgl.enum (postscripttype, ps=1, eps=2, tex=3, pdf=4) )
