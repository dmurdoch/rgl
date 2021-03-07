in_pkgdown_example <- function() 
	!is.null(getOption("downlit.rdname")) && 
	  requireNamespace("downlit") &&
	  requireNamespace("pkgdown")

pkgdown_print.rglId <- local({
	plotnum <- 0
	
	function(x, visible = TRUE) {
		scene <- scene3d()
		if (inherits(x, "rglHighlevel"))
			plotnum <<- plotnum + 1
		structure(list(plotnum = plotnum,
							     scene = scene),
							class = c("rglRecordedplot", "otherRecordedplot"))
	}
})

replay_html.rglRecordedplot <- function(x, ...) {
	# Needs reuse = FALSE, or a reset at the start of
	# each example.  Currently there's no way to do that.
	rendered <- htmltools::renderTags(rglwidget(x$scene, reuse = FALSE))
	structure(rendered$html, dependencies = rendered$dependencies)
}

register_pkgdown_methods <- local({
	registered <- FALSE
	function(register = in_pkgdown_example()) {
		if (!registered && register) {
			registerS3method("replay_html", "rglRecordedplot", 
											 replay_html.rglRecordedplot, 
											 envir = asNamespace("downlit"))
			registerS3method("is_low_change", "rglRecordedplot", 
											 is_low_change.rglRecordedplot,
											 envir = asNamespace("downlit"))
			registerS3method("pkgdown_print", "rglId", 
											 pkgdown_print.rglId, 
											 envir = asNamespace("pkgdown"))
			registered <<- TRUE
		}
	}
})
