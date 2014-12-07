
library(rgl)
options(rgl.useNULL=TRUE)

hook_webgl <- local({
  commonParts <- TRUE
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
                    commonParts = commonParts)
    if (!isTRUE(options$rgl.keepopen) && rgl.cur())
      rgl.close()
    commonParts <<- FALSE
    res <- readLines(name)
    res <- res[!grepl("^\\s*$", res)]
    paste(gsub("^\\s+", "", res), collapse = "\n")
  }
})

knitr::knit_hooks$set(rgl = hook_webgl)

documentedfns <- c()
indexfns <- function(fns, text = paste0("`", fns, "`"), show = TRUE) {
  documentedfns <<- c(documentedfns, fns)
  anchors <- paste0('<a name="', fns, '">', 
                    if (show) linkfn(fns, text, pkg = "rgl"), 
                    '</a>')
  paste(anchors, collapse=if (show) ", " else "")
}

linkfn <- function(fn, text = paste0("`", fn, "`"), pkg = NA) {
  if (is.na(pkg))
    paste0('<a href="#', fn, '">', text, '</a>')
  else
    paste0('<a href="../../', pkg, '/help/', fn, '">', text, 
           '</a>')
}

# Write this once at the start of the document.

cat('<style>
.nostripes tr.even {background-color: white;}
table {border-style: none;}
table th {border-style: none;}
table td {border-style: none;}
a[href^=".."] {text-decoration: underline;}
</style>
')  

writeIndex <- function(cols = 4) {
  documentedfns <- sort(documentedfns)
  entries <- paste0('<a href="#', documentedfns, '">', documentedfns, '</a>&nbsp;&nbsp;')
  len <- length(entries)
  padding <- ((len + cols - 1) %/% cols) * cols - len
  if (padding)
    entries <- c(entries, rep("", length.out=padding))
  cat('\n<div class="nostripes">\n')
  print(knitr::kable(matrix(entries, ncol=cols), format="pandoc"))
  cat("</div>\n")
}
