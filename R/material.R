##
## R source file
## This file is part of rgl
##
##

##
## ===[ SECTION: generic appearance function ]================================
##

rgl.material0 <- function(
  color        = "white",
  alpha        = 1.0,
  lit          = TRUE, 
  ambient      = "black",
  specular     = "white", 
  emission     = "black", 
  shininess    = 50.0, 
  smooth       = TRUE,
  textures     = NULL, 
  textype      = "rgb",
  texmode      = "modulate",
  texmipmap    = FALSE, 
  texminfilter = "linear", 
  texmagfilter = "linear",
  texenvmap    = FALSE,
  front        = "filled", 
  back         = "filled",
  size         = 3.0,
  lwd          = 1.0, 
  fog          = TRUE,
  point_antialias = FALSE,
  line_antialias = FALSE,
  depth_mask   = TRUE,
  depth_test   = "less",
  polygon_offset = c(0.0, 0.0),
  margin = "",
  floating = FALSE,
  tag = "",
  blend = c("src_alpha", "one_minus_src_alpha"),
  vertex_shader = "", 
  fragment_shader = "",
  user_attributes = NULL,
  user_uniforms = NULL,
  col,
  ...
) {
  # Allow compatibility with base graphics without relying
  # on abbreviated arguments
  
  if (missing(color) && !missing(col))
    color <- col
  
  # solid or diffuse component
  color     <- rgl.mcolor(color)
  if (length(color) < 1)
    stop("There must be at least one color")

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
  rgl.bool(depth_mask)
  rgl.clamp(shininess,0,128)
  rgl.numeric(size)
  rgl.numeric(lwd)
  depth_test <- rgl.enum.depthtest(depth_test)
  
  # side-dependant rendering

  front <- rgl.enum.polymode(front)
  back  <- rgl.enum.polymode(back)

  # texture mapping

  rgl.bool(texmipmap)

  tmp <- encodeTexture(list(textype = textype,
              texmode = texmode,
              texminfilter = texminfilter,
              texmagfilter = texmagfilter))
  rgl.bool(texenvmap)
  texdelete <- !is.null(attr(textures, "rgl_source"))
  
  # polygon offset
  
  stopifnot(is.numeric(polygon_offset), 
            length(polygon_offset) <= 2, 
            length(polygon_offset) >= 1)
  if (length(polygon_offset) == 1)
    polygon_offset <- c(polygon_offset, polygon_offset)

  # blending
  
  stopifnot(length(blend) == 2)
  blend <- c(rgl.enum.blend(blend[1]), rgl.enum.blend(blend[2]))
  
  # vector length

  ncolor <- dim(color)[2]
  nalpha <- length(alpha)

  margin <- parseMargin(margin, floating = floating)
  
  # user data
  
  tag <- as.character(tag)
  rgl.string(tag)
  
  # shaders
  rgl.string(vertex_shader)
  rgl.string(fragment_shader)

  # pack data

  idata <- as.integer( c( ncolor, lit, smooth, front, back, fog, 
                          tmp$textype, texmipmap, tmp$texminfilter, tmp$texmagfilter, 
                          nalpha, ambient, specular, emission, texenvmap, 
                          point_antialias, line_antialias, 
                          depth_mask, depth_test, 
                          margin$coord - 1, margin$edge, floating,

                          blend, tmp$texmode, color) )
  cdata <- as.character(c( tag, vertex_shader, fragment_shader ))
  ddata <- as.numeric(c( shininess, size, lwd, polygon_offset, alpha ))

  ret <- .C( rgl_material,
    success = FALSE,
    idata,
    cdata,
    ddata
  )$success
  
  if (ret) {
    
    if (!missing(textures))
      textures <- fixTextures(textures)
    
    for (i in seq_along(textures))
      if (is.list(textures[[i]]) &&
          is.null(textures[[i]]$filename) &&
          is.null(textures[[i]]$raster))
        stop("Bad texture specification.")
    
    textures <- lapply(textures, prepareTexture)
    textures <- encodeTextures(textures)
    ret <- .Call(rgl_textures_from_list, textures, texdelete)
  }
  
  # Make sure attributes and uniforms
  # are stored as doubles and contain
  # cases in each column
  
  if (ret) {
    stopifnot(is.null(user_attributes) || is.list(user_attributes), 
              length(user_attributes) == length(names(user_attributes)))
    user_attributes <- lapply(user_attributes, function(x) {storage.mode(x) <- "double"; t(x)})
    ret <- .Call(rgl_set_user_data,
                 user_attributes, TRUE)
  }
    
  if (ret) {
    stopifnot(is.null(user_uniforms) || is.list(user_uniforms),
              length(user_uniforms) == length(names(user_uniforms)))
    user_uniforms <- lapply(user_uniforms, function(x) {storage.mode(x) <- "double"; if (is.matrix(x)) t(x) else t(t(x))})
    ret <- .Call(rgl_set_user_data,
                 user_uniforms, FALSE)
  }
  
  ret
}

