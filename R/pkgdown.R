# Functions related to working in pkgdown

pkgdown_rdname <- function() 
	getOption("downlit.rdname", "")

# The exists() part of this test are only needed until
# CRAN's version of the packages contain my suggested patches.
in_pkgdown_example <- function() 
	nchar(pkgdown_rdname()) && 
	requireNamespace("downlit") &&
	exists("is_low_change.default", asNamespace("downlit")) &&
	requireNamespace("pkgdown") &&
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

replay_html.rglRecordedplot <- local({
	rdname <- ""
	function(x, ...) {
		if (pkgdown_rdname() != rdname) {
			environment(rglwidget)$reuseDF <- NULL
			rdname <<- pkgdown_rdname()
		}
		
	  rendered <- htmltools::renderTags(rglwidget(x$scene, reuse = TRUE))
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

pkgdown_figure_info <- function() {
	info <- getOption("pkgdown.figures", list())
	if (length(info)) {
    if (is.null(info[["fig.height"]]))
      info[["fig.height"]] <- info[["fig.width"]]*info[["fig.asp"]]
    else if (is.null(info[["fig.width"]]))
      info[["fig.width"]] <- info[["fig.height"]]/info[["fig.asp"]]
	}
	info
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
