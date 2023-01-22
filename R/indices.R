
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
