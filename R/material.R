##
## R source file
## This file is part of rgl
##
## $Id$
##

##
## ===[ SECTION: generic appearance function ]================================
##

rgl.material <- function (
  color        = c("white"),
  alpha        = c(1.0),
  lit          = TRUE, 
  ambient      = "black",
  specular     = "white", 
  emission     = "black", 
  shininess    = 50.0, 
  smooth       = TRUE,
  texture      = NULL, 
  textype      = "rgb", 
  texmipmap    = FALSE, 
  texminfilter = "linear", 
  texmagfilter = "linear",
  texenvmap    = FALSE,
  front        = "fill", 
  back         = "fill",
  size         = 1.0, 
  fog          = TRUE,
  ...
) {
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

  rgl.bool(texmipmap)

  if (length(texture) > 1)
    stop("texture should be a single character string or NULL")

  if (is.null(texture))
    texture <- ""

  textype <- rgl.enum.textype( textype )
  texminfilter <- rgl.enum.texminfilter( texminfilter )
  texmagfilter <- rgl.enum.texmagfilter( texmagfilter )
  rgl.bool(texenvmap)

  # vector length

  ncolor <- dim(color)[2]
  nalpha <- length(alpha)

  # pack data

  idata <- as.integer( c( ncolor, lit, smooth, front, back, fog, textype, texmipmap, texminfilter, texmagfilter, nalpha, ambient, specular, emission, texenvmap, color ) )
  cdata <- as.character(c( texture ))
  ddata <- as.numeric(c( shininess, size, alpha ))

  ret <- .C( rgl_material,
    success = FALSE,
    idata,
    cdata,
    ddata
  )
}

rgl.getcolorcount <- function() .C( rgl_getcolorcount, count=integer(1) )$count
  
rgl.getmaterial <- function(ncolors = rgl.getcolorcount()) {

  idata <- rep(0, 21+3*ncolors)
  idata[1] <- ncolors
  idata[11] <- ncolors
  
  cdata <- character(0)
  ddata <- rep(0, 2+ncolors)
  
  ret <- .C( rgl_getmaterial,
    success = FALSE,
    idata = as.integer(idata),
    cdata = cdata,
    ddata = as.numeric(ddata)
  )
  
  if (!ret$success) stop('rgl.getmaterial')
  
  polymodes = c("filled", "lines", "points", "culled")
  
  idata <- ret$idata
  ddata <- ret$ddata
  
  list(color = rgb(idata[19 + 3*(1:idata[1])], idata[20 + 3*(1:idata[1])], idata[21 + 3*(1:idata[1])], maxColorValue = 255),
       alpha = ddata[seq(from=3, length=idata[11])],
       lit = idata[2] > 0,
       ambient = rgb(idata[12], idata[13], idata[14], maxColorValue = 255),
       specular = rgb(idata[15], idata[16], idata[17], maxColorValue = 255),
       emission = rgb(idata[18], idata[19], idata[20], maxColorValue = 255),
       shininess = ddata[1],
       smooth = idata[3] > 0,
       front = polymodes[idata[4]],
       back = polymodes[idata[5]],
       size = ddata[2],
       fog = idata[6] > 0)
                   
}
