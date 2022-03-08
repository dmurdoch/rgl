in_knitr <- function()
  isTRUE(getOption("knitr.in.progress"))

##
## knitr hook functions
##
##

fns <- local({
  newwindowdone <- FALSE
  closewindowsdone <- FALSE
  do_newwindow <- function(options) {
    if (!newwindowdone) {
      newwindow <- options$rgl.newwindow
      if (!is.null(newwindow) && newwindow)
        open3d()
      if (!is.null(options$rgl.keepopen))
        warning("rgl.keepopen has been replaced by rgl.newwindow")
      newwindowdone <<- TRUE
      closewindowsdone <<- FALSE
    }
  }
  do_closewindows <- function(options) {
    if (!closewindowsdone) {
      closewindows <- options$rgl.closewindows
      if (!is.null(closewindows) && closewindows)
        while (cur3d())
          close3d()
      newwindowdone <<- FALSE
      closewindowsdone <<- TRUE
    }
  }
  list(do_newwindow = do_newwindow,
       do_closewindows = do_closewindows)
})

do_newwindow <- fns[["do_newwindow"]]
do_closewindows <- fns[["do_closewindows"]]
rm(fns)

hook_webgl <- function(before, options, envir) {
  if (before) {
    do_newwindow(options)
    return()
  }
  res <- if (cur3d() != 0) {
    out_type <- opts_knit$get("out.format")
    if (!length(intersect(out_type, c("markdown", "html"))))
      stop("'hook_webgl' is for HTML only. ",
           "Use 'hook_rgl' instead, or 'setupKnitr(autoprint = TRUE)'.")
    knit_print(rglwidget(), options = options)
  }
  do_closewindows(options)
  m <- attr(res, 'knit_meta')
  knit_meta_add(m, if (missing(options)) '' else options$label)
  res
}

hook_rgl <- function(before, options, envir) {
  if (before) {
    do_newwindow(options)
    return()
  }
  res <- if (cur3d() != 0) {
    name <- fig_path("", options)
    margin <- options$rgl.margin
    if (is.null(margin)) margin <- 100
    par3d(windowRect = margin + options$dpi * 
                                c(0, 0, options$fig.width, options$fig.height))
    Sys.sleep(.05) # need time to respond to window size change

    dir <- knitr::opts_knit$get("base_dir")
    if (is.character(dir)) {
      if (!file_test("-d", dir)) dir.create(dir, recursive = TRUE)
      owd <- setwd(dir)
      on.exit(setwd(owd))
    }
    save_rgl(name, options$dev)
    options$fig.num <- 1L  # only one figure in total
    options$dev <- "png"
    hook_plot_custom(before, options, envir)
  }
  do_closewindows(options)
  res
}

hook_rglchunk <- function(before, options, envir) {
  if (before)
    do_newwindow(options)
  else if (is.null(options$webgl) && is.null(options$rgl))
    do_closewindows(options)
}

save_rgl <- function(name, devices) {
  if (!file_test("-d", dirname(name))) 
    dir.create(dirname(name), recursive = TRUE)
  # support 3 formats: eps, pdf and png (default)
  for (dev in devices) switch(
    dev,
    eps = ,
    postscript = rgl.postscript(paste0(name, ".eps"), fmt = "eps"),
    pdf = rgl.postscript(paste0(name, '.pdf'), fmt = "pdf"),
    snapshot3d(paste0(name, ".png"))
  )
}


# This code is mostly taken from Shiny, which has lots of authors:  see
# https://github.com/rstudio/shiny/blob/master/R/utils.R

# Evaluate an expression using our own private stream of
# randomness (not affected by set.seed).
withPrivateSeed <- local({

  ownSeed <- NULL

  function(expr) {
    # Save the old seed if present.
    if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      hasOrigSeed <- TRUE
      origSeed <- .GlobalEnv$.Random.seed
    } else {
      hasOrigSeed <- FALSE
    }

    # Swap in the private seed.
    if (is.null(ownSeed)) {
      if (hasOrigSeed) {
        # Move old seed out of the way if present.
        rm(.Random.seed, envir = .GlobalEnv, inherits = FALSE)
      }
    } else {
      .GlobalEnv$.Random.seed <- ownSeed
    }

    # On exit, save the modified private seed, and put the old seed back.
    on.exit({
      ownSeed <<- .GlobalEnv$.Random.seed

      if (hasOrigSeed) {
        .GlobalEnv$.Random.seed <- origSeed
      } else {
        rm(.Random.seed, envir = .GlobalEnv, inherits = FALSE)
      }
      # Shiny had this workaround.  I think we don't need it, and have
      # commented it out.
      # Need to call this to make sure that the value of .Random.seed gets put
      # into R's internal RNG state. (Issue #1763)

      # httpuv::getRNGState() # nolint
    })
    
    expr
  }
})

# Version of sample that runs with private seed
p_sample <- function(...) {
  withPrivateSeed(sample(...))
}

