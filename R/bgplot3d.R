legend3d <- function(...) {
  result <- bgplot3d({
    par(mar=c(0,0,0,0))
    plot(0,0, type="n", xlim=0:1, ylim=0:1, xaxs="i", yaxs="i", axes=FALSE, bty="n")
    legend(...)
  })
  invisible(result)
}

bgplot3d <- function(expression) {
  viewport <- par3d("viewport")
  width <- viewport["width"]
  height <- viewport["height"]
  filename <- tempfile(fileext = ".png")
  png(filename = filename, width=width, height=height)
  value <- expression  
  dev.off()
  result <- bg3d(texture=filename, col="white")
  unlink(filename)
  invisible(structure(result, value = value))
}
