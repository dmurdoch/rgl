
in_litedown <- function() 
  isNamespaceLoaded("litedown") && isTRUE(litedown::reactor("rgl.inLitedown"))

fns <- local({
  saveopts <- NULL
  plotnum <- 0
  setupDone <- NULL
  latex <- FALSE
  previd <- "None"
  
  counter <- 0L
  
  rgl_counter <- function() {
    counter <<- counter + 1L
    counter
  }
  
  litedownNeedsSnapshot <- function(options){
    litedown::get_context("format") != "html"
  }
  
  setupLitedown <- function(autoprint = FALSE) {
    if (!requireNamespace("litedown"))
      return()
    
    s3_register("xfun::record_print", "rglOpen3d")
    s3_register("xfun::record_print", "rglId")
    
    litedown::reactor(rgl.inLitedown = TRUE)

    # R produces multiple vignettes in the same session.
    # Watch out for leftovers
    
    if (!is.null(setupDone)) {
      options(saveopts)
      saveopts <<- NULL
      counter <<- 0L
    }
    
    setupDone <<- list(autoprint = autoprint)
    
    litedown::reactor(rgl.chunk = TRUE)
    
    latex <<- identical(litedown::get_context("format"), "latex")
    if (autoprint)
      saveopts <<- litedown::reactor(rgl.printRglwidget = TRUE)
  }  
  
  record_print.rglOpen3d <- function(x, ...) {
    print(x, ...)
    if (isTRUE(litedown::reactor("rgl.printRglwidget"))) {
      plotnum <<- plotnum + 1
    }
    invisible(x)
  }

  record_print.rglId <- function(x, ...) {
    if (!isTRUE(litedown::reactor("rgl.printRglwidget")) || par3d("skipRedraw"))	
      invisible("")
    options <- litedown::reactor()
    scene <- scene3d()
    args <- list(...)
    if (inherits(x, "rglHighlevel"))
      plotnum <<- plotnum + 1
    
    recorded <- structure(list(plotnum = plotnum,
                     scene = scene,
                     options = options),
                class = c("rglRecordedplot", "knit_other_plot"))

    doSnapshot <- litedownNeedsSnapshot(options)
    margin <- options$rgl.margin
    if (is.null(margin))
      margin <- 100
    content <- suppressMessages(rglwidget(scene,
                         width = figWidth() + margin,
                         height = figHeight(),
                         webgl = !doSnapshot))
    if (inherits(content, "knit_image_paths")) {
      # # We've done a snapshot, put it in the right place.
      name <- fig_path("-rgl.png", options, rgl_counter())
      if (!file_test("-d", dirname(name)))
        dir.create(dirname(name), recursive = TRUE)
      file.copy(content, name, overwrite = TRUE)
      unlink(content)
      alt <- options$fig.alt
      if (is.null(alt))
        alt <- options$fig.cap
      if (is.null(alt))
        alt <- ""
      xfun::new_record(sprintf("![%s](%s)", alt, name), "asis")
    } else {
      id <- content$elementId
      fig.align <- options$fig.align
      if (length(fig.align) ==  1 && fig.align != "default")
        content <- prependContent(content,
                                  tags$style(sprintf(
                                    "#%s {%s}",
                                    content$elementId,
                                    switch(fig.align,
                                           center = "margin:auto;",
                                           left   = "margin-left:0;margin-right:auto;",
                                           right  = "margin-left:auto;margin-right:0;",
                                           ""))))
      result <- do.call(xfun::record_print, c(list(x = content, options = options), args))
      if (!latex) {
        meta <- litedown::reactor("meta")
        rgldata <- meta$"header-includes"
        if (is.null(rgldata))
          rgldata <- character()
        if (inherits(x, "rglLowlevel")) {
          rgldata[previd] <- sprintf('<script type="application/json" data-for="%s">{"x":[],"evals":[],"jsHooks":[]}</script>', previd)
        }
        # FIXME:  this isn't the right way to do this...
        regexp <- "^<!--html_preserve-->(<p id.*></div>)\n(<script.*</script>)<!--/html_preserve-->$"
        insert <- sub(regexp, "\\1", result)
        data <- sub(regexp, "\\2", result)
        
        rgldata <- c(rgldata, data)
        names(rgldata)[length(rgldata)] <- id
        previd <<- id
      }
      
      meta$"header-includes" <- rgldata
      litedown::reactor(meta = meta)
      
      xfun::new_record(insert, "asis")
    }
  }
  
  list(
    setupLitedown = setupLitedown,
    record_print.rglOpen3d = record_print.rglOpen3d,
    record_print.rglId = record_print.rglId)
})

setupLitedown <- fns[["setupLitedown"]]
record_print.rglId <- fns[["record_print.rglId"]]
record_print.rglOpen3d <- fns[["record_print.rglOpen3d"]]

rm(fns)
