in_pkgdown_example <- function() 
	!is.null(getOption("downlit.rdname")) && 
	  requireNamespace("downlit") &&
	  requireNamespace("pkgdown")

pkgdown_print.rglId <- function(x, visible) {
	result <- htmltools::renderTags(rglwidget())
	class(result) <- c("rgl_rendered", class(result))
	result
}

replay_html.rgl_rendered <- function(x, ...) {
	structure(x$html, dependencies = x$dependencies)
}

