
# Get the attribute expanded by the indices, if any
expandAttrib <- function(id, attrib) {
  result <- rgl.attrib(id, attrib)
  if (length(result)) {
    indices <- rgl.attrib(id, "indices")
    if (length(indices))
      result <- result[indices,]
  }
  result
}

expandVertices <- function(id) 
  expandAttrib(id, "vertices")

expandNormals <- function(id)
  expandAttrib(id, "normals")

expandTexcoords <- function(id)
  expandAttrib(id, "texcoords")

# expandColors <- function(id) {
#   result <- rgl.attrib(id, "colors")
#   if (nrow(result) > 1)
#     result <- expandAttrib("colors")
#   result
# }

expandMaterial <- function(id, nvert) {
  result <- rgl.getmaterial(nvert, id = id)
  indices <- rgl.attrib(id, "indices")
  if (length(indices)) {
    length(indices) <- min(nvert, length(indices))
    if (length(result$color) > 1)
      result$color <- result$color[indices]
    if (length(result$alpha) > 1 )
      result$alpha <- result$alpha[indices]
  }
  result
}

getExpandedNverts <- function(id) {
  result <- length(rgl.attrib(id, "indices"))
  if (!result)
    result <- NROW(rgl.attrib(id, "vertices"))
  result
}

getIndices <- function(id) {
  result <- rgl.attrib(id, "indices")
  if (!length(result))
    result <- seq_len(NROW(rgl.attrib(id, "vertices")))
  result
}

# Check for indices that differ from default
checkForIndices <- function(id, warn = TRUE) {
  has_indices <- length(indices <- rgl.attrib(id, "indices")) > 0 && 
                 !all(indices == seq_along(indices))
  if (has_indices && warn)
    warning("Indices not supported.  Skipping id", id, call. = FALSE)
  has_indices
}
