subsceneInfo <- function(id, recursive = FALSE) {
  if (missing(id)) 
    id <- .C(rgl_getsubsceneid, id = 1L)$id
  else if (is.character(id) && id == "root") 
    id <- .C(rgl_getsubsceneid, id = 0L)$id
  if (!id) stop("No subscene info available.")
  id <- as.integer(id)
  result <- list(id = id)
  
  parent <- .C(rgl_getsubsceneparent, id = id)$id
  
  if (is.na(parent)) stop("Subscene ", id, " not found.")
  if (!parent) parent <- NULL
  result[["parent"]] <- parent
  
  n <- .C(rgl_getsubscenechildcount, id = id, n = integer(1))$n
  if (n) {
    children <- .C(rgl_getsubscenechildren, id = id, children=integer(n))$children
    if (recursive) {
      childlist <- list()
      for (i in seq_len(n))
        childlist[[i]] <- subsceneInfo(id = children[i], recursive = TRUE)
      result[["children"]] <- childlist
    } else
      result[["children"]] <- children
  }
  
  embeddings <- .C(rgl_getEmbedding, id = id, embeddings = integer(3))$embeddings
  embeddings <- c("inherit", "modify", "replace")[embeddings]
  names(embeddings) <- c("viewport", "projection", "model")
  result[["embeddings"]] <- embeddings
  result
}
