##
## R source file
## This file is part of rgl
##
## $Id: material.R,v 1.1 2003/03/25 00:13:21 dadler Exp $
##

##
## ===[ SECTION: generic appearance function ]================================
##

rgl.material <- function ( 
  color = "white",  alpha = 1.0,
  lit = TRUE, ambient = "black",  specular="white", emission = "black", shininess = 50.0, 
  smooth = TRUE,  texture = NULL, textype = "rgb",
  front = "fill", back = "fill",
  size = 1.0, fog = TRUE )
{

  # solid or diffuse component

  color     <- rgl.mcolor(color)

  # light properties

  ambient   <- rgl.color(ambient)
  specular  <- rgl.color(specular)
  emission  <- rgl.color(emission)

  # others

  rgl.bool(lit)
  rgl.bool(fog)
  rgl.bool(smooth)
  rgl.clamp(shininess,0,128)
  rgl.numeric(size)
  
  # side-dependant rendering

  front <- rgl.enum.polymode(front)
  back  <- rgl.enum.polymode(back)

  # texture mapping

  if (length(texture) > 1)
    stop("texture should be a single character string or NULL")

  if (is.null(texture))
    texture <- ""

  textype <- rgl.enum.textype( textype )

  # vector length

  ncolor <- dim(color)[2]
  nalpha <- length(alpha)

  # pack data

  idata <- as.integer( c( ncolor, lit, smooth, front, back, fog, textype, nalpha, ambient, specular, emission, color ) )
  cdata <- as.character(c( texture ))
  ddata <- as.numeric(c( shininess, size, alpha ))

  ret <- .C( symbol.C("rgl_material"),
    success = FALSE,
    idata,
    cdata,
    ddata
  )
}
