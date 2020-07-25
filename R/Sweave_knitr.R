

##
## Sweave device
##
##

rgl.Sweave <- function(name, width, height, options, ...) {
  if (length(hook <- getHook("on.rgl.close"))) {
    # test is for compatibility with R < 3.0.0
    if (is.list(hook)) hook <- hook[[1]]  
    dev <- environment(hook)$dev
    set3d(dev)
  } else {
    wr <- c(0, 0, width*options$resolution, height*options$resolution)
    open3d(windowRect=wr)
    if (is.null(delay <- options$delay)) delay <- 0.1
    Sys.sleep(as.numeric(delay))
    wrnew <- par3d("windowRect")
    if (wr[3] - wr[1] != wrnew[3] - wrnew[1] ||
        wr[4] - wr[2] != wrnew[4] - wrnew[2])
      stop("rgl window creation error; try reducing resolution, width or height")
    dev <- cur3d()
  } 

  snapshotDone <- FALSE

  stayOpen <- isTRUE(options$stayopen)

  type <- options$outputtype
  if (is.null(type)) type <- "png"

  setHook("on.rgl.close", action="replace", function(remove=TRUE) {
    prev.dev <- cur3d()
    on.exit(set3d(prev.dev))

    if (!snapshotDone) {
      set3d(dev)
      switch(type,
        png = rgl.snapshot(filename=paste(name, "png", sep=".")),
        pdf = rgl.postscript(filename=paste(name, "pdf", sep="."), fmt="pdf"),
        eps = rgl.postscript(filename=paste(name, "eps", sep="."), fmt="eps"),
        stop(gettextf("Unrecognized rgl outputtype: '%s'", type), domain = NA)
      )
      snapshotDone <<- TRUE
    }

    if (remove)
      setHook("on.rgl.close", action="replace", NULL)
  })
}

rgl.Sweave.off <- function() {
  if (length(hook <- getHook("on.rgl.close"))) {
    if (is.list(hook)) hook <- hook[[1]] # test is for R pre-3.0.0 compatibility
    stayOpen <- environment(hook)$stayOpen
    if (stayOpen) hook(FALSE)
    else close3d()
  }
}
  
##
## Sweave snapshot
##
##

Sweave.snapshot <- function() {
  if (length(hook <- getHook("on.rgl.close"))) {
    if (is.list(hook)) hook <- hook[[1]] # test is for R pre-3.0.0 compatibility
    hook(remove = FALSE)
  }
}

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

      # httpuv::getRNGState()
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
  oldopthooks <- NULL
  oldevalhook <- function(...) NULL
  
  plotnum <- 0
  
  fig.keep <- NULL
  fig.show <- NULL
  fig.beforecode <- NULL
  
  setupKnitr <- function(autoprint = FALSE, 
                         rgl.newwindow = autoprint,
                         rgl.closewindows = autoprint) {
    # R produces multiple vignettes in the same session.
    environment(rglwidget)$reuseDF <- NULL
    knitr::opts_chunk$set(rgl.newwindow = rgl.newwindow, 
                          rgl.closewindows = rgl.closewindows,
                          rgl.chunk = TRUE)

      knit_hooks$set(webgl = hook_webgl)
      knit_hooks$set(webGL = hook_webgl)
      knit_hooks$set(rgl = hook_rgl)
      knit_hooks$set(rgl.chunk = hook_rglchunk)
      
      if (autoprint) {
        saveopts <<- options(rgl.printRglwidget = TRUE, rgl.useNULL = TRUE)
        oldevalhook <<- knit_hooks$get("evaluate")
        knit_hooks$set( evaluate = hook_evaluate)
        oldopthooks <<- opts_hooks$get(c("fig.keep", "fig.show", "fig.beforecode"))
        opts_hooks$set(fig.keep = hook_figkeep,
                       fig.show = hook_figshow,
                       fig.beforecode = hook_figbeforecode
                       )
      }
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
  
  find_figs <- function(res, classes = c("recordedplot",
                                         "rglRecordedplot",
                                         "knit_image_paths"))
    vapply(res, function(x) {
      cl <- class(x)
      length(intersect(cl, classes)) > 0
    }, logical(1))
  
  # move plots before source code
  fig_before_code = function(x) {
    s = vapply(x, evaluate::is.source, logical(1))
    if (length(s) == 0 || !any(s)) return(x)
    s = which(s)
    f = which(find_figs(x))
    f = f[f >= min(s)]  # only move those plots after the first code block
    for (i in f) {
      j = max(s[s < i])
      tmp = x[i]; x[[i]] = NULL; x = append(x, tmp, j - 1)
      s = which(vapply(x, evaluate::is.source, logical(1)))
    }
    x
  }
  
  hook_evaluate <- function(...) {
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
      snapshot <- identical(opts_knit$get("rmarkdown.pandoc.to"), "latex")
      for (f in figs) {
        obj <- res[[f]]
        options <- obj$options
        scene <- obj$scene
        if (snapshot) {
          filename <- tempfile(fileext = ".png")
          snapshot3d(filename, scene = scene)
          content <- include_graphics(filename)
          if (is.null(options$out.width))
            options$out.width <- with(options, paste0(out.width.px, "px"))
          if (is.null(options$out.height))
            options$out.height <- with(options, paste0(out.height.px, "px"))
        } else {
          content <- rglwidget(scene,
                               width = obj$width,
                               height = obj$height,
                               reuse = TRUE)
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
        }
        res[[f]] <- do.call("knit_print", c(list(content, options), obj$args))
        if (!snapshot) 
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
  is_low_change = function(p1, p2) {
    p1 = p1[[1]]; p2 = p2[[1]]  # real plot info is in [[1]],
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
      if (is_low_change(x[[i1]], x[[i2]])) m = c(m, i1)
      i1 = idx[i + 1]
      i2 = idx[i + 2]
    }
    if (is.null(m)) x else x[-m]
  }
  
  list(setupKnitr = setupKnitr,
       hook_evaluate = hook_evaluate,
       hook_figkeep = hook_figkeep,
       hook_figshow = hook_figshow,
       hook_figbeforecode = hook_figbeforecode,
       knit_print.rglId = knit_print.rglId)
})

setupKnitr <- fns[["setupKnitr"]]
hook_evaluate <- fns[["hook_evaluate"]]
hook_figkeep <- fns[["hook_figkeep"]]
hook_figshow <- fns[["hook_figshow"]]
hook_figbeforecode <- fns[["hook_figbeforecode"]]
knit_print.rglId <- fns[["knit_print.rglId"]]
rm(fns)

figWidth <- function() 
  if (length(result <- with(opts_current$get(c("fig.width", "dpi", "fig.retina")),
	     fig.width*dpi/fig.retina))) result[1] else NULL
  

figHeight <- function() 
  if (length(result <- with(opts_current$get(c("fig.height", "dpi", "fig.retina")),
	     fig.height*dpi/fig.retina))) result[1] else NULL
