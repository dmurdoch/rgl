subst <- function(strings, ..., digits=7) {
  substitutions <- list(...)
  names <- names(substitutions)
  if (is.null(names)) names <- rep("", length(substitutions))
  for (i in seq_along(names)) {
    if ((n <- names[i]) == "")
      n <- as.character(sys.call()[[i+2]])
    value <- substitutions[[i]]
    if (is.numeric(value))
      value <- formatC(value, digits=digits, width=1)
    strings <- gsub(paste("%", n, "%", sep=""), value, strings)
  }
  strings
}

rglwidgetCheck <- function() {
  if (!requireNamespace("rglwidget", quietly = TRUE))
    stop("This function requires the rglwidget package to be installed.")
}

convertBBox <- function(id,
  verts = rgl.attrib(id, "vertices"),
  text = rgl.attrib(id, "text"),
  mat = rgl.getmaterial(id = id)) {
  if (!length(text))
    text <- rep("", NROW(verts))
  if (length(mat$color) > 1)
    mat$color <- mat$color[2] # We ignore the "box" colour

  if(any(missing <- text == ""))
    text[missing] <- apply(verts[missing,], 1, function(row) format(row[!is.na(row)]))

  res <- integer(0)
  if (any(inds <- is.na(verts[,2]) & is.na(verts[,3])))
    res <- c(res, do.call(axis3d, c(list(edge = "x", at = verts[inds, 1], labels = text[inds]), mat)))
  if (any(inds <- is.na(verts[,1]) & is.na(verts[,3])))
    res <- c(res, do.call(axis3d, c(list(edge = "y", at = verts[inds, 2], labels = text[inds]), mat)))
  if (any(inds <- is.na(verts[,1]) & is.na(verts[,2])))
    res <- c(res, do.call(axis3d, c(list(edge = "z", at = verts[inds, 3], labels = text[inds]), mat)))
  res <- c(res, do.call(box3d, mat))
  res
}

rootSubscene <- function() {
  id <- currentSubscene3d()
  repeat {
    info <- subsceneInfo(id)
    if (is.null(info$parent)) return(id)
    else id <- info$parent
  }
}

writeWebGL <- function(dir="webGL", filename=file.path(dir, "index.html"),
                       template = system.file(file.path("WebGL", "template.html"), package = "rgl"),
                       prefix = "",
                       snapshot = TRUE, commonParts = TRUE, reuse = NULL,
		       font="Arial",
                       width = NULL, height = NULL) {

  rglwidgetCheck()
  rglwidget::.writeWebGL(dir, filename, template, prefix, snapshot, commonParts,
  		         reuse, font, width, height)
}
