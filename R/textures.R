# Attach the expression for the source of a texture if
# it is not already there,
# add names,
# convert to a list.

fixTextures <- function(textures, ...) {
  if (length(textures)) {
    if (inherits(textures, "rglTexture"))
      textures <- list(uSampler = textures)
    textures <- lapply(textures, fixTexture)
    names <- names(textures)
    if (!length(names)) {
      if (length(textures) == 1)
        names(textures) <- "uSampler"
      else
        stop("Multiple textures must be named.")
    } else 
      if (any(duplicated(names)))
        stop("Texture names must be unique")
  }
  textures
}

textureComponents <- c("filename",
                       "raster", 
                       "textype",
                       "texmode",
                       "texmipmap",
                       "texminfilter",
                       "texmagfilter",
                       "texenvmap")  

rglTexture <- function(filename, raster,
                       textype = default$textype,
                       texmode = default$texmode,
                       texmipmap = default$texmipmap,
                       texminfilter = default$texminfilter,
                       texmagfilter = default$texmagfilter,
                       texenvmap = default$texenvmap,
                       src = NULL,
                       default = material3d()) {
  result <- list(textype = textype,
                 texmode = texmode,
                 texmipmap = texmipmap,
                 texminfilter = texminfilter,
                 texmagfilter = texmagfilter,
                 texenvmap = texenvmap)
  if (is.numeric(textype))
    result <- decodeTexture(result)
  result$filename <- default$filename
  result$raster <- default$raster
  if (!missing(filename))
    result$filename <- filename
  else if (!missing(raster))
    result$raster <- raster
  
  if (!is.null(src))
    result$src <- src
  
  structure(result, class = "rglTexture")
}

# Convert internal integer codes to
# human readable ones
decodeTextures <- function(textures, id) {
  names <- names(textures)
  result <- list()
  for (i in seq_along(textures))
    result[[i]] <- decodeTexture(textures[[i]], id, names[i])
  names(result) <- names
  result
}

decodeTexture <- function(texture, id, name, withClass = TRUE) {
  names <- names(texture)
  stopifnot(all(names %in% textureComponents),
            # Need everything except filename and raster
            all(textureComponents[-(1:2)] %in% names))
  
  textypes <- c("alpha", "luminance", "luminance.alpha", "rgb", "rgba")
  texmodes <- c("replace", "modulate", "decal", "blend", "add")
  minfilters <- c("nearest", "linear", "nearest.mipmap.nearest", "nearest.mipmap.linear", 
                  "linear.mipmap.nearest", "linear.mipmap.linear")
  magfilters <- c("nearest", "linear")
  
  result <- texture
  result$textype <- textypes[texture$textype]
  result$texmode <- texmodes[texture$texmode + 1]
  result$texmipmap <- as.logical(texture$texmipmap)
  result$texminfilter <- minfilters[texture$texminfilter + 1]
  result$texmagfilter <- magfilters[texture$texmagfilter + 1]
  result$texenvmap <- as.logical(texture$texenvmap)
  if (!is.null(texture$filename) &&
      texture$filename == "<raster>") {
      result$filename <- NULL
      result$raster <- rgl.textureRaster(id, name)
  }
  
  if (withClass)
    rglTexture(default = result)
  else
    result
}


# Convert human readable texture 
# properties to internal integer codes

encodeTextures <- function(textures)
  lapply(textures, encodeTexture)

encodeTexture <- function(texture) {
  texture$textype <- rgl.enum.textype(texture$textype)
  texture$texmode <- rgl.enum.texmode(texture$texmode)
  texture$texminfilter <- rgl.enum.texminfilter(texture$texminfilter)
  texture$texmagfilter <- rgl.enum.texmagfilter(texture$texmagfilter)
  texture
}

# This just handles one component of the 
# texture list

prepareTexture <- function(texture) {
  arr <- NULL
  src <- NULL
  if (is.null(texture))
    result <- ""
  else if (is.list(texture))
    result <- texture
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

# A single texture should be a list
# with the named components from above.
# This function coerces it to that form:
# - a scalar character becomes the filename
# - anything else other than a list
#   is coerced to a raster

fixTexture <- function(texture) {
  if (is.character(texture) && length(texture) == 1) {
    texture <- rglTexture(filename = unname(texture))
  } else if (!is.list(texture)) {
    texture <- rglTexture(raster = as.raster(texture))
  }
  if (!inherits(texture, "rglTexture"))
    stop("Unrecognized texture type.")
  names <- names(texture)
  if (any(duplicated(names)) ||
      !all(names %in% textureComponents))
    stop("Unrecognized or duplicated texture component")
  texture
}

# Warn about putting a texture on a black surface, but only
# if the surface is black because that's the default.

warnBlackTexture <- function(...,
                             defaults = material3d(),
                             color = col, col = "missing",
                             texture = defaults$texture,
                             texmode = defaults$texmode) {
  if (!is.null(texture)) {
    if (length(color) == 1 &&
        !is.na(color) &&
        color == "missing" &&
        !is.na(texmode) && 
        texmode == "modulate" &&
        isTRUE(getOption("rgl.warnBlackTexture", TRUE)) &&
        length(defaults$color) &&
        !is.na(defaults$color[1]) &&
        defaults$color[1] %in% c("#000000", "black"))
      warning("Texture will be invisible on black surface", call. = FALSE) 
  }
}