rgl.material <- function(...) {
  .Defunct("material3d")
}

rgl.getcolorcount <- function() .C( rgl_getcolorcount, count=integer(1) )$count
  
rgl.getmaterial <- function(ncolors, id = NULL) {

  if (!length(id)) id <- 0L
  if (missing(ncolors))
    ncolors <- if (id) rgl.attrib.count(id, "colors") else rgl.getcolorcount()
  
  idata <- rep(-1, 34+3*ncolors)
  idata[1] <- ncolors
  idata[11] <- ncolors
  
  cdata <- character(4)
  ddata <- rep(0, 5+ncolors)
  
  ret <- .C( rgl_getmaterial,
    success = FALSE,
    id = as.integer(id),
    idata = as.integer(idata),
    cdata = cdata,
    ddata = as.numeric(ddata)
  )
  
  if (!ret$success) stop('rgl.getmaterial failed')
  
  polymodes <- c("filled", "lines", "points", "culled")
  depthtests <- c("never", "less", "equal", "lequal", "greater", 
                  "notequal", "gequal", "always")
  blendmodes <- c("zero", "one", 
                  "src_color", "one_minus_src_color", 
                  "dst_color", "one_minus_dst_color",
                  "src_alpha", "one_minus_src_alpha",
                  "dst_alpha", "one_minus_dst_alpha",
                  "constant_color", "one_minus_constant_color",
                  "constant_alpha", "one_minus_constant_alpha",
                  "src_alpha_saturate")
  
  idata <- ret$idata
  ddata <- ret$ddata
  cdata <- ret$cdata
  
  # extract attributes and uniforms,
  # and transpose them back to the usual
  # form
  
  user_attributes <- .Call(rgl_get_user_data, as.integer(id), TRUE)
  user_attributes <- lapply(user_attributes, t) 
  user_uniforms <- .Call(rgl_get_user_data, as.integer(id), FALSE)
  user_uniforms <- lapply(user_uniforms,t)  
  
  textures <- .Call(rgl_get_textures, as.integer(id))
  
  textures <- decodeTextures(textures, id)
  
  tmp <- list(textype = idata[7],
              texmode = idata[34],
              texmipmap = idata[8],
              texminfilter = idata[9],
              texmagfilter = idata[10],
              texenvmap = idata[21])
  tmp <- decodeTexture(tmp, withClass = FALSE)

  c(tmp, list(color = rgb(idata[32 + 3*(seq_len(idata[1]))], 
                   idata[33 + 3*(seq_len(idata[1]))], 
                   idata[34 + 3*(seq_len(idata[1]))], maxColorValue = 255),
       alpha = if (idata[11]) ddata[seq(from=6, length.out = idata[11])] else 1,
       lit = idata[2] > 0,
       ambient = rgb(idata[12], idata[13], idata[14], maxColorValue = 255),
       specular = rgb(idata[15], idata[16], idata[17], maxColorValue = 255),
       emission = rgb(idata[18], idata[19], idata[20], maxColorValue = 255),
       shininess = ddata[1],
       smooth = idata[3] > 0,
       textures = textures,
       front = polymodes[idata[4]],
       back = polymodes[idata[5]],
       size = ddata[2],
       lwd  = ddata[3],
       fog = idata[6] > 0,
       point_antialias = idata[22] == 1,
       line_antialias = idata[23] == 1,
       depth_mask = idata[24] == 1,
       depth_test = depthtests[idata[25] + 1],
       isTransparent = idata[26] == 1,
       polygon_offset = ddata[4:5],
       margin = deparseMargin(list(coord = idata[27] + 1, edge = idata[28:30])),
       floating = idata[31] == 1,
       blend = blendmodes[idata[32:33] + 1],
       tag = cdata[1],
  		 vertex_shader = structure(cdata[3], class = "rglShader",
  		 													type = "vertex"),
  		 fragment_shader = structure(cdata[4], class = "rglShader",
  		 													type = "fragment"),
  		 user_attributes = user_attributes,
  		 user_uniforms = user_uniforms
       ))
            
}

textureSource <- function(texture) {
  .Deprecated("rgl.textureRaster")
  if (missing(texture))
    return(.rglEnv$textureDir)
  else if (texture == "<raster>")
    stop("No texture source.")
  if (requireNamespace("png")) {
    png <- png::readPNG(texture, info = TRUE)
    if (!is.null(info <- attr(png, "info")) && 
        !is.null(info$text) &&
        !is.na(src <- info$text["rgl_source"]))
      return(parse(text = src)[[1]])
  }
  texture
}

rgl.textureRaster <- function(id = NULL, name = "uSampler") {
  if (length(id) == 0L) id <- 0L
  stopifnot(length(id) == 1L)
  
  res <- .Call( rgl_textureRaster, 
                id = as.integer(id),
                name = as.character(name))
  if (is.null(res))
    return(res);
  if (dim(res)[3L] == 1L)
    res <- res[,,1L]
  as.raster(res, max = 255)
}
