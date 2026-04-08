glyphAtlas <- function(text, family = "sans", font = 1,
                       cex = 1, col = "black",
                       monochrome = TRUE,
                       atlas = NULL) {
  stopifnot(is.null(atlas) || inherits(atlas, "glyph_atlas") || is.character(atlas))
  n <- length(text)
  family <- rep_len(as.character(family), n)
  font <- rep_len(as.integer(font), n)
  cex <- rep_len(as.double(cex), n)
  col <- rep_len(col, n)
  monochrome <- as.logical(monochrome)

  rgb <- col2rgb(col, alpha = TRUE)

  .Call(rgl_build_atlasR, text, family, font, cex, rgb, monochrome, atlas)
}

print.glyph_atlas <- function(x, verbose = FALSE, ...) {
  dim <- dim(x$buffer)
  monochrome <- x$monochrome
  if (!monochrome) dim <- dim[-1]
  cat("Glyph atlas:\n")
  if (monochrome)
    cat("  monochrome")
  else
    cat("  color")
  cat(sprintf(" buffer size %d x %d\n", dim[1], dim[2]))
  cat(sprintf("  %d fonts\n", length(x$fonts)))
  if (verbose)
    print(x$fonts)
  cat(sprintf("  %d glyphs\n", nrow(x$glyphs)))
  if (verbose)
    print(x$glyphs)
  cat(sprintf("  %d strings\n", nrow(x$strings)))
  if (verbose) {
    for (i in seq_len(nrow(x$strings))) {
      print(x$strings[i,])
      print(x$fragments[x$fragments$stringnum == i,])
    }
  }
  invisible(x)
}

plot.glyph_atlas <- function(x, y, interpolate = FALSE, ...) {
  b <- x$buffer
  if (length(dim(b)) == 2) {
    raster <- as.raster(t(b),
                        max = 255)
  } else {
    raster <- aperm(b, c(3,2,1))
    raster <- raster[,,4:1]
    raster <- as.raster(raster, max = 255)
  }
  save <- par(mar = c(1,1,1,1))
  on.exit(par(save))
  plot(raster, interpolate = interpolate, ...)
}

bufferToRaster <- function(buffer) {
  if (length(dim(buffer)) == 2)
    # reverse black and white 
    as.raster(t(255 - buffer), max = 255)
  else {
    raster <- aperm(buffer, c(3,2,1))
    # put in rgba order instead of abgr
    raster <- raster[,,4:1]
    as.raster(raster, max = 255)
  }
}

renderFromAtlas <- function(atlas, num, x = 0, y = 0,
                            verbose = FALSE,
                            interpolate = FALSE,
                            showBaselines = FALSE, ...) {
  xlim <- range(x)
  ylim <- range(y)
  xlims <- list()
  x <- rep_len(x, length(num))
  y <- rep_len(y, length(num))
  frags <- list()
  for (i in seq_along(num)) {
    frags[[i]] <- fragment <- atlas$fragments[atlas$fragments$stringnum == num[i],]
    glyphs <- cbind(fragment, atlas$glyphs[fragment$glyphnum,])
    xlims[[i]] <- range(c(x[i] + glyphs$x_offset + glyphs$x,
                          x[i] + glyphs$x_offset + glyphs$x + glyphs$width))
    xlim <- range(c(xlim, xlims[[i]]))
    ylim <- range(c(ylim,
                    y[i] + glyphs$y_offset - glyphs$y,
                    y[i] + glyphs$y_offset - glyphs$y - glyphs$height))
  }
  plot(xlim, ylim, type = "n", asp = 1, ...)
  raster <- bufferToRaster(atlas$buffer)
  for (i in seq_along(num)) {
    if (verbose) {
      string <- atlas$strings[num[i],]
      font <- atlas$fonts[string$fontnum]
      message("Rendering '", string$text, "' in font ", font)
    }
    fragment <- frags[[i]]
    glyphs <- cbind(fragment, atlas$glyphs[fragment$glyphnum,])
    for (j in seq_len(nrow(glyphs))) {
      g <- glyphs[j,]
      r <- raster[g$y_atlas + 1:g$height, g$x_atlas + 1:g$width]
      rasterImage(r, xleft = x[i] + g$x_offset + g$x,
                  xright = x[i] + g$x_offset + g$x + g$width,
                  ytop = y[i] + g$y_offset - g$y,
                  ybottom = y[i] + g$y_offset - g$y- g$height,
                  interpolate = interpolate)
    }
    if (showBaselines)
      segments(xlims[[i]][1], y[i], xlims[[i]][2], y[i])
  }
}
