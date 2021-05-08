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

# FIXME:  this function should handle both R and Javascript
#  callbacks somehow.

setUserCallbacks <- function(button, begin = NULL, update = NULL, end = NULL,
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
  if (is.numeric(button))
    button <- c("left", "right", "middle", "default")[button]
  sub$par3d$mouseMode[button] <- "user"
  if (is.null(sub$callbacks))
    sub$callbacks <- list()
  sub$callbacks[[button]] <- list(begin = begin, update = update,
                        end = end)
  sub$embeddings["mouse"] <- "replace"
  javascript <- c(scene$javascript, javascript)
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
      fns <- callbacks[[button]]
      if (!is.null(fns)) {
        for (f in c("begin", "update", "end"))
          if (is.character(fns[[f]])) {
            fn <- try(match.fun(fns[[f]]), silent = TRUE)
            if (is.function(fn))
              fns[[f]] <- fn
            else
              fns[[f]] <- NULL
          }
        callbacks[[button]] <- fns
        if (any(vapply(fns, is.function, TRUE)))
          do.call(rgl.setMouseCallbacks, 
                  c(list(button = c(left = 1, right = 2, middle = 3, default = 4)[button],
                         dev = dev, subscene = subscene),
                    fns))
      }
    }
  }
  invisible(scene)
}
