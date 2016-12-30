dirname <- tempfile()
dir.create(dirname)
olddir <- setwd(dirname)

library(tools)
db <- Rd_db("rgl")
names <- names(db)
Rmdnames <- sub("[.]Rd$", ".Rmd", names)
htmlnames <- sub("[.]Rd$", ".html", names)

# These functions are based on similar ones from tools
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
        if (is.list(e)) {
            unlist(lapply(e[is.na(match(RdTags(e), c("\\donttest", "\\dontrun")))], 
                recurse))
        }
        else e
    }
    .Rd_deparse(recurse(x), tag = FALSE)
}
library(rgl)
options(rgl.useNULL = TRUE, rgl.printRglwidget = TRUE)
prevlink <- "[Prev](index.html)"
indexlink <- "[Index](index.html)"

for (i in seq_along(db)) {
  Rmd <- file(Rmdnames[i], open = "wt")
  nextlink <- if (i < length(htmlnames)) paste0("[Next](", htmlnames[i+1], ")") else ""
  writeLines(c('---', paste0('title: ', names[i]), 
'output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
initialWd <- getwd()
options(rgl.useNULL = TRUE, rgl.printRglwidget = TRUE)
library(rgl)
options(ask = FALSE, examples.ask = FALSE, device.ask.default = FALSE)
```
'), Rmd)
  writeLines(paste(prevlink, nextlink, indexlink), Rmd)
  writeLines('```{r}', Rmd)
  code <- .Rd_get_example_code(db[[i]])
  writeLines(code, Rmd)
  writeLines(
'```
```{r echo=FALSE,include=FALSE}
setwd(initialWd)
while(length(rgl.dev.list())) rgl.close()
```
', Rmd)
  writeLines(paste(prevlink, nextlink, indexlink), Rmd)
  close(Rmd)
  prevlink <- paste0("[Prev](", htmlnames[i], ")")
  rmarkdown::render(Rmdnames[i])
  while(length(rgl.dev.list())) rgl.close()
}

indexname <- "index.Rmd"
index <- file(indexname, open = "wt")
writeLines(
'---
title: "rgl Examples"
author: "Duncan Murdoch"
output: html_document
---
	
These files show all examples from every help file
in `rgl`.  

', index)
writeLines(paste0("[", names, "](", htmlnames, ")  "), index)
close(index)

browseURL(rmarkdown::render(indexname))
setwd(olddir)
