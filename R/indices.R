
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
