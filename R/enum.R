# enumerations

rgl.enum <- function ( name, ..., multi = FALSE)
{
  choices <- list( ... )
  names   <- attr(choices,"names")

  if (multi) pos <- pmatch( name, c(names, "all") )
  else pos <- pmatch( name, names )
 
  max <- length(names)

  if ( any( is.na(pos) ) )
    stop("symbolic value must be chosen from ", list(names) )
  else if ( (max+1) %in% pos )
    pos <- seq_along(names)
    
  id  <- unlist(choices[pos])
  
  if ( length(id) > 1 && !multi )
    stop("multiple choices not allowed")
 
  return( id )
}

rgl.enum.nodetype <- function (type) 
rgl.enum( type, shapes=1, lights=2, bboxdeco=3, viewpoint=4, material=5, background=6, multi = TRUE )

rgl.enum.attribtype <- function (attrib)
rgl.enum( attrib, vertices=1, normals=2, colors=3, texcoords=4, dim=5, 
          texts=6, cex=7, adj=8)

rgl.enum.pixfmt <- function (fmt)
rgl.enum( fmt, png=0 )

rgl.enum.polymode <- function (mode)
rgl.enum( mode, filled=1, lines=2, points=3, culled=4)

rgl.enum.textype <- function (textype)
rgl.enum( textype, alpha=1, luminance=2, luminance.alpha=3, rgb=4, rgba=5 )

rgl.enum.fogtype <- function (fogtype)
rgl.enum (fogtype, none=1, linear=2, exp=3, exp2=4)

rgl.enum.primtype <- function (primtype)
rgl.enum( primtype, points=1, lines=2, triangles=3, quadrangles=4, linestrips=5 )

rgl.enum.halign <- function( halign)
rgl.enum (halign, left=-1, center=0, right=1 )
  
rgl.enum.texminfilter <- function (minfiltertype)
rgl.enum (minfiltertype, nearest=0, linear=1, nearest.mipmap.nearest=2, nearest.mipmap.linear=3, linear.mipmap.nearest=4, linear.mipmap.linear=5)
  
rgl.enum.texmagfilter <- function (magfiltertype)
rgl.enum (magfiltertype, nearest=0, linear=1)

rgl.enum.gl2ps <- function (postscripttype)
rgl.enum (postscripttype, ps=0, eps=1, tex=2, pdf=3, svg=4, pgf=5)

rgl.enum.pixelcomponent <- function(component)
rgl.enum(component, red=0, green=1, blue=2, alpha=3, depth=4, luminance=5)

rgl.enum.depthtest <- function(depthtest)
rgl.enum(depthtest, never=0, less=1, equal=2, lequal=3, greater=4, 
                    notequal=5, gequal=6, always= 7)