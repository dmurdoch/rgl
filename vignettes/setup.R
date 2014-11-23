
library(rgl)
options(rgl.useNULL=TRUE)

rgl.knitr <- local({
  canvasMatrix <- TRUE
  function (before, options, envir) 
  {
    if (before || rgl::rgl.cur() == 0 || !requireNamespace("knitr")) 
      return()
    out_type <- knitr::opts_knit$get("rmarkdown.pandoc.to")
    if (out_type != "html") 
      stop("The rgl.knitr hook is for HTML only.  Use knitr::hook_rgl instead.")
    
    name <- tempfile("webgl", tmpdir = ".", fileext = ".html")
    on.exit(unlink(name))
    rgl::par3d(windowRect = options$dpi * c(0, 0, options$fig.width, 
                                            options$fig.height)/2)
    prefix = gsub("[^[:alnum:]]", "_", options$label)
    prefix = sub("^([^[:alpha:]])", "_\\1", prefix)
    rgl::writeWebGL(dir = dirname(name), 
                    filename = name, 
                    snapshot = !rgl.useNULL(),
                    template = NULL, 
                    prefix = prefix, 
                    canvasMatrix = canvasMatrix)
    canvasMatrix <<- FALSE
    res <- readLines(name)
    res <- res[!grepl("^\\s*$", res)]
    paste(gsub("^\\s+", "", res), collapse = "\n")
  }
})

knitr::knit_hooks$set(rgl = rgl.knitr)

documentedfns <- c()
indexfns <- function(fns, show = TRUE) {
  documentedfns <<- c(documentedfns, fns)
  anchors <- paste0('<a name="', fns, '">', 
                    if (show) paste0("<code>", fns, "</code>"), 
                    '</a>')
  paste(anchors, collapse=if (show) ", " else "")
}
