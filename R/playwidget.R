
#' Widget output function for use in Shiny
#'
#' @export
playwidgetOutput <- function(outputId, width = '0px', height = '0px'){
  shinyWidgetOutput(outputId, 'rglPlayer', width, height, package = 'rgl')
}

#' Widget render function for use in Shiny
#'
#' @export
renderPlaywidget <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, rglwidgetOutput, env, quoted = TRUE)
}

playwidget <- function(sceneId, ...)
  UseMethod("playwidget")

playwidget.default <- function(sceneId, controls, start = 0, stop = Inf, interval = 0.05,  rate = 1,
                       components = c("Reverse", "Play", "Slower", "Faster", "Reset", "Slider", "Label"),
                       loop = TRUE,
                       step = 1, labels = NULL,
                       precision = 3,
                       elementId = NULL, respondTo = NULL,
                       reinit = NULL,
		       buttonLabels = components,
		       pause = "Pause",
                       ...) {

  sceneId <- as.character(sceneId)

  if (length(sceneId) != 1)
    stop("Unsupported `sceneId`")

  if (is.null(elementId) && !inShiny())
    elementId <- paste0("rgl-play", sample(100000, 1))

  if (!is.null(respondTo))
    components <- NULL

  if (length(stop) != 1 || !is.finite(stop)) stop <- NULL

  if (identical(controls, NA)) 
  	stop(dQuote("controls"), " should not be NA.")
  	
  stopifnot(is.list(controls))

  if (inherits(controls, "rglControl"))
    controls <- list(controls)

  types <- vapply(controls, class, "")
  if (any(bad <- types != "rglControl")) {
    bad <- which(bad)[1]
    stop("Controls should be of class 'rglControl', control ", bad, " is ", types[bad])
  }
  names(controls) <- NULL

  if (length(reinit)) {
    bad <- vapply(controls, function(x) x$type == "vertexSetter" && length(intersect(reinit, x$objid)), FALSE)
    if (any(bad))
      warning("'vertexControl' is incompatible with re-initialization")
  }

  if (!length(components))
    components <- character()
  else
    components <- match.arg(components, 
    			c("Reverse", "Play", "Slower", "Faster", "Reset", "Slider", "Label", "Step"),
    			several.ok = TRUE)

  buttonLabels <- as.character(buttonLabels)
  pause <- as.character(pause)
  stopifnot(length(buttonLabels) == length(components),
  	    length(pause) == 1)
  
  if (is.null(stop) && !missing(labels) && length(labels))
    stop <- start + (length(labels) - 1)*step

  if (is.null(stop)) {
    if ("Slider" %in% components) {
      warning("Cannot have slider with non-finite limits")
      components <- setdiff(components, "Slider")
    }
    labels <- NULL
  } else {
    if (stop == start)
      warning("'stop' and 'start' are both ", start)
  }

  control <- list(
       actions = controls,
       start = start,
       stop = stop,
       value = start,
       interval = interval,
       rate = rate,
       components = components,
       buttonLabels = buttonLabels,
       pause = pause,
       loop = loop,
       step = step,
       labels = labels,
       precision = precision,
       reinit = reinit,
       sceneId = sceneId,
       respondTo = respondTo)

  createWidget(
    name = 'rglPlayer',
    x = control,
    elementId = elementId,
    package = 'rgl',
    sizingPolicy = sizingPolicy(defaultWidth = "auto",
                                defaultHeight = "auto"),
    ...
  )
}

rglPlayer_html <- function(id, style, class, ...) {
  tags$span(id = id, class = class)
}

playwidget.rglWebGL <- function(sceneId, controls, elementId = NULL, ...) {

  if (is.null(elementId) && !inShiny())
    elementId <- paste0("rgl-play", sample(100000, 1))

  if (!is.null(elementId) && !(elementId %in% sceneId$x$players))
    sceneId$x$players <- c(sceneId$x$players, elementId)

  browsable(tagList(sceneId,
                    playwidget(sceneId$elementId, controls, elementId = elementId,
                               ...)))
}

playwidget.rglPlayer <- function(sceneId, controls, ...) {

  browsable(tagList(sceneId,
                    playwidget(NA, controls,
                               ...)))
}

playwidget.shiny.tag.list <- function(sceneId, controls, elementId = NULL, ...) {

  if (is.null(elementId) && !inShiny())
    elementId <- paste0("rgl-play", sample(100000, 1))

  scene <- NULL
  for (i in seq_along(sceneId)) {
    if (inherits(sceneId[[i]], "rglWebGL")) {
      scene <- sceneId[[i]]$elementId
      if (!is.null(elementId) && !(elementId %in% sceneId[[i]]$x$players))
        sceneId[[i]]$x$players <- c(sceneId[[i]]$x$players, elementId)
      break
    }
  }

  if (is.null(scene))
    scene <- NA

  sceneId[[length(sceneId) + 1]] <-
    playwidget(scene, controls, elementId = elementId,
                               ...)
  sceneId
}

toggleWidget <- function(sceneId, ids, subscenes = NULL, label = deparse(substitute(ids)), ...) 
  playwidget(sceneId, 
	subsetControl(subsets = list(ids, integer()), subscenes = subscenes),
	start = 0, stop = 1,
	components = "Step",
	buttonLabels = label,
	interval = 1,
	...)