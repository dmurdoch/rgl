# The rgl font database is only used when rgl is configured for FreeType.  
# Since 0.105.13 this is always true on Windows, but since 0.106.2
# r3dDefaults sets useFreeType to FALSE, so the windowsFonts() are used instead.

# This code is closely modelled on the Quartz font database.

.rglEnv <- new.env()

assign(".rglFonts", list(), envir = .rglEnv)

# Check that the font has the correct structure and information
checkrglFont <- function(font) {
    if (!is.character(font) || length(font) != 4)
        stop("Invalid rgl font:  must be 4 filenames")
    font
}

setrglFonts <- function(fonts, fontNames) {
    fonts <- lapply(fonts, checkrglFont)
    fontDB <- get(".rglFonts", envir=.rglEnv)
    existingFonts <- fontNames %in% names(fontDB)
    if (sum(existingFonts) > 0)
        fontDB[fontNames[existingFonts]] <- fonts[existingFonts]
    if (sum(existingFonts) < length(fontNames))
        fontDB <- c(fontDB, fonts[!existingFonts])
    assign(".rglFonts", fontDB, envir=.rglEnv)
}

printFont <- function(font) {
    paste(font, "\n", sep="")
}

printFonts <- function(fonts) {
    cat(paste(names(fonts), ": ", unlist(lapply(fonts, printFont)),
              sep="", collapse=""))
}

# If no arguments spec'ed, return entire font database
# If no named arguments spec'ed, all args should be font names
# to get info on them from the database
# Else, must specify new fonts to enter into database (all
# of which must be valid filenames and
# all of which must be named args)
rglFonts <- function(...) {
  ndots <- length(fonts <- list(...))
  if (ndots==0) {
    get(".rglFonts", .rglEnv)
  } else {
    fontNames <- names(fonts)
    nnames <- length(fontNames)
    if (nnames == 0) {
      if (!all(sapply(fonts, is.character))) {
        stop("Invalid arguments in 'rglFonts' (must be font names)")
      } else {
        get(".rglFonts", .rglEnv)[unlist(fonts)]
      }
    } else {
      if (ndots != nnames) {
        stop("Invalid arguments in 'rglFonts' (need named args)")
      }
      setrglFonts(fonts, fontNames)
    }
  }
}

rglFont <- function(family) {
  checkrglFont(family)
}
