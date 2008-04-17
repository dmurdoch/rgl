# The rgl font database is only used when rgl is configured for freetype.  
# Usually this is not true in Windows, and the windowsFonts are used instead.

# This code is closely modelled on the Quartz font database.

.rglEnv <- new.env()

assign(".rglFonts", list(), envir = .rglEnv)

# Check that the font has the correct structure and information
checkrglFont <- function(font) {
    if (!is.character(font) || length(font) != 4)
        stop("invalid rgl font:  must be 4 filenames")
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
# to get info on from the database
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
        stop(gettextf("invalid arguments in '%s' (must be font names)",
                      "rglFonts"), domain = NA)
      } else {
        get(".rglFonts", .rglEnv)[unlist(fonts)]
      }
    } else {
      if (ndots != nnames) {
        stop(gettextf("invalid arguments in '%s' (need named args)",
                      "rglFonts"), domain = NA)
      }
      setrglFonts(fonts, fontNames)
    }
  }
}

rglFont <- function(family) {
  checkrglFont(family)
}

if ( .Platform$OS.type == "windows" ) {
   rglFonts(       serif = rglFont(c("times.ttf", "timesbd.ttf", "timesi.ttf", "timesbi.ttf")),
                   sans = rglFont(c("arial.ttf", "arialbd.ttf", "ariali.ttf", "arialbi.ttf")),
                   mono = rglFont(c("cour.ttf", "courbd.ttf", "couri.ttf", "courbi.ttf")),
                   symbol = rglFont(rep("symbol.ttf", 4)))
} else {
  local({ 
          rglFonts(serif = rep(system.file("fonts/FreeSerif.ttf", package="rgl"), 4),
                   sans  = rep(system.file("fonts/FreeSans.ttf", package="rgl"), 4),
                   mono  = rep(system.file("fonts/FreeMono.ttf", package="rgl"), 4),
                   symbol = rep(system.file("fonts/FreeSerif.ttf", package="rgl"), 4)) })
}
