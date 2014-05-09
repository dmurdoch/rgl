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

newSubscene3d <- function(viewport = "replace", 
                       projection = "replace",
		       model = "replace",
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
  invisible(subscene)
}

delFromSubscene3d <- function(ids, subscene = subsceneInfo()$id) {
  result <- .C(rgl_delfromsubscene, success = as.integer(subscene), 
     n = as.integer(length(ids)), ids = as.integer(ids))$success
  if (!result)
    stop("Failed to delete objects from subscene ", subscene)
  invisible(subscene)
}

# This destroys any objects that are in the scene but
# not in either the protect vector or visible in a subscene

gc3d <- function(protect=NULL) {
  protect <- as.integer(protect)
  invisible( .C(rgl_gc, n = length(protect), protect)$n )
}

next3d <- function(current = NA, clear = TRUE) {
  .check3d()
  if (is.na(current))
    current <- subsceneInfo()$id
  subscenes <- .rglEnv$subsceneList
  if (is.null(subscenes)) 
    subscenes <- current
  if (current %in% subscenes) {
    this <- which(current == subscenes)
    if (this == length(subscenes)) 
      current <- subscenes[1]
    else 
      current <- subscenes[this + 1]
  } else
    current <- subscenes[1]
  if (clear)
    clear3d(subscene = current)
  useSubscene3d(current)
}
  
mfrow3d <- function(nr, nc, byrow = TRUE, parent = NA, 
                           ...) {
  stopifnot(nr >= 1, nc >= 1)
  .check3d()
  if (is.na(parent))
    parent <- subsceneInfo()$id
  useSubscene3d(parent)
  result <- integer(nr*nc)
  parentvp <- par3d("viewport")
  if (byrow)
    for (i in seq_len(nr))
      for (j in seq_len(nc)) {
        newvp <- c(parentvp[1] + (j - 1)*parentvp[3]/nc,
                   parentvp[2] + (nr - i)*parentvp[4]/nr,
                   parentvp[3]/nc, parentvp[4]/nr)
        result[(i-1)*nc + j] <- newSubscene3d(newviewport = newvp, parent = parent, ...)
      }
  else
    for (j in seq_len(nc))
      for (i in seq_len(nr)) {
        newvp <- c(parentvp[1] + (j - 1)*parentvp[3]/nc,
                   parentvp[2] + (nr - i)*parentvp[4]/nr,
                   parentvp[3]/nc, parentvp[4]/nr)
        result[(j-1)*nr + i] <- newSubscene3d(newviewport = newvp, parent = parent, ...)
      }
  useSubscene3d(result[1])
  attr(result, "prev") <- .rglEnv$subsceneList
  assign("subsceneList", result, env = .rglEnv)
  invisible(result)
}

layout3d <- function(mat, widths = rep.int(1, ncol(mat)), 
                          heights = rep.int(1, nrow(mat)),
                          parent = NA, 
                          ...) {
  storage.mode(mat) <- "integer"
  mat <- as.matrix(mat)
  num.figures <- max(mat)
  if (!all(seq_len(num.figures) %in% as.integer(mat)))
    stop(gettextf("layout matrix must contain at least one reference\nto each of the values {1 ... %d}\n", 
            num.figures), domain = NA)
  dm <- dim(mat)
  num.rows <- dm[1L]
  num.cols <- dm[2L]

  .check3d()
  if (is.na(parent))
    parent <- subsceneInfo()$id
  useSubscene3d(parent)
  parentvp <- par3d("viewport")
  
  widths <- parentvp["width"]*widths/sum(widths)
  heights <- parentvp["height"]*heights/sum(heights)
  xs <- c(0, cumsum(widths))
  ys <- rev(c(0, cumsum(rev(heights))))[-1]
  
  result <- integer(num.figures)
  for (i in seq_len(num.figures)) {
    rows <- range(row(mat)[mat == i])
    cols <- range(col(mat)[mat == i])
    newvp <- c(xs[cols[1]], ys[rows[1]], sum(widths[cols[1]:cols[2]]), sum(heights[rows[1]:rows[2]]))
    result[i] <- newSubscene3d(newviewport = newvp, parent = parent,  ...)
  }
  useSubscene3d(result[1])
  attr(result, "prev") <- .rglEnv$subsceneList
  assign("subsceneList", result, env = .rglEnv)
  invisible(result)
}
