options(rgl.useNULL=FALSE)
suppressPackageStartupMessages(library(rgl))
options(rgl.useNULL=TRUE)
options(rgl.printRglwidget=FALSE)
open3d()

if (!requireNamespace("rmarkdown", quietly = TRUE) ||
    !rmarkdown::pandoc_available("1.14")) {
  warning(call. = FALSE, "These vignettes assume rmarkdown and Pandoc
          version 1.14.  These were not found. Older versions will not work.")
  knitr::knit_exit()
}


# If Pandoc is not installed, the output format won't be set.
# knitr uses it to determine whether to do
# screenshots; we don't want those. see https://github.com/rstudio/markdown/issues/115

knitr::opts_chunk$set(screenshot.force = FALSE, snapshot = FALSE)
  
# knitr::opts_chunk$set(snapshot = TRUE)  # for snapshots instead of dynamic

documentedfns <- c()
deprecatedfns <- c()

backticked <- function(s) paste0("`", s, "`")

indexfns <- function(fns, text = backticked(fns), show = TRUE, pkg = "rgl") {
  documentedfns <<- c(documentedfns, fns)
  anchors <- paste0('<a name="', fns, '">',
                    if (show) linkfn(fns, text, pkg = pkg),
                    '</a>')
  paste(anchors, collapse=if (show) ", " else "")
}

deprecated <- function(fns, text = backticked(fns), show = TRUE, pkg = "rgl") {
  deprecatedfns <<- c(deprecatedfns, fns)
  if (show)
    paste(text, collapse = ", ")
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
    text <- rep_len(text, length(fn))
    url <- rep_len(NA, length(fn))
    for (i in seq_along(fn)) {
      if (pkg == "rgl") {
        rdpath <- Sys.getenv("VignetteRdPath", unset = "../html/")
        url[i] <- paste0(rdpath, basename(help(fn[i])), ".html")
      } else if (requireNamespace("downlit", quietly = TRUE))
        url[i] <- downlit::autolink_url(paste0(pkg, "::", fn[i]))
      if (is.na(url[i]))
        url[i] <- paste0('../../', pkg, '/help/', fn[i], ".html")
    }
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

# This sets up default "alt text" for screen readers.

defaultAltText <- function() {
  paste(knitr::opts_current$get("label"), "example.")
}

knitr::opts_chunk$set(fig.alt = quote(defaultAltText()))
