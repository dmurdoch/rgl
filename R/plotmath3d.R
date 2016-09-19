plotmath3d <- function(x, y = NULL, z = NULL,
		       text, 
		       cex = par("cex"), adj = par("adj"),
		       fixedSize = TRUE,
		       startsize = 480, initCex = 5, 
		       ...) {
  xyz <- xyz.coords(x, y, z)
  n <- length(xyz$x)
  if (is.vector(text))
    text <- rep(text, length.out = n)
  cex <- rep(cex, length.out = n)
  adj <- c(adj, 0.5, 0.5)[1:2]
  save3d <- par3d(skipRedraw = TRUE)
  save <- options(device.ask.default = FALSE)
  on.exit({options(save); par3d(save3d)})
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
    w <- strwidth(thistext, cex = initCex, ...)*(2*abs(adj[1] - 0.5) + 1)
    h <- strheight(thistext, cex = initCex, ...)*(2*abs(adj[2] - 0.5) + 1)
    dev.off()
	
    # Now make a smaller bitmap
    expand <- 1.5
    size <- round(expand*startsize*max(w, h))
    png(f, bg = "transparent", width = size, height = size)
    par(mar = c(0, 0, 0, 0), xaxs = "i", xaxt = "n", 
        yaxs = "i", yaxt = "n",
        usr = c(0, 1, 0, 1))
    plot.new()
    text(0.5, 0.5, thistext, adj = adj, cex = initCex, ...)
    dev.off()

    with(xyz, sprites3d(x[i], y[i], z[i], texture = f, textype = "rgba", 
            col = "white", lit = FALSE, radius = cex[i]*size/initCex/20,
            fixedSize = fixedSize))
  }
}