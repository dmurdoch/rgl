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

newSubscene3d <- function(viewport = "inherit", 
                       projection = "inherit",
		       model = "inherit",
                       parent = subsceneInfo()$id, copyLights = TRUE,
                       copyShapes = FALSE,
                       copyBBoxDeco = copyShapes,
                       newviewport) {
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
    if (copyLights || copyShapes || copyBBoxDeco) {
      useSubscene3d(parent)
      ids <- rgl.ids(type = 
        c("lights", "shapes", "bboxdeco")[c(copyLights, copyShapes, copyBBoxDeco)])$id
      if (length(ids)) 
        addToSubscene3d(ids, subscene = id)
    }
    useSubscene3d(id)
    if (!missing(newviewport)) {
      embedding <- subsceneInfo(id)$embeddings
      if (embedding[1] > 1)
        par3d(viewport = as.integer(newviewport))
    }
  } else
    stop("Subscene creation failed.")
  invisible(id)
}

useSubscene3d <- function(subscene) {
  result <- .C(rgl_setsubscene, id=as.integer(subscene))$id
  if (!result) stop("Subscene ", subscene, " not found.")
  invisible(subscene)
}

addToSubscene3d <- function(ids, subscene = subsceneInfo()$id) {
  result <- .C(rgl_addtosubscene, success = as.integer(subscene), 
     n = as.integer(length(ids)), ids = as.integer(ids))$success
  if (!result)
    stop("Failed to add objects to subscene ", subscene)
}
