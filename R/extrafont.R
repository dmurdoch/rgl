# This function is modelled on similar functions in 
# the extrafont package.

loadfonts_rgl <- function(..., quiet = TRUE) {
	
	makeRglFont <- function(family) {
		getIndex <- function(Bold, Italic)
			1 + Bold + 2*Italic
		fontdata <- fontdata[fontdata$FamilyName == family,,drop = FALSE]
		result <- rep(NA, 4)
		for (i in seq_len(nrow(fontdata))) {
			index <- with(fontdata, getIndex(Bold[i], Italic[i]))
			if (is.na(result[index]))
				result[index] <- fontdata$fontfile[i]
		}
		value <- result[1]
		# Propagate to more conditions
		for (i in 2:4)
			if (is.na(result[i]))
				result[i] <- result[i-1]
		# Propagate to fewer
		for (i in 3:1)
			if (is.na(result[i]))
				result[i] <- result[i+1]
		result
	}
	
	register_family_rgl <- function(family) {
		# Now we can register the font with rgl with something like this:
		# rglFonts("Arial" = rglFont("Arial"))
		if (family %in% cfonts) {
			if (!quiet) {
				message(family, " already registered with rglFonts().")
			}
			return(NULL)
		}
		if (!quiet) {
			message("Registering font with R using rglFonts(): ", family)
		}
		# Since 'family' is a string containing the name of the argument, we
		# need to use do.call
		args <- list()
		args[[family]] <- makeRglFont(family)
		if (!is.null(args[[family]]))
			do.call(rglFonts, args)
	}
	
	if (!requireNamespace("extrafont"))
		stop("This function requires the extrafont package.")
	
	fontdata <- extrafont::fonttable()
	# remove empty FamilyNames
	fontdata <- fontdata[fontdata$FamilyName != "", , drop = FALSE]
	families <- unique(fontdata$FamilyName)
	# If args were given, limit attention to those
	args <- list(...)
	if (length(args))
		families <- intersect(families, args)
	cfonts <- names(rglFonts())
	lapply(families, register_family_rgl)
	allfonts <- rglFonts()
	names <- names(args)
	for (i in seq_along(names)) {
		origname <- args[[names[i]]]
		if (origname %in% names(allfonts)) {
			font <- allfonts[[origname]]
			arg <- list()
			arg[[names[i]]] <- font
			do.call(rglFonts, arg)
		}
	}
}

rglExtrafonts <- function(..., quiet = TRUE) {
	if (!requireNamespace("extrafont"))
		return()
	
	args <- list(...)
	names <- names(args)
	result <- character()
	if (is.null(names))
		names <- rep("", length(args))
	for (i in seq_along(args)) {
		choices <- args[[i]]
		if (length(choices)) {
		  font <- extrafont::choose_font(choices)
		  result[i] <- font
		  if (nchar(font)) {
		  	arg <- list(quiet = quiet)
		  	if (!nchar(names[i]))
		  		names[i] <- font
		  	arg[[names[i]]] <- font
		  	do.call(loadfonts_rgl, arg)
		  } else
		  	warning("Fonts ", paste0('"', choices, '"', collapse = ", "), " not found.")
		}
	}
	names(result) <- names
  invisible(result)
}
