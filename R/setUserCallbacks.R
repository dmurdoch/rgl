rgl.callback.env <- new.env(parent = emptyenv())

findSubscene <- function(subscene, id) {
  if (subscene$id == id)
    return(subscene)
  subscenes <- subscene$subscenes
  if (!is.null(subscenes)) {
    for (i in seq_along(subscenes)) {
      if (!is.null(result <- findSubscene(subscenes[[i]])))
        return(result)
    }
  }
  NULL
}

findBboxdeco <- function(scene, subscene, root = scene$rootSubscene, guess = NULL) {
  active <- root
  for (id in active$objects)
    if (scene$objects[[as.character(id)]]$type == "bboxdeco")
      guess <- id
  if (active$id == subscene)
    if (is.null(guess))
      return(NULL)
    else
      return(scene$objects[[as.character(guess)]])
  for (sub in active$subscenes)
    if (!is.null(bbox <- findBboxdeco(scene, subscene, sub, guess)))
      return(bbox)
  return(NULL)
}

replaceSubscene <- function(subscene, id, newvalue) {
  if (as.character(subscene$id) == id)
    return(newvalue)
  subscenes <- subscene$subscenes
  if (!is.null(subscenes))
    for (i in seq_along(subscenes))
      if (!is.null(result <- replaceSubscene(subscenes[[i]], id, newvalue))) {
        subscene$subscenes[[i]] <- result
        return(subscene)
      }
  NULL
}

setUserCallbacks <- function(button = NULL, begin = NULL, update = NULL, end = NULL,
                             rotate = NULL,
                             javascript = NULL,
                             subscene = scene$rootSubscene$id,
			                       scene = scene3d(minimal = FALSE),
			                       applyToScene = TRUE,
			                       applyToDev = missing(scene)) {
  force(applyToDev)
  stopifnot(inherits(scene, "rglscene"))
  subscene <- as.character(subscene)

  sub <- findSubscene(scene$rootSubscene, subscene)
  if (is.null(sub))
    stop("subscene ", subscene, " not found.")
  if (is.null(sub$par3d) || is.null(sub$par3d$mouseMode) 
      || is.null(sub$embeddings)) 
    stop("Internal error:  subscene missing mouseMode or embeddings")
  if (is.null(sub$callbacks))
    sub$callbacks <- list()
  if (!is.null(button)) {
    if (is.numeric(button))
      button <- c("none", "left", "right", "middle", "wheel")[button + 1]
    sub$par3d$mouseMode[button] <- "user"
    sub$callbacks[[button]] <- list(begin = begin, update = update,
                                    end = end, rotate = rotate)
    sub$embeddings["mouse"] <- "replace"
  } 
  javascript <- paste(c(scene$javascript, javascript),
                      collapse = "\n")
  if (applyToScene) {
    scene$rootSubscene <- replaceSubscene(scene$rootSubscene,
                                        subscene, sub)
    scene$javascript <- javascript
  }
  if (applyToDev) {
    dev <- cur3d()
    devname <- paste0("dev", dev)
    callbacks <- rgl.callback.env[[devname]]
    if (is.null(callbacks))
      callbacks <- list()
    callbacks[[paste0("sub", subscene)]] <- sub$callbacks
    callbacks$javascript <- javascript
    rgl.callback.env[[devname]] <- callbacks
    if (dev > 0) {
      callbacks <- sub$callbacks
      if (!is.null(button)) {
        fns <- callbacks[[button]]
        if (!is.null(fns)) {
          for (f in c("begin", "update", "end", "rotate"))
            if (is.character(fns[[f]])) {
              fn <- try(match.fun(fns[[f]]), silent = TRUE)
              if (is.function(fn))
                fns[[f]] <- fn
              else
                fns[[f]] <- NULL
            }
          callbacks[[button]] <- fns
          if (button == "wheel" && is.function(fns$rotate))
            rgl.setWheelCallback(rotate = fns$rotate, dev = dev, subscene = subscene)
          fns$rotate <- NULL
          if (any(vapply(fns, is.function, TRUE)))
            do.call(rgl.setMouseCallbacks, 
                    c(list(button = c(none = 0, left = 1, right = 2, middle = 3, wheel = 4)[button],
                           dev = dev, subscene = subscene),
                      fns))
        }
      }
    }
  }
  invisible(scene)
}

setAxisCallbacks <- function(axes, fns,
                             javascript = NULL,
                             subscene = scene$rootSubscene$id,
                             scene = scene3d(minimal = FALSE),
                             applyToScene = TRUE,
                             applyToDev = missing(scene)) {
  force(applyToDev)
  stopifnot(inherits(scene, "rglscene"))
  subscene <- as.character(subscene)
  
  if (!is.character(axes))
    axes <- c("x", "y", "z")[axes]
  else
    axes <- tolower(axes)
  stopifnot(all(axes %in% c("x", "y", "z")))
  
  if (!is.list(fns))
    fns <- list(fns)
  
  n <- max(length(axes), length(fns))
  axes <- rep(axes, length = n)
  fns <- rep(fns, length = n)
  
  sub <- findSubscene(scene$rootSubscene, subscene)
  if (is.null(sub))
    stop("subscene ", subscene, " not found.")
  bbox <- findBboxdeco(scene, subscene)
  if (is.null(bbox)) 
    stop("No bbox decoration found.")
  if (is.null(bbox$callbacks))
    bbox$callbacks <- list()
  for (i in seq_len(n))
    bbox$callbacks[[axes[i]]] <- fns[[i]]

  javascript <- paste(c(scene$javascript, javascript),
                      collapse = "\n")
  if (applyToScene) {
    scene$objects[[as.character(bbox$id)]] <- bbox
    scene$javascript <- javascript
  }
  if (applyToDev) {
    dev <- cur3d()
    devname <- paste0("dev", dev)
    callbacks <- rgl.callback.env[[devname]]
    if (is.null(callbacks))
      callbacks <- list()
    callbacks[[paste0("bbox", bbox$id)]] <- bbox$callbacks
    callbacks$javascript <- javascript
    rgl.callback.env[[devname]] <- callbacks
    if (dev > 0) {
      callbacks <- bbox$callbacks
      for (i in seq_len(n)) {
        fn <- fns[[i]]
        if (is.character(fn)) {
          fn <- try(match.fun(fn), silent = TRUE)
          if (!is.function(fn))
            fn <- NULL
        }
        rgl.setAxisCallback(match(axes[i], c("x", "y", "z")), fn, 
                            dev = dev, subscene = subscene)
      }
    }
  }
  invisible(scene)
}
