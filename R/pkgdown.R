# Functions related to working in pkgdown

# The exists() part of this test are only needed until
# CRAN's version of the packages contain my suggested patches.
in_pkgdown_example <- function() 
	!is.null(getOption("downlit.rdname")) && 
	  requireNamespace("downlit") &&
	  exists("is_low_change.default", asNamespace("downlit")) &&
	  requireNamespace("pkgdown") &&
    exists("pkgdown_print", asNamespace("pkgdown"))
	  
fns <- local({
	plotnum <- 0
	
	pkgdown_print.rglId <- function(x, visible = TRUE) {
		scene <- scene3d()
		if (inherits(x, "rglHighlevel"))
			plotnum <<- plotnum + 1
		structure(list(plotnum = plotnum,
							     scene = scene),
							class = c("rglRecordedplot", "otherRecordedplot"))
	}
	
	pkgdown_print.rglOpen3d <- function(x, visible = TRUE) {
		plotnum <<- plotnum + 1
		invisible(x)
	}
	
	list(pkgdown_print.rglId = pkgdown_print.rglId,
			 pkgdown_print.rglOpen3d = pkgdown_print.rglOpen3d)
})

pkgdown_print.rglId <-     fns[["pkgdown_print.rglId"]]
pkgdown_print.rglOpen3d <- fns[["pkgdown_print.rglOpen3d"]]
rm(fns)

replay_html.rglRecordedplot <- function(x, ...) {
	# Needs reuse = FALSE, or a reset at the start of
	# each example.  Currently there's no way to do that.
	rendered <- htmltools::renderTags(rglwidget(x$scene, reuse = FALSE))
	structure(rendered$html, dependencies = rendered$dependencies)
}

# This is only needed until CRAN's pkgdown exports pkgdown_print,
# then we should use pkgdown::pkgdown_print
pkgdown_print <- NULL

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
			registerS3method("pkgdown_print", "rglOpen3d", 
											 pkgdown_print.rglOpen3d, 
											 envir = asNamespace("pkgdown"))
			registered <<- TRUE
		}
	}
})
