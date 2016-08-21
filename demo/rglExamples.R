Rmdname <- tempfile(fileext = ".Rmd")
Rmd <- file(Rmdname, open = "wt")
writeLines(
'---
title: "rgl Examples"
author: "Duncan Murdoch"
output: 
  html_document:
    toc: true
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
initialWd <- getwd()
options(rgl.useNULL = TRUE, rgl.printRglwidget = TRUE)
library(rgl)
```

This file shows all examples from every help file
in `rgl`.  Currently the large number of displays
overwhelms the system so most of them lose
interactivity (or worse); we are working on fixing that
to make the display of large documents more resilient.

', Rmd)

library(tools)
db <- Rd_db("rgl")
names <- names(db)

# These functions are taken from tools
.Rd_deparse <- function (x, tag = TRUE) 
{
    if (!tag) 
        attr(x, "Rd_tag") <- "Rd"
    paste(as.character(x), collapse = "")
}
.Rd_drop_nodes_with_tags <- function (x, tags) 
{
    recurse <- function(e) {
        if (is.list(e)) 
            structure(lapply(e[is.na(match(RdTags(e), tags))], 
                recurse), Rd_tag = attr(e, "Rd_tag"))
        else e
    }
    recurse(x)
}
.Rd_drop_comments <- function (x) 
.Rd_drop_nodes_with_tags(x, "COMMENT")

RdTags <- function (Rd) 
{
    res <- sapply(Rd, attr, "Rd_tag")
    if (!length(res)) 
        res <- character()
    res
}
.Rd_get_section <- function (x, which, predefined = TRUE) 
{
    if (predefined) 
        x <- x[RdTags(x) == paste0("\\", which)]
    else {
        x <- x[RdTags(x) == "\\section"]
        if (length(x)) {
            ind <- sapply(x, function(e) .Rd_get_text(e[[1L]])) == 
                which
            x <- lapply(x[ind], `[[`, 2L)
        }
    }
    if (!length(x)) 
        x
    else structure(x[[1L]], class = "Rd")
}
.Rd_get_example_code <- function (x) 
{
    x <- .Rd_get_section(x, "examples")
    if (!length(x)) 
        return(character())
    x <- .Rd_drop_comments(x)
    recurse <- function(e) {
        if (!is.null(tag <- attr(e, "Rd_tag")) && tag %in% c("\\dontshow", 
            "\\testonly")) 
            attr(e, "Rd_tag") <- "Rd"
        if (is.list(e)) {
            structure(lapply(e[is.na(match(RdTags(e), "\\dontrun"))], 
                recurse), Rd_tag = attr(e, "Rd_tag"))
        }
        else e
    }
    .Rd_deparse(recurse(x), tag = FALSE)
}

library(rgl)
options(rgl.useNULL = TRUE, rgl.printRglwidget = TRUE)
for (i in seq_along(db)) {
  writeLines('
```{r echo = FALSE}
while (length(rgl.dev.list()))
  rgl.close()
setwd(initialWd)
options(ask = FALSE, examples.ask = FALSE, device.ask.default = FALSE)
```', Rmd)
  cat("\n## ", names[i], "\n\n```{r ", names[i], "}", file = Rmd)
  writeLines(.Rd_get_example_code(db[[i]]), Rmd)
  writeLines('```', Rmd)
}
close(Rmd)
browseURL(rmarkdown::render(Rmdname))