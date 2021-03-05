in_pkgdown_example <- function() 
	!is.null(getOption("downlit.rdname")) && 
	  requireNamespace("downlit") &&
	  requireNamespace("pkgdown")

pkgdown_print.rglId <- function(x, visible) {
	rendered <- htmltools::renderTags(rglwidget())
	result <- rendered$html
	class(result) <- "rgl_rendered"
	result
}

replay_html.rgl_rendered <- function(x, ...) {
	unclass(x)
}

