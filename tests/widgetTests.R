# Test inclusion of rgl scenes

if (!requireNamespace("rmarkdown") || !rmarkdown::pandoc_available("1.14")) {
  stop("Need R Markdown and Pandoc")
}

textEqual <- function(f1, f2) {
  f1 <- Sys.glob(f1)
  f2 <- Sys.glob(f2)
  stopifnot(numfiles = length(f1) == length(f2),
            filesexist = file.exists(f1, f2),
            contentmatches = mapply(function(f1, f2)
                     identical(readLines(f1), readLines(f2)),
                   f1, f2)
  )
}

binEqual <- function(f1, f2) {
  f1 <- Sys.glob(f1)
  f2 <- Sys.glob(f2)
  stopifnot(numfiles = length(f1) == length(f2),
            filesexist = file.exists(f1, f2),
            contentmatches = mapply(function(f1, f2)
                     tools::md5sum(f1) == tools::md5sum(f2),
                   f1, f2)
  )
}

f0 <- "README.Rmd"
file.copy(file.path("..", f0), tempdir(), overwrite = TRUE)
f1 <- file.path(tempdir(), f0)
rmarkdown::render(f1)
textEqual("../README.md", 
          file.path(tempdir(), "README.md")
          )
binEqual("../man/figures/README/*",
         file.path(tempdir(), "man/figures/README/*")
         )
