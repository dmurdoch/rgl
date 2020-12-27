plotmath3d <- function(x, y = NULL, z = NULL,
		       text, 
		       cex = par("cex"), adj = par("adj"),
		       pos = NULL, offset = 0.5,
		       fixedSize = TRUE,
		       startsize = 480, initCex = 5, 
		       ...) {
  xyz <- xyz.coords(x, y, z)
  n <- length(xyz$x)
  if (is.vector(text))
    text <- rep(text, length.out = n)
  cex <- rep(cex, length.out = n)
  if (!is.null(pos))
    pos <- rep_len(pos, n)
  else
    adj <- c(adj, 0.5, 0.5)[1:2]
  save3d <- par3d(skipRedraw = TRUE)
  save <- options(device.ask.default = FALSE)
  on.exit({options(save); par3d(save3d)}) # nolint
  result <- integer(n)
  for (i in seq_len(n)) {
    # Open the device twice.  The first one is to measure the text...
    f <- tempfile(fileext = ".png")
    png(f, bg = "transparent", width = startsize, height = startsize)
    par(mar = c(0, 0, 0, 0), xaxs = "i", xaxt = "n",  
        yaxs = "i", yaxt = "n",
        usr = c(0, 1, 0, 1))
    plot.new()
    if (is.vector(text))
      thistext <- text[i]
    else
      thistext <- text
    w <- strwidth(thistext, cex = initCex, ...)
    w1 <- strwidth("m", cex = initCex, ...)
    h <- strheight(thistext, cex = initCex, ...)
    dev.off()

    if (!is.null(pos)) 
      adj <- list("1" = c(0.5, 1 + offset), 
                  "2" = c(1 + w1*offset/w, 0.5), 
                  "3" = c(0.5, -offset), 
                  "4" = c(-w1*offset/w, 0.5))[[pos[i]]]
    
    # Now make a smaller bitmap
    expand <- 1.5
    size <- round(expand*startsize*max(c(w, h)*(2*abs(adj - 0.5) + 1)))
    png(f, bg = "transparent", width = size, height = size)
    par(mar = c(0, 0, 0, 0), xaxs = "i", xaxt = "n", 
        yaxs = "i", yaxt = "n",
        usr = c(0, 1, 0, 1))
    plot.new()
    text(0.5, 0.5, thistext, adj = adj, cex = initCex, ...)
    dev.off()

    result[i] <- with(xyz, sprites3d(x[i], y[i], z[i], texture = f, textype = "rgba", 
            col = "white", lit = FALSE, radius = cex[i]*size/initCex/20,
            fixedSize = fixedSize))
  }
  lowlevel(result)
}
