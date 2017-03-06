
subsetControl <- function(value = 1, subsets, subscenes = NULL,
                         fullset = Reduce(union, subsets),
                         accumulate = FALSE) {
  subsets <- lapply(subsets, as.integer)
  fullset <- as.integer(fullset)
  if (length(names(subsets)))
    labels <- names(subsets)
  else
    labels <- NULL
  structure(list(type = "subsetSetter",
       value = value - 1,
       subsets = unname(subsets),
       subscenes = subscenes,
       fullset = fullset,
       accumulate = accumulate,
       labels = labels),
      class = "rglControl")
}

propertyControl <- function(value = 0, entries, properties, objids, values = NULL,
                            param = seq_len(NROW(values)) - 1, interp = TRUE) {
  objids <- as.integer(objids)
  structure(list(type = "propertySetter",
       value = value,
       values = values,
       entries = entries,
       properties = properties,
       objids = objids,
       param = param,
       interp = interp),
      class = "rglControl")
}

clipplaneControl <- function(a=NULL, b=NULL, c=NULL, d=NULL,
                            plane = 1, clipplaneids,
                            ...) {
  values <- cbind(a = a, b = b, c = c, d = d)
  col <- which(colnames(values) == letters[1:4]) - 1
  propertyControl(values = values, entries = 4*(plane-1) + col,
                  properties = "vClipplane", objids = clipplaneids,
                  ...)
}

ageControl <- function(births, ages, objids, value = 0, colors = NULL, alpha = NULL,
                       radii = NULL, vertices = NULL, normals = NULL,
                       origins = NULL, texcoords = NULL,
                       x = NULL, y = NULL, z = NULL,
                       red = NULL, green = NULL, blue = NULL) {

  lengths <- c(colors = NROW(colors), alpha = length(alpha),
               radii = length(radii), vertices = NROW(vertices),
               normals = NROW(normals), origins = NROW(origins),
               texcoords = NROW(texcoords),
               x = length(x), y = length(y), z = length(z),
               red = length(red), green = length(green), blue = length(blue))
  lengths <- lengths[lengths > 0]
  n <- unique(lengths)
  stopifnot(length(n) == 1, n == length(ages), all(diff(ages) >= 0))

  ages <- c(-Inf, ages, Inf)
  rows <- c(1, 1:n, n)

  result <- list(type = "ageSetter",
                 objids = as.integer(objids),
                 value = value,
                 births = births,
                 ages = ages)

  if (!is.null(colors)) {
    colors <- col2rgb(colors)/255
    colors <- as.numeric(colors[,rows])
    result <- c(result, list(colors = colors))
  }

  if (!is.null(alpha))
    result <- c(result, list(alpha = alpha[rows]))

  if (!is.null(radii))
    result <- c(result, list(radii = radii[rows]))

  if (!is.null(vertices)) {
    stopifnot(ncol(vertices) == 3)
    result <- c(result, list(vertices = as.numeric(t(vertices[rows,]))))
  }

  if (!is.null(normals)) {
    stopifnot(ncol(normals) == 3)
    result <- c(result, list(normals = as.numeric(t(normals[rows,]))))
  }

  if (!is.null(origins)) {
    stopifnot(ncol(origins) == 2)
    result <- c(result, list(origins = as.numeric(t(origins[rows,]))))
  }

  if (!is.null(texcoords)) {
    stopifnot(ncol(texcoords) == 2)
    result <- c(result, list(texcoords = as.numeric(t(texcoords[rows,]))))
  }

  if (!is.null(x))
    result <- c(result, list(x = x[rows]))

  if (!is.null(y))
    result <- c(result, list(y = y[rows]))

  if (!is.null(z))
    result <- c(result, list(z = z[rows]))

  if (!is.null(red))
    result <- c(result, list(red = red[rows]))

  if (!is.null(green))
    result <- c(result, list(green = green[rows]))

  if (!is.null(blue))
    result <- c(result, list(blue = blue[rows]))

  structure(result, class = "rglControl")
}

vertexControl <- function(value = 0, values = NULL, vertices = 1, attributes, objid,
                          param = seq_len(NROW(values)) - 1, interp = TRUE) {
  attributes <- match.arg(attributes,
                          choices = c("x", "y", "z",
                                      "red", "green", "blue", "alpha",
                                      "radii",
                                      "nx", "ny", "nz",
                                      "ox", "oy", "oz",
                                      "ts", "tt"),
                          several.ok = TRUE)
  if (!is.null(values)) {
    ncol <- max(length(vertices), length(attributes))
    if (is.matrix(values))
      stopifnot(ncol == ncol(values))
    else {
      stopifnot(ncol == 1)
      values <- matrix(values, ncol = 1)
    }
    # Repeat first and last values to make search simpler.
    param <- c(-Inf, param, Inf)
    values <- rbind(values[1,], values, values[nrow(values),])
  }

  structure(list(type = "vertexSetter",
       value = value,
       values = values,
       vertices = vertices - 1, # Javascript 0-based indexing
       attributes = attributes,
       objid = as.integer(objid),
       param = param,       # Javascript 0-based indexing
       interp = interp),
      class = "rglControl")
}

# This is a bridge to the old system
# In the old system, the rglClass object was a global named
# <prefix>rgl, and controls install methods on it.  In the
# new system, the rglClass object is just a field of a <div>
# element.  The R code below creates an empty global for the
# controls to modify, then the Javascript code in oldBridge
# imports those into the real scene object.

elementId2Prefix <- function(elementId, prefix = elementId) {
  cat(paste0("<script>var ", prefix, "rgl = {};</script>"))
  playwidget(elementId, structure(list(type = "oldBridge",
                                       prefix = prefix),
                                  class = "rglControl"),
             components = character(0))
}

# This puts together a custom message for a more extensive change

sceneChange <- function(elementId, x = scene3d(),
                        delete = NULL, add = NULL, replace = NULL,
                        material = FALSE, rootSubscene = FALSE,
                        delfromSubscenes = NULL, skipRedraw = FALSE) {
  allSubscenes <- function() {
    result <- numeric()
    for (obj in scene$objects)
      if (obj$type == "subscene")
        result <- c(result, obj$id)
    result
  }
  inSubscenes <- function(id, subs) {
    result <- numeric()
    for (sub in subs)
      if (id %in% sub$objects)
        result <- c(result, sub$id)
    result
  }
  delete <- unique(c(delete, replace))
  add <- unique(c(add, replace))

  scene <- convertScene(x)
  allsubids <- allSubscenes()
  allsubs <- scene$objects[as.character(allsubids)]
  for (id in add)
    scene$objects[[as.character(id)]]$inSubscenes <- inSubscenes(id, allsubs)

  scene$elementId <- elementId
  allIds <- names(scene$objects)
  dontSend <- setdiff(allIds, as.character(add))
  scene$objects[dontSend] <- NULL
  if (!length(scene$objects))
    scene$objects <- NULL
  scene$sphereVerts <- NULL
  if (!material)
    scene$material <- NULL
  if (!rootSubscene)
    scene$rootSubscene <- NULL
  scene$delete <- delete
  if (is.null(delfromSubscenes))
    delfromSubscenes <- allsubids
  scene$delfromSubscenes <- as.numeric(delfromSubscenes)
  if (is.na(skipRedraw))
    scene$redrawScene <- FALSE
  else {
    scene$redrawScene <- !skipRedraw
    scene$skipRedraw <- skipRedraw
  }
  scene
}

registerSceneChange <- function() {
  tags$script('
Shiny.addCustomMessageHandler("sceneChange",
  rglwidgetClass.prototype.sceneChangeHandler);
')
}
