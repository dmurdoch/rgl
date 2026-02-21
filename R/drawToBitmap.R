# idToBitmap <- function(id, ...) {
#   stopifnot(length(id) == 1)
#   
#   texts <- c(rgl.attrib(id, "texts"))
#   if (!length(texts))
#     return(NULL)
#   
#   cex <- c(rgl.attrib(id, "cex"))
#   family <- c(rgl.attrib(id, "family"))
#   font <- c(rgl.attrib(id, "font"))
#   
#   drawToBitmap(texts, cex = cex, family = family, font = font, ...)
# }


getPowerOfTwo <- function(n) {
  2^ceiling(log(n, 2))
}

drawToBitmap <- function(texts, cex = par3d("cex"), 
                         family = par3d("family"), 
                         fontfile = NULL,
                         font = par3d("font"), 
                         showBaselines = FALSE,
                         onePerLine = FALSE,
                         unique = !onePerLine,
                         minWidth = 0,
                         minHeight = 0,
                         powerOfTwo = FALSE,
                         verbose = FALSE) {
  
  if (!length(texts))
    return(NULL)
  
  df0 <- data.frame(texts = texts, cex = cex, family = family, font = font)
  if (unique) {
    keys0 <- paste(texts, cex, family, font, sep = "_")
  
    uniq <- !duplicated(keys0)
    df <- df0[uniq, ]
    keys <- keys0[uniq]
  } else
    df <- df0
  
  n <- nrow(df)
  
  texts <- enc2utf8(df$texts)
  cex <- as.double(df$cex)
  size <- as.double(20*cex)
  family <- as.character(df$family)
  font <- as.integer(df$font)
  if (length(fontfile) > 0) {
    fontfile <- as.character(fontfile)
    df$fontfile <- fontfile
    df$family <- NULL
  }
  
  # Measure the text
  
  measures <- measure_text(texts, family = family, fontfile = fontfile, font = font, cex = cex)
  
  # Change to integers, add a measure of safety
  
  bmWidth <- max(measures[, "x_advance"] - measures[, "x_bearing"] + 2, minWidth)
  if (powerOfTwo)
    bmWidth <- getPowerOfTwo(bmWidth)
  
  if (onePerLine) {
    heights <- measures[, "ascent"] + measures[,"descent"]
    xy <- cbind(x = 1 - measures[, "x_bearing"], y = cumsum(c(1, heights[-n])))
    attr(xy, "height") <- max(xy[,2] + measures[, "ascent"] + measures[, "descent"])
  } else {
    key <- paste(texts, family, font, cex, sep="_")
    xy <- pack_text(key, measures, bmWidth)
  }

  bmHeight <- max(attr(xy, "height"), minHeight)
  
  if (powerOfTwo)
    bmHeight <- getPowerOfTwo(bmHeight)

  bmWidth <- as.integer(bmWidth)
  bmHeight <- as.integer(bmHeight)
  
  result <- .Call(rasterText:::C_draw_text_to_rasterR, xy[,1], xy[,2], texts, family, font, fontfile, size, bmWidth, bmHeight )
  result <- matrix(result, bmHeight, bmWidth, byrow = TRUE)
  if (showBaselines) {
    for (i in 1:nrow(xy)) {
      result[xy[i, 2] + 
               measures[i, "baseline"]
             ,
             xy[i, 1]+
               measures[i, "x_bearing"] +
               0:measures[i, "width"]] <- 255
    }
  }
  
  result <- t(result)[,bmHeight:1]
  info <- data.frame(df, measures, xy)
  if (verbose) {
    cat("Bitmap dimensions ", nrow(result), ncol(result), "\n")
    print(info)
  }
  structure(result, info = info)
}
