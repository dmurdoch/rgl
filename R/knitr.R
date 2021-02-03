
##
## knitr hook functions
##
##

## Note:  Up to knitr version 1.30 (or higher?), the is_low_change
##  and wrap() functions weren't exported as generics, so
##  rgl had to do all sorts of messing around with knitr 
##  internals to get things to work.  This code is used
##  only when oldKnitrVersion() evaluates to TRUE.
##  Once rgl is willing to depend on a knitr release that
##  includes those exports, lots of code can be deleted.

oldKnitrVersion <- function() 
  !all(c("wrap", "is_low_change") %in% getNamespaceExports("knitr"))

# This is only needed for old knitr:
globalVariables("wrap")

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
    rgl.snapshot(paste0(name, ".png"), fmt = "png")
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
  
  # These are only used with old knitr
  
  oldopthooks <- NULL
  oldevalhook <- function(...) NULL
  
  fig.keep <- NULL
  fig.show <- NULL
  fig.beforecode <- NULL
  
  # end of old knitr version dependency
  
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
        if (oldKnitrVersion()) {
          knit_hooks$set( evaluate = oldevalhook)
          oldevalhook <<- NULL
          oldopthooks <<- opts_hooks$get(c("fig.keep", "fig.show", "fig.beforecode"))
          opts_hooks$set(fig.keep = oldopthooks[["fig.keep"]],
                         fig.show = oldopthooks[["fig.show"]],
                         fig.beforecode = oldopthooks[["fig.beforecode"]])
          oldopthooks <<- NULL
        }
      }
    }
    if (!oldKnitrVersion()) {
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
    }
    setupDone <<- list(autoprint = autoprint,
                       rgl.newwindow = rgl.newwindow,
                       rgl.closewindows = rgl.closewindows)
    
    # R produces multiple vignettes in the same session.
    environment(rglwidget)$reuseDF <- NULL
    knitr::opts_chunk$set(rgl.newwindow = rgl.newwindow, 
                          rgl.closewindows = rgl.closewindows,
                          rgl.chunk = TRUE)
    
    knit_hooks$set(webgl = hook_webgl)
    knit_hooks$set(webGL = hook_webgl)
    knit_hooks$set(rgl = hook_rgl)
    knit_hooks$set(rgl.chunk = hook_rglchunk)
    latex <<- identical(opts_knit$get("out.format"), "latex") || identical(opts_knit$get("rmarkdown.pandoc.to"), "latex")
    if (autoprint) {
      saveopts <<- options(rgl.printRglwidget = TRUE, rgl.useNULL = !latex)
      if (oldKnitrVersion()) {
        oldevalhook <<- knit_hooks$get("evaluate")
        knit_hooks$set( evaluate = hook_evaluate)
        oldopthooks <<- opts_hooks$get(c("fig.keep", "fig.show", "fig.beforecode"))
        opts_hooks$set(fig.keep = hook_figkeep,
                       fig.show = hook_figshow,
                       fig.beforecode = hook_figbeforecode)
      }
    }
  }  
  
  knit_print.rglOpen3d <- function(x, options, ...) {
    print(x, ...)
    if (getOption("rgl.printRglwidget", FALSE)) {
      plotnum <<- plotnum + 1
    }
    invisible(x)
  }
  
  knit_print.rglId <- function(x, options, ...) {
    if (getOption("rgl.printRglwidget", FALSE))	{
      scene <- scene3d()
      args <- list(...)
      if (inherits(x, "rglHighlevel"))
        plotnum <<- plotnum + 1
      structure(list(plotnum = plotnum,
                     scene = scene,
                     width = figWidth(),
                     height = figHeight(),
                     options = options, args = args),
                class = "rglRecordedplot")
    } else
      invisible(x)
  }
  
  ## These definitions are only used with old knitr
  {
    find_figs <- function(res, classes = c("recordedplot",
                                           "rglRecordedplot",
                                           "knit_image_paths"))
      vapply(res, function(x) {
        cl <- class(x)
        length(intersect(cl, classes)) > 0
      }, logical(1))
    
    # move plots before source code
    fig_before_code <- function(x) {
      s <- vapply(x, evaluate::is.source, logical(1))
      if (length(s) == 0 || !any(s)) return(x)
      s <- which(s)
      f <- which(find_figs(x))
      f <- f[f >= min(s)]  # only move those plots after the first code block
      for (i in f) {
        j <- max(s[s < i])
        tmp <- x[i]; x[[i]] <- NULL; x <- append(x, tmp, j - 1)
        s <- which(vapply(x, evaluate::is.source, logical(1)))
      }
      x
    }
    
    hook_evaluate <- function(...) {
      counter <<- 0L
      res <- oldevalhook(...)
      keep <- fig.keep
      keep.idx <- NULL
      if (is.logical(keep)) keep <- which(keep)
      if (is.numeric(keep)) {
        keep.idx <- keep
        keep <- "index"
      }
      # rearrange locations of figures
      figs <- find_figs(res)
      if (length(figs) && any(figs)) {
        if (keep == 'none') {
          res <- res[!figs] # remove all
        } else {
          if (fig.show == 'hold') {
            res <- c(res[!figs], res[figs]) # move to the end
            figs <- find_figs(res)
          }
          if (length(figs) && sum(figs) > 1) {
            if (keep %in% c('first', 'last')) {
              res <- res[-(if (keep == 'last') head else tail)(which(figs), -1L)]
            } else {
              # keep only selected
              if (keep == 'index') res <- res[-which(figs)[-keep.idx]]
              # merge low-level plotting changes
              if (keep == 'high') res <- merge_low_plot(res, figs)
            }
          }
        }
        if (isTRUE(fig.beforecode)) 
          res <- fig_before_code(res)
        # Now replace the rgl figs with their code.
        figs <- which(find_figs(res, "rglRecordedplot"))
        for (f in figs) {
          obj <- res[[f]]
          options <- obj$options
          scene <- obj$scene
          doSnapshot <- knitrNeedsSnapshot(options)
          content <- rglwidget(scene,
                               width = obj$width,
                               height = obj$height,
                               reuse = TRUE,
                               snapshot = doSnapshot)
          if (inherits(content, "knit_image_paths")) {
            # # We've done a snapshot, put it in the right place.
            name <- file.path(options$fig.path, 
                              paste0(options$label, "-rgl-", rgl_counter(), ".png"))
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
          res[[f]] <- do.call("knit_print", c(list(content, options), obj$args))
          if (!latex) 
            class(res[[f]]) <- c(class(res[[f]]), "knit_asis_htmlwidget")
        }
      }
      # Finally, clear the scenes for the next chunk
      plotnum <<- 0
      res
    }
    
    hook_figkeep <- function(options) {
      if (!is.null(hook <- oldopthooks$fig.keep))
        options <- hook(options)
      fig.keep <<- options$fig.keep
      options$fig.keep <- "all"
      options
    }
    
    hook_figshow <- function(options) {
      if (!is.null(hook <- oldopthooks$fig.show))
        options <- hook(options)
      fig.show <<- options$fig.show
      options$fig.show <- "asis"
      options
    }
    
    hook_figbeforecode <- function(options) {
      if (!is.null(hook <- oldopthooks$fig.beforecode))
        options <- hook(options)
      fig.beforecode <<- options$fig.beforecode
      options$fig.beforecode <- FALSE
      options
    }
    
    # These functions are closely based on code from knitr:
    
    # compare two recorded plots
    # Name in knitr is is_low_change; we don't want to conflict
    # so we rename to is_low_change_rgl, but only call this
    # in old knitr.
    
    is_low_change_rgl <- function(p1, p2) {
      p1 <- p1[[1]]; p2 <- p2[[1]]  # real plot info is in [[1]],
      # as is plotnum
      if (length(p2) < (n1 <- length(p1))) return(FALSE)  # length must increase
      identical(p1[1:n1], p2[1:n1])
    }
    
    merge_low_plot <- function(x, idx) {
      idx <- which(idx); n <- length(idx); m <- NULL # store indices that will be removed
      if (n <= 1) return(x)
      i1 <- idx[1]; i2 <- idx[2]  # compare plots sequentially
      for (i in 1:(n - 1)) {
        # remove the previous plot and move its index to the next plot
        if (is_low_change_rgl(x[[i1]], x[[i2]])) m <- c(m, i1)
        i1 <- idx[i + 1]
        i2 <- idx[i + 2]
      }
      if (is.null(m)) x else x[-m]
    }
  }
  ## End of old knitr specifics
    
    wrap.rglRecordedplot <- function(x, options = list(), ...)  {
      latex <- identical(opts_knit$get("out.format"), "latex") || identical(opts_knit$get("rmarkdown.pandoc.to"), "latex")
      scene <- x$scene
      doSnapshot <- latex || isTRUE(options$snapshot)
      content <- rglwidget(scene,
                           width = x$width,
                           height = x$height,
                           reuse = TRUE,
                           webgl = !doSnapshot,
                           latex = latex)
      if (inherits(content, "knit_image_paths")) {
        # # We've done a snapshot, put it in the right place.
        name <- file.path(options$fig.path,
                          paste0(options$label, "-rgl-", rgl_counter(), ".png"))
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
      
      wrap(result, options)
    }
    
    list(
      # These are for old knitr only:
      hook_evaluate = hook_evaluate,
      hook_figkeep = hook_figkeep,
      hook_figshow = hook_figshow,
      hook_figbeforecode = hook_figbeforecode,
      # end of old knitr specifics
      
      setupKnitr = setupKnitr,
      knit_print.rglOpen3d = knit_print.rglOpen3d,
      knit_print.rglId = knit_print.rglId,
      wrap.rglRecordedplot = wrap.rglRecordedplot)
  
})

setupKnitr <- fns[["setupKnitr"]]
knit_print.rglId <- fns[["knit_print.rglId"]]
knit_print.rglOpen3d <- fns[["knit_print.rglOpen3d"]]
# old knitr specifics
{
  hook_evaluate <- fns[["hook_evaluate"]]
  hook_figkeep <- fns[["hook_figkeep"]]
  hook_figshow <- fns[["hook_figshow"]]
  hook_figbeforecode <- fns[["hook_figbeforecode"]]
}
# End of old knitr specifics
wrap.rglRecordedplot <- fns[["wrap.rglRecordedplot"]]

rm(fns)

is_low_change.rglRecordedplot <- function(p1, p2) {
  inherits(p2, "rglRecordedplot") && p1$plotnum == p2$plotnum
}

figWidth <- function()
  if (length(result <- with(opts_current$get(c("fig.width", "dpi", "fig.retina")),
	     fig.width*dpi/fig.retina))) result[1] else NULL
  

figHeight <- function() 
  if (length(result <- with(opts_current$get(c("fig.height", "dpi", "fig.retina")),
	     fig.height*dpi/fig.retina))) result[1] else NULL
