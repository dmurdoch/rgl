
#' Widget output function for use in Shiny
#'
#' @export
playwidgetOutput <- function(outputId, width = '0px', height = '0px') {
	registerShinyHandlers()
  shinyWidgetOutput(outputId, 'rglPlayer', width, height, package = 'rgl')
}

#' Widget render function for use in Shiny
#'
#' @export
renderPlaywidget <- function(expr, env = parent.frame(), quoted = FALSE, outputArgs = list()) {
	registerShinyHandlers()
  if (!quoted) expr <- substitute(expr)  # force quoted
  shiny::markRenderFunction(playwidgetOutput,
                     shinyRenderWidget(expr, playwidgetOutput, env, quoted = TRUE),
  		     outputArgs = outputArgs)
}

playwidget <- function(sceneId, controls, start = 0, stop = Inf, interval = 0.05,  rate = 1,
                       components = c("Reverse", "Play", "Slower", "Faster", "Reset", "Slider", "Label"),
                       loop = TRUE,
                       step = 1, labels = NULL,
                       precision = 3,
                       elementId = NULL, respondTo = NULL,
                       reinit = NULL,
		       buttonLabels = components,
		       pause = "Pause",
		       height = 40,
                       ...) {

  if (is.null(elementId) && !inShiny())
    elementId <- newElementId("rgl-play")

  # sceneId = NA turns into prevRglWidget = NULL      
  upstream <- processUpstream(sceneId, playerId = elementId)
  
  if (!is.null(respondTo))
    components <- buttonLabels <- NULL

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
  
  for (i in seq_along(controls)) {
    control <- controls[[i]]
    if (!is.null(labels)) 
      labels <- control$labels
    if (!is.null(control$param)) {
      start <- min(start, control$param[is.finite(control$param)])
      stop <- max(stop, control$param[is.finite(control$param)])
    }
  }

  if (is.null(stop) && !missing(labels) && length(labels)) {
    stop <- start + (length(labels) - 1)*step
  }
  
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
       sceneId = upstream$prevRglWidget,
       respondTo = respondTo)

  result <- createWidget(
    name = 'rglPlayer',
    x = control,
    elementId = elementId,
    package = 'rgl',
    height = height,
    sizingPolicy = sizingPolicy(defaultWidth = "auto",
                                defaultHeight = "auto"),
    dependencies = rglDependency,
    ...
  )
  if (is.list(upstream$objects)) {
    do.call(combineWidgets, 
            c(upstream$objects, 
              list(combineWidgets(result, nrow = 1), 
                   rowsize = c(upstream$rowsizes, height), 
                   ncol = 1)))
  } else
    result
}

toggleWidget <- function(sceneId, ids = integer(), 
                         hidden = integer(),
                         subscenes = NULL, 
                         label = deparse(substitute(ids)), 
                         ...) 
  playwidget(sceneId, 
             subsetControl(subsets = list(ids, hidden), subscenes = subscenes),
             start = 0, stop = 1,
             components = "Step",
             buttonLabels = label,
             interval = 1,
             ...)
