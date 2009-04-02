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
  size         = 3.0,
  lwd          = 1.0, 
  fog          = TRUE,
  point_antialias = FALSE,
  line_antialias = FALSE,
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
  rgl.bool(point_antialias)
  rgl.bool(line_antialias)
  rgl.clamp(shininess,0,128)
  rgl.numeric(size)
  rgl.numeric(lwd)
  
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

  idata <- as.integer( c( ncolor, lit, smooth, front, back, fog, 
                          textype, texmipmap, texminfilter, texmagfilter, 
                          nalpha, ambient, specular, emission, texenvmap, 
                          point_antialias, line_antialias, color ) )
  cdata <- as.character(c( texture ))
  ddata <- as.numeric(c( shininess, size, lwd, alpha ))

  ret <- .C( rgl_material,
    success = FALSE,
    idata,
    cdata,
    ddata
  )
}

rgl.getcolorcount <- function() .C( rgl_getcolorcount, count=integer(1) )$count
  
rgl.getmaterial <- function(ncolors = rgl.getcolorcount()) {

  idata <- rep(0, 23+3*ncolors)
  idata[1] <- ncolors
  idata[11] <- ncolors
  
  cdata <- paste(rep(" ", 512), collapse="")
  ddata <- rep(0, 2+ncolors)
  
  ret <- .C( rgl_getmaterial,
    success = FALSE,
    idata = as.integer(idata),
    cdata = cdata,
    ddata = as.numeric(ddata)
  )
  
  if (!ret$success) stop('rgl.getmaterial')
  
  polymodes <- c("filled", "lines", "points", "culled")
  textypes <- c("alpha", "luminance", "luminance.alpha", "rgb", "rgba")
  minfilters <- c("nearest", "linear", "nearest.mipmap.nearest", "nearest.mipmap.linear", 
                  "linear.mipmap.nearest", "linear.mipmap.linear")
  magfilters <- c("nearest", "linear")
  idata <- ret$idata
  ddata <- ret$ddata
  cdata <- ret$cdata
  
  list(color = rgb(idata[21 + 3*(1:idata[1])], idata[22 + 3*(1:idata[1])], idata[23 + 3*(1:idata[1])], maxColorValue = 255),
       alpha = ddata[seq(from=4, length=idata[11])],
       lit = idata[2] > 0,
       ambient = rgb(idata[12], idata[13], idata[14], maxColorValue = 255),
       specular = rgb(idata[15], idata[16], idata[17], maxColorValue = 255),
       emission = rgb(idata[18], idata[19], idata[20], maxColorValue = 255),
       shininess = ddata[1],
       smooth = idata[3] > 0,
       texture = if (cdata == "") NULL else cdata,
       textype      = textypes[idata[7]], 
       texmipmap    = idata[8] == 1,
       texminfilter = minfilters[idata[9] + 1],
       texmagfilter = magfilters[idata[10] + 1],
       texenvmap    = idata[21] == 1,
       front = polymodes[idata[4]],
       back = polymodes[idata[5]],
       size = ddata[2],
       lwd  = ddata[3],
       fog = idata[6] > 0,
       point_antialias = idata[22] == 1,
       line_antialias = idata[23] == 1)
                   
}
