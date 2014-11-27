
library(rgl)
options(rgl.useNULL=TRUE)

hook_webgl <- local({
  canvasMatrix <- TRUE
  function (before, options, envir) 
  {
    if (before || rgl::rgl.cur() == 0 || !requireNamespace("knitr")) 
      return()
    out_type <- knitr::opts_knit$get("out.format")
    if (!length(intersect(out_type, c("markdown", "html"))))       
      stop("hook_webgl is for HTML only.  Use knitr::hook_rgl instead.")
    
    name <- tempfile("webgl", tmpdir = ".", fileext = ".html")
    on.exit(unlink(name))
    dpi <- 96 # was options$dpi
    rgl::par3d(windowRect = dpi * c(0, 0, options$fig.width, 
                                            options$fig.height))
    Sys.sleep(0.1)
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

knitr::knit_hooks$set(rgl = hook_webgl)

documentedfns <- c()
indexfns <- function(fns, show = TRUE) {
  documentedfns <<- c(documentedfns, fns)
  anchors <- paste0('<a name="', fns, '">', 
                    if (show) paste0("<code>", fns, "</code>"), 
                    '</a>')
  paste(anchors, collapse=if (show) ", " else "")
}

citefn <- function(fn, text=paste0("`", fn, "`")) {
  paste0('<a href="#', fn, '">', text, '</a>')
}

writeIndex <- function(cols = 4) {
  documentedfns <- sort(documentedfns)
  entries <- paste0('<a href="#', documentedfns, '">', documentedfns, '</a>&nbsp;&nbsp;')
  len <- length(entries)
  rows <- len %/% cols
  extra <- len %% cols
  ofs <- c()
  for (i in seq_len(cols-1) - 1) 
    ofs <- c(ofs, rows + (extra > i))
  ofs <- cumsum(ofs)
  cat("\n------------- ")
  for (i in seq_len(cols-1))
    cat("| ------------")
  cat("\n")
  columns <- list(entries[1:rows])
  for (i in seq_len(cols-1)+1) 
    columns[[i]] <- entries[(ofs[i-1]+1):(ofs[i-1]+rows)]
  cat(do.call(paste, c(columns, sep = " | ")), sep="\n")  
  if (extra) {
    for (i in seq_len(extra))
      cat(entries[ofs[i]], ' | ')
    cat("&nbsp;")
  }
  cat("\n\n")
}
