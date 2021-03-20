# Functions related to working in pkgdown

pkgdown_rdname <- function() 
	getOption("downlit.rdname", "")

in_pkgdown <- function() 
	requireNamespace("pkgdown", quietly = TRUE) && pkgdown::in_pkgdown()

# The exists() part of this test are only needed until
# CRAN's version of the packages contain my suggested patches.
in_pkgdown_example <- function() 
	nchar(pkgdown_rdname()) && 
	requireNamespace("downlit", quietly = TRUE) &&
	exists("is_low_change.default", asNamespace("downlit")) &&
	requireNamespace("pkgdown", quietly = TRUE) &&
	exists("pkgdown_print", asNamespace("pkgdown"))

fns <- local({
	plotnum <- 0
	
	pkgdown_print.rglId <- function(x, visible = TRUE) {
		
		if (inherits(x, "rglHighlevel"))
			plotnum <<- plotnum + 1
		
		if (visible) {
		  scene <- scene3d()
		  structure(list(plotnum = plotnum,
			  				     scene = scene),
				  			class = c("rglRecordedplot", "otherRecordedplot"))
		} else
			invisible()
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

globalVariables("fig.asp")
pkgdown_dims <- function() {
	settings <- pkgdown_fig_settings()
	rgl <- settings$other.parameters$rgl
	
	settings[names(rgl)] <- rgl

	numparms <- length(intersect(names(rgl), c("fig.width", "fig.height", "fig.asp")))
	if (numparms > 0 && numparms < 3) {
		settings <- within(settings, {
	    if (is.null(rgl$fig.height))
		    fig.height <- fig.width * fig.asp
	    if (is.null(rgl$fig.width))
	    	fig.width <- fig.height / fig.asp
		})
	}
	
	width <- with(settings, dpi*fig.width)
	height <- with(settings, dpi*fig.height)
	list(width = width, height = height)
}

replay_html.rglRecordedplot <- local({
	rdname <- ""
	function(x, ...) {
		if (pkgdown_rdname() != rdname) 
			rdname <<- pkgdown_rdname()
		
		settings <- pkgdown_dims()
		rendered <- htmltools::renderTags(rglwidget(x$scene,
																								width = settings$width, height = settings$height))
		structure(rendered$html, dependencies = rendered$dependencies)
	}
})

pkgdown_info <- local({
	info <- NULL
	function() {
		if (!is.null(info))
			return(info)
    path <- "."
    repeat {
	    if (file.exists(file.path(path, "DESCRIPTION"))) {
	    	info <<- pkgdown::as_pkgdown(path)
	    	return(info)
	    }
	    newpath <- file.path(path, "..")
	    if (normalizePath(newpath) == normalizePath(path))
	    	return(list())
	    path <- newpath
    }
  }
})

# These are only needed until CRAN's pkgdown exports pkgdown_print
# and fig_settings,
# then we should use pkgdown::pkgdown_print and pkgdown::fig_settings
pkgdown_print <- function(x, visible = TRUE) ""

pkgdown_fig_settings <- function() list(dpi = 96, fig.width = 5, fig.height = 5)

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
