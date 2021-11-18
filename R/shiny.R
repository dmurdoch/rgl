# shiny support functions

# Shiny objects if the widget sets elementId, so we
# need to detect it.  Thanks to Joe Cheng for suggesting this code.

inShiny <- function() isNamespaceLoaded("shiny") && !is.null(shiny::getDefaultReactiveDomain())

fns <- local({
	registered <- FALSE
	registerShinyHandlers <- function() {
		if (!registered) {
			if (requireNamespace("shiny")) {
			  shiny::registerInputHandler("shinyPar3d", convertShinyPar3d, force = TRUE)
			  shiny::registerInputHandler("shinyMouse3d", convertShinyMouse3d, force = TRUE)
			  registered <<- TRUE
			} else
				stop("Not in Shiny")
		}
	}
	unregisterShinyHandlers <- function() {
		if (registered) {
			shiny::removeInputHandler("shinyPar3d")
			shiny::removeInputHandler("shinyMouse3d")
		}
	}
	list(registerShinyHandlers = registerShinyHandlers,
			 unregisterShinyHandlers = unregisterShinyHandlers)
})
registerShinyHandlers <- fns$registerShinyHandlers
unregisterShinyHandlers <- fns$unregisterShinyHandlers
rm(fns)

# Widget output function for use in Shiny

rglwidgetOutput <- function(outputId, width = '512px', height = '512px') {
	registerShinyHandlers()
	shinyWidgetOutput(outputId, 'rglWebGL', width, height, package = 'rgl')
}

# Widget render function for use in Shiny

renderRglwidget <- function(expr, env = parent.frame(), quoted = FALSE, outputArgs = list()) {
	registerShinyHandlers()
	if (!quoted) expr <- substitute(expr)  # force quoted
	shiny::markRenderFunction(rglwidgetOutput,
														shinyRenderWidget(expr, rglwidgetOutput, env, quoted = TRUE),
														outputArgs = outputArgs)
}

shinySetPar3d <- function(..., session,
													subscene = currentSubscene3d(cur3d())) {
	registerShinyHandlers()
	args <- list(...)
	argnames <- names(args)
	if (length(args) == 1 && is.null(argnames)) {
		args <- args[[1]]
	}
	# We might have been passed modified shinyGetPar3d output;
	# clean it up.
	args[["subscene"]] <- NULL
	args[["tag"]] <- NULL
	argnames <- names(args)
	
	if (is.null(argnames) || any(argnames == ""))
		stop("Parameters must all be named")
	
	badargs <- argnames[!(argnames %in% .Par3d) | argnames %in% .Par3d.readonly]
	if (length(badargs))
		stop("Invalid parameter(s): ", badargs)
	
	for (arg in argnames) {
		session$sendCustomMessage("shinySetPar3d", 
															list(subscene = subscene,
																	 parameter = arg,
																	 value = args[[arg]]))
	}
}

shinyGetPar3d <- function(parameters, session,
													subscene = currentSubscene3d(cur3d()),
													tag = "") {
	registerShinyHandlers()
	badargs <- parameters[!(parameters %in% .Par3d)]
	if (length(badargs))
		stop("invalid parameter(s): ", badargs)
	session$sendCustomMessage("shinyGetPar3d",
														list(tag = tag, subscene = subscene, 
																 parameters = parameters))
}

convertShinyPar3d <- function(par3d, ...) {
	for (parm in c("modelMatrix", "projMatrix", "userMatrix", "userProjection"))
		if (!is.null(par3d[[parm]]))
			par3d[[parm]] <- matrix(unlist(par3d[[parm]]), 4, 4)
	for (parm in c("mouseMode", "observer", "scale", "viewport", "bbox", "windowRect"))
		if (!is.null(par3d[[parm]]))
			par3d[[parm]] <- unlist(par3d[[parm]])
	par3d
}

shinyResetBrush <- function(session, brush) {
	registerShinyHandlers()
	session$sendCustomMessage("resetBrush", brush)
}

convertShinyMouse3d <- function(mouse3d, ...) {
	for (parm in c("model", "proj")) 
		if (!is.null(mouse3d[[parm]]))
			mouse3d[[parm]] <- matrix(unlist(mouse3d[[parm]]), 4, 4)
	
	if (length(unlist(mouse3d$view)) == 4) 
		mouse3d$view <- structure(unlist(mouse3d$view),
															names = c("x", "y", "width", "height"))
	if (all(c("p1", "p2") %in% names(mouse3d$region)))
		mouse3d$region <- with(mouse3d$region,
													 c(x1 = (p1$x + 1)/2,
													 	y1 = (p1$y + 1)/2,
													 	x2 = (p2$x + 1)/2,
													 	y2 = (p2$y + 1)/2))
	structure(mouse3d, class = "rglMouseSelection")
}
