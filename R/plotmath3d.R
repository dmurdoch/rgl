plotmath3d <- function(x, y = NULL, z = NULL,
		       text, 
		       cex = par("cex"), adj = 0.5,
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
  adj <- c(adj, 0.5, 0.5, 0.5)[1:3]
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

    # Now make a smaller bitmap
    expand <- 1.5
    size <- round(expand*startsize*max(c(w, h)))
    png(f, bg = "transparent", width = size, height = size)
    par(mar = c(0, 0, 0, 0), xaxs = "i", xaxt = "n", 
        yaxs = "i", yaxt = "n",
        usr = c(0, 1, 0, 1))
    plot.new()
    text(0.5, 0.5, thistext, adj = c(0.5,0.5), cex = initCex, ...)
    dev.off()
    # The 0.4 tries to match the text3d offset
    offseti <- 0.4*offset*h/w
    posi <- if (is.null(pos)) NULL else pos[i]
    result[i] <- with(xyz, sprites3d(x[i], y[i], z[i], texture = f, textype = "rgba", 
            col = "white", lit = FALSE, radius = cex[i]*size/initCex/20,
            adj = adj, pos = posi, offset = offseti,
            fixedSize = fixedSize))
  }
  lowlevel(result)
}
