options(rgl.useNULL=FALSE)
suppressPackageStartupMessages(library(rgl))
options(rgl.useNULL=TRUE)
options(rgl.printRglwidget=FALSE)

if (!requireNamespace("rmarkdown") || !rmarkdown::pandoc_available("1.14")) {
  warning(call. = FALSE, "These vignettes assume rmarkdown and pandoc version 1.14.  These were not found. Older versions will not work.")
  knitr::knit_exit()
}

# knitr::opts_chunk$set(snapshot = TRUE)  # for snapshots instead of dynamic

documentedfns <- c()

backticked <- function(s) paste0("`", s, "`")

indexfns <- function(fns, text = backticked(fns), show = TRUE, pkg = "rgl") {
  documentedfns <<- c(documentedfns, fns)
  anchors <- paste0('<a name="', fns, '">',
                    if (show) linkfn(fns, text, pkg = pkg),
                    '</a>')
  paste(anchors, collapse=if (show) ", " else "")
}

indexclass <-
  indexproperties <- function(fns, text = backticked(fns), show = TRUE) {
    documentedfns <<- c(documentedfns, fns)
    anchors <- paste0('<a name="', fns, '">',
                      if (show) text,
                      '</a>')
    paste(anchors, collapse=if (show) ", " else "")
  }

indexmethods <- function(fns, text = backticked(paste0(fns, "()")), show = TRUE) {
  documentedfns <<- c(documentedfns, fns)
  anchors <- paste0('<a name="', fns, '">',
                    if (show) text,
                    '</a>')
  paste(anchors, collapse=if (show) ", " else "")
}

linkfn <- function(fn, text = backticked(fn), pkg = NA) {
  if (is.na(pkg))
    paste0('<a href="#', fn, '">', text, '</a>')
  else {
    if (requireNamespace("downlit"))
      url <- downlit::autolink_url(paste0(pkg, "::", fn))
    else
      url <- NA
    if (is.na(url))
      url <- paste0('../../', pkg, '/help/', fn)

    paste0('<a href="', url, '">', text, '</a>')
  }
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
  if (!is.null(documentedfns)) {
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
}

# This displays the string code as `r code` when entered
# as `r rinline(code)`.  Due to Stephane Laurent
rinline <- function(code, script = FALSE){
  if (script)
    html <- "`r CODE`"
  else
    html <- '<code  class="r">``` `r CODE` ```</code>'
  sub("CODE", code, html)
}
