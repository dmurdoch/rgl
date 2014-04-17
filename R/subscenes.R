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

subscene3d <- function(id, viewport = "inherit", 
                       projection = "inherit",
		       model = "inherit",
                       parent = subsceneInfo()$id, copyLights = TRUE,
                       copyShapes = FALSE,
                       newviewport) {
  if (missing(id)) {
    embedding <- c("inherit", "modify", "replace")
    viewport <- pmatch(viewport, embedding)
    projection <- pmatch(projection, embedding)
    model <- pmatch(model, embedding)
    stopifnot(length(viewport) == 1, length(projection) == 1, length(model) == 1,
	      !is.na(viewport), !is.na(projection), !is.na(model))
    embedding <- c(viewport, projection, model)
  
    id <- .C(rgl_newsubscene, id = integer(1), parent = as.integer(parent),
               embedding = as.integer(embedding))$id
               
    if (id) {
      if (copyLights || copyShapes) {
        .C(rgl_setsubscene, parent)
        ids <- rgl.ids(type = c("lights", "shapes")[c(copyLights, copyShapes)])$id
        if (length(ids)) {
          .C(rgl_setsubscene, id)
          .C(rgl_addtosubscene, success = integer(1), n = as.integer(length(ids)),
  	                        ids = as.integer(ids))
        }
      }
    }
  }
  id <- .C(rgl_setsubscene, id = id)$id
  if (id) {
    if (!missing(newviewport)) {
      embedding <- subsceneInfo(id)$embeddings
      if (embedding[1] > 1)
        par3d(viewport = as.integer(newviewport))
    }
  }
  invisible(id)
}
