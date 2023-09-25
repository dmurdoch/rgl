idToBitmap <- function(id, ...) {
  stopifnot(length(id) == 1)
  
  texts <- rgl.attrib(id, "texts")
  if (!length(texts))
    return(NULL)
  
  cex <- rgl.attrib(id, "cex")
  family <- rgl.attrib(id, "family")
  font <- rgl.attrib(id, "font")
  
  drawToBitmap(texts, cex = cex, family = family, font = font, ...)
}

drawToBitmap <- function(texts, cex = par3d(cex), family = par3d("family"), font = par3d("font"), background = "transparent",
                         verbose = FALSE) {
  
  n <- length(texts)
  if (!n)
    return(NULL)
  
  shaping <- textshaping::shape_text(texts, family = family,
                          italic = font > 2,
                          bold = font %in% c(2, 4),
                          size = cex * 12,
                          align = "left",
                          hjust = 0,
                          vjust = 0)
  if (verbose)
    print(shaping)

  metrics <- shaping$metrics
  x0 <- 0
  x1 <- metrics$width + pmax(0, -metrics$left_bearing) +
                        pmax(0, -metrics$right_bearing)

  
  # First pass:  measure the text
  
  ragg::agg_capture(width = 480, height = 480)
  on.exit(dev.off())
  
  pixels <- function(size) ceiling(as.numeric(grid::convertUnit(size, "npc"))*480)
  
  widths <- numeric(n)
  ascents <- numeric(n)
  descents <- numeric(n)
  
  for (fam in unique(family)) {
    gp <- fam == family
    grid::pushViewport(grid::viewport(gp = grid::gpar(cex = cex[gp], font = font[gp], fontfamily = fam)))
    widths[gp] <- pixels(grid::stringWidth(texts[gp]))
    ascents[gp] <- pixels(grid::stringAscent(texts[gp])) + 1
    descents[gp] <- pixels(grid::stringDescent(texts[gp])) + 1
    grid::popViewport()
  }
  on.exit(NULL)
  dev.off()
  
  maxwidth <- max(ceiling(widths))
  
  heights <- ceiling(ascents) + ceiling(descents) 
  totalheight <- sum(heights)
  y <- c(0, cumsum(heights[-n])) + descents

  getraster <- ragg::agg_capture(width = maxwidth, height = totalheight, units = "px", background = background)
  
  if (verbose)
    cat("width=", maxwidth, "height=", totalheight, "\n")
  
  on.exit(dev.off())
  
  for (fam in unique(family)) {
    gp <- fam == family
    grid::pushViewport(grid::viewport(gp = grid::gpar(cex = cex[gp], font = font[gp], fontfamily = fam)))
    grid::grid.text(texts[gp], x = 0, y = grid::unit(y[gp]/totalheight, "npc"), just = c(0,0))
    if (verbose)
      cat("width = ", widths[gp], "\n",
          "ascent = ", ascents[gp], "\n",
          "descent = ", descents[gp], "\n")
    grid::popViewport()
  }
  
  # grid::grid.lines(x = rep(c(0,1,NA), n), y = grid::unit(rep(y/totalheight, each = 3), "npc")) # baselines
  
  getraster(TRUE)
}

library(rgl)
x <- text3d(1:4, 1:4, 1:4, c("xxx", "yyy", "xxx", "xxM"), cex=5)
y <- idToBitmap(x, verbose = TRUE)
grid::grid.raster(y)