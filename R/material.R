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
  texture      = NULL, 
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

  texture <- prepareTexture(texture)

  if (is.array(texture)) {
    arr <- texture
    texture <- ""
  } else
    arr <- NULL
  
  textype <- rgl.enum.textype( textype )
  texmode <- rgl.enum.texmode( texmode )
  texminfilter <- rgl.enum.texminfilter( texminfilter )
  texmagfilter <- rgl.enum.texmagfilter( texmagfilter )
  rgl.bool(texenvmap)
  texdelete <- !is.null(attr(texture, "rgl_source"))
  
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
                          textype, texmipmap, texminfilter, texmagfilter, 
                          nalpha, ambient, specular, emission, texenvmap, 
                          point_antialias, line_antialias, 
                          depth_mask, depth_test, 
                          margin$coord - 1, margin$edge, floating,

                          blend, texmode, texdelete, color) )
  cdata <- as.character(c( tag, texture, vertex_shader, fragment_shader ))
  ddata <- as.numeric(c( shininess, size, lwd, polygon_offset, alpha ))

  ret <- .C( rgl_material,
    success = FALSE,
    idata,
    cdata,
    ddata
  )$success
  
  if (ret && !is.null(arr))
    ret <- .Call(rgl_texture_from_array, arr)
  
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
  textypes <- c("alpha", "luminance", "luminance.alpha", "rgb", "rgba")
  texmodes <- c("replace", "modulate", "decal", "blend", "add")
  minfilters <- c("nearest", "linear", "nearest.mipmap.nearest", "nearest.mipmap.linear", 
                  "linear.mipmap.nearest", "linear.mipmap.linear")
  magfilters <- c("nearest", "linear")
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
  
  list(color = rgb(idata[32 + 3*(seq_len(idata[1]))], 
                   idata[33 + 3*(seq_len(idata[1]))], 
                   idata[34 + 3*(seq_len(idata[1]))], maxColorValue = 255),
       alpha = if (idata[11]) ddata[seq(from=6, length.out = idata[11])] else 1,
       lit = idata[2] > 0,
       ambient = rgb(idata[12], idata[13], idata[14], maxColorValue = 255),
       specular = rgb(idata[15], idata[16], idata[17], maxColorValue = 255),
       emission = rgb(idata[18], idata[19], idata[20], maxColorValue = 255),
       shininess = ddata[1],
       smooth = idata[3] > 0,
       texture = if (cdata[2] == "") NULL else cdata[2],
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
       line_antialias = idata[23] == 1,
       depth_mask = idata[24] == 1,
       depth_test = depthtests[idata[25] + 1],
       isTransparent = idata[26] == 1,
       polygon_offset = ddata[4:5],
       margin = deparseMargin(list(coord = idata[27] + 1, edge = idata[28:30])),
       floating = idata[31] == 1,
       blend = blendmodes[idata[32:33] + 1],
       texmode = texmodes[idata[34] + 1],
       tag = cdata[1],
  		 vertex_shader = structure(cdata[3], class = "rglShader",
  		 													type = "vertex"),
  		 fragment_shader = structure(cdata[4], class = "rglShader",
  		 													type = "fragment"),
  		 user_attributes = user_attributes,
  		 user_uniforms = user_uniforms
       )
            
}

prepareTexture <- function(texture) {
  arr <- NULL
  src <- NULL
  if (is.null(texture))
    result <- ""
  else if (is.character(texture) && length(texture) == 1) {
    if (texture == "<raster>") 
      result <- ""
    else {
      # Assume it's a filename
      ext <- tolower(file_ext(texture))
      if (ext %in% c("jpg", "jpeg")) {
        if (requireNamespace("jpeg"))
          arr <- jpeg::readJPEG(texture)
        else
          stop("JPEG textures require the 'jpeg' package")
        src <- texture
      } else
        result <- normalizePath(texture)
    }
  } else {
    raster <- as.raster(texture)
    arr <- col2rgb(raster)/255
    dim(arr) <- c(dim(raster), 3)
  }
  
  if (!is.null(arr)) {
    result <- arr
    origsrc <- attr(texture, "src")
    if (!is.null(origsrc))
      src <- origsrc
  }
  
  structure(result, rgl_source = src)
}

textureSource <- function(texture) {
  if (missing(texture))
    return(.rglEnv$textureDir)
  if (requireNamespace("png")) {
    png <- png::readPNG(texture, info = TRUE)
    if (!is.null(info <- attr(png, "info")) && 
        !is.null(info$text) &&
        !is.na(src <- info$text["rgl_source"]))
      return(parse(text = src)[[1]])
  }
  texture
}

rgl.textureRaster <- function(id = NULL) {
  if (length(id) == 0L) id <- 0L
  stopifnot(length(id) == 1L)
  
  res <- .Call( rgl_textureRaster, 
                id = as.integer(id) )
  if (is.null(res))
    return(res);
  if (dim(res)[3L] == 1L)
    res <- res[,,1L]
  as.raster(res, max = 255)
}
