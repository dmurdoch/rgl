latex3d <- function(x, y = NULL, z = NULL,
		       text, 
		       cex = par("cex"), adj = 0.5,
		       pos = NULL, offset = 0.5,
		       fixedSize = TRUE,
		       startsize = 480, initCex = 5, 
		       margin = "", floating = FALSE, tag = "",
		       verbose = FALSE,
		       ...) {
  if (!requireNamespace("xdvir"))
    stop("This function requires the `xdvir` package.")
  xyz <- xyz.coords(x, y, z, recycle = TRUE)
  n <- length(xyz$x)
  if (is.vector(text))
    text <- rep(text, length.out = n)
  cex <- rep(cex, length.out = n)
  if (!is.null(pos))
    pos <- rep_len(pos, n)
  adj <- c(adj, 0.5, 0.5, 0.5)[1:3]
  save3d <- par3d(skipRedraw = TRUE)
  save <- options(device.ask.default = FALSE, tinytex.verbose = verbose, xdvir.engine = "xetex")
  on.exit({options(save); par3d(save3d)}) # nolint
  result <- integer(n)
  if (verbose) {
    cat("TeX status:\n")
    xdvir::TeXstatus()
  }
  for (i in seq_len(n)) {
    # Open the device twice.  The first one is to measure the text...
    f <- tempfile(fileext = ".png")
    png(f, bg = "transparent", width = initCex*startsize, height = initCex*startsize, res = initCex*72)
    if (is.vector(text))
      thistext <- text[i]
    else
      thistext <- text
    if (verbose) {
      doc <- xdvir::author(thistext, ...)
      cat("\nGenerated LaTeX:\n")
      print(doc)
      texfile <- tempfile("t", fileext=".tex")
      if (.Platform$OS.type == "windows")
        gsub("/", "\\", texfile, fixed = TRUE)
      cat("\nWriting tex to ", texfile, "\n")
      dvi <- xdvir::typeset(doc, texFile = texfile, ...)
      cat("\nGenerated DVI:\n")
      print(dvi)
      g <- xdvir::dviGrob(dvi, ...)
    } else 
      g <- xdvir::latexGrob(thistext, ...)
    w_npc <- grid::convertWidth(grid::grobWidth(g), "npc", valueOnly = TRUE)
    h_npc <- grid::convertHeight(grid::grobHeight(g), "npc", valueOnly = TRUE)
    safe.dev.off()

    # Now make a smaller bitmap
    maxdim <- max(w_npc, h_npc)
    size <- round(initCex*startsize*maxdim)
    png(f, bg = "transparent", 
        width = size, height = size+1, 
        pointsize = 12, res = initCex*72)
    grid::grid.draw(g)
    
    safe.dev.off()
    # The 0.4 tries to match the text3d offset
    offseti <- 0.4*offset*h_npc/w_npc
    posi <- if (is.null(pos)) NULL else pos[i]
    result[i] <- with(xyz, sprites3d(x[i], y[i], z[i], texture = f, textype = "rgba", 
            col = "white", lit = FALSE, radius = cex[i]*size/initCex/20,
            adj = adj, pos = posi, offset = offseti,
            fixedSize = fixedSize,
            margin = margin, floating = floating, tag = tag))
  }
  lowlevel(result)
}
