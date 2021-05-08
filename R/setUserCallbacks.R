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
			                       scene = scene3d(minimal),
			                       minimal = TRUE) {
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
  scene$rootSubscene <- replaceSubscene(scene$rootSubscene,
                                        subscene, sub)
  scene$javascript <- c(scene$javascript, javascript)
  scene
}