fns <- local({
  saveopts <- NULL
  plotnum <- 0
  setupDone <- NULL
  latex <- FALSE
  
  counter <- 0L
  rgl_counter <- function() {
    counter <<- counter + 1L
    counter
  }
  
  setupKnitr <- function(autoprint = FALSE, 
                         rgl.newwindow = autoprint,
                         rgl.closewindows = autoprint) {
    if (!is.null(setupDone)) {
      if (setupDone$autoprint) {
        message("undoing setup")
        options(saveopts)
        saveopts <<- NULL
        setupDone <<- NULL
      }
    }

      if (!is.null(setupDone)) {
        if (setupDone$autoprint != autoprint ||
            setupDone$rgl.newwindow != rgl.newwindow ||
            setupDone$rgl.closewindows != rgl.closewindows) {
          warning("Already set autoprint = ", setupDone$autoprint,
                  ", rgl.newwindow = ", setupDone$rgl.newwindow,
                  ", rgl.closewindows = ", setupDone$rgl.closewindows)
        }
        return()
      }
      counter <<- 0L

    setupDone <<- list(autoprint = autoprint,
                       rgl.newwindow = rgl.newwindow,
                       rgl.closewindows = rgl.closewindows)
    
    # R produces multiple vignettes in the same session.
    knitr::opts_chunk$set(rgl.newwindow = rgl.newwindow, 
                          rgl.closewindows = rgl.closewindows,
                          rgl.chunk = TRUE)
    
    knit_hooks$set(webgl = hook_webgl)
    knit_hooks$set(webGL = hook_webgl)
    knit_hooks$set(rgl = hook_rgl)
    knit_hooks$set(rgl.chunk = hook_rglchunk)
    latex <<- identical(opts_knit$get("out.format"), "latex") || identical(opts_knit$get("rmarkdown.pandoc.to"), "latex")
    if (autoprint)
      saveopts <<- options(rgl.printRglwidget = TRUE)
  }  
  
  knit_print.rglOpen3d <- function(x, options, ...) {
    print(x, ...)
    if (getOption("rgl.printRglwidget", FALSE)) {
      plotnum <<- plotnum + 1
    }
    invisible(x)
  }
  
  knit_print.rglId <- function(x, options, ...) {
    if (getOption("rgl.printRglwidget", FALSE) && !par3d("skipRedraw"))	{
      scene <- scene3d()
      args <- list(...)
      if (inherits(x, "rglHighlevel"))
        plotnum <<- plotnum + 1
      structure(list(plotnum = plotnum,
                     scene = scene,
                     width = figWidth(),
                     height = figHeight(),
                     options = options, args = args),
                class = c("rglRecordedplot", "knit_other_plot"))
    } else
      invisible(x)
  }
    
    sew.rglRecordedplot <- function(x, options = list(), ...)  {
      latex <- identical(opts_knit$get("out.format"), "latex") || identical(opts_knit$get("rmarkdown.pandoc.to"), "latex")
      scene <- x$scene
      doSnapshot <- knitrNeedsSnapshot(options)
      content <- rglwidget(scene,
                           width = x$width,
                           height = x$height,
                           webgl = !doSnapshot)
      if (inherits(content, "knit_image_paths")) {
        # # We've done a snapshot, put it in the right place.
        name <- fig_path("-rgl.png", options, rgl_counter())
        if (!file_test("-d", dirname(name)))
          dir.create(dirname(name), recursive = TRUE)
        file.copy(content, name, overwrite = TRUE)
        unlink(content)
        content <- structure(list(file = name,
                                  extension = "png"),
                             class = "html_screenshot")
      }
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
      result <- do.call("knit_print", c(list(content, options), x$args))
      if (!latex)
        class(result) <- c(class(result), "knit_asis_htmlwidget")
      
      sew(result, options)
    }
    
    list(
      setupKnitr = setupKnitr,
      knit_print.rglOpen3d = knit_print.rglOpen3d,
      knit_print.rglId = knit_print.rglId,
      sew.rglRecordedplot = sew.rglRecordedplot)
})

setupKnitr <- fns[["setupKnitr"]]
knit_print.rglId <- fns[["knit_print.rglId"]]
knit_print.rglOpen3d <- fns[["knit_print.rglOpen3d"]]
sew.rglRecordedplot <- fns[["sew.rglRecordedplot"]]

rm(fns)

is_low_change.rglRecordedplot <- function(p1, p2) {
  inherits(p2, "rglRecordedplot") && p1$plotnum == p2$plotnum
}

figWidth <- function() {
  if (in_pkgdown_example())
    return(pkgdown_dims()$width)
  else if (in_knitr())
    opts <- opts_current$get(c("fig.width", "dpi", "fig.retina"))
  else
    opts <- NULL
  if (length(opts)) {
    result <- with(opts, fig.width*dpi/fig.retina)
    result[1] 
  } else NULL
}

figHeight <- function() {
  if (in_pkgdown_example())
    return(pkgdown_dims()$height)
  else if (in_knitr())
    opts <- opts_current$get(c("fig.height", "dpi", "fig.retina"))
  else
    opts <- NULL
  if (length(opts)) {
    result <- with(opts, fig.height*dpi/fig.retina)
    result[1] 
  } else NULL
}
