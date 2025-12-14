\name{rglFonts}
\alias{rglFonts}
\title{
Specify FreeType fonts
}
\description{
Specify FreeType fonts for use in \pkg{rgl} graphics.
}
\usage{
rglFonts(...)
}
\arguments{
  \item{ ... }{Device dependent font definitions for use with FreeType.}  
}
\details{
By default, \pkg{rgl} uses system fonts on all platforms.
This function allows the defaults to be overridden by
specifying 
FreeType font files.  These files are only used if
\code{par3d("useFreeType")} is set to \code{TRUE}.

\code{rglFonts}
takes a vector of four filenames of TrueType font files which
will be used for the four styles regular, bold, italic and bold italic.  The
vector is passed with a name to be used as the family name, e.g.
\code{rglFonts(sans = c("/path/to/FreeSans.ttf", ...))}.  In order to 
limit the file size, the \pkg{rgl} package ships with just 3 font files, for 
regular versions of the \code{serif}, \code{sans} and \code{mono} families.  
Additional free font files were available in the past from the
Amaya project, though currently the
\code{\link{rglExtrafonts}} function provides an easier way
to register new fonts.

On Windows the system fonts are acceptable and are used
when \code{useFreeType = FALSE} (the current default in
\code{\link{r3dDefaults}}).  Mappings to \code{family} names
are controlled by the \code{grDevices::windowsFonts()}
function.

Full pathnames should normally be used to specify font files.  If relative
paths are used, they are interpreted differently by platform.  Currently
Windows fonts are looked for in the Windows fonts folder, while other
platforms use the current working directory.

If FreeType fonts are not used, then bitmapped fonts will be used instead.
On Windows these will be based on the fonts specified using the 
#ifdef windows
\code{\link{windowsFonts}} 
#endif
#ifndef windows
\code{windowsFonts}
#endif
function, and are resizable.
Other platforms will use the default bitmapped font which is not
resizable.  

Bitmapped fonts have a limited number of characters supported; if any
unsupported characters are used, an error will be thrown.
}
\value{
the current set of font definitions.
}
\seealso{\code{\link{text3d}}}
\examples{
\dontrun{
# These FreeType fonts are available from the Amaya project, and are not shipped
# with rgl.  You would normally install them to the rgl/fonts directory
# and use fully qualified pathnames, e.g. 
# system.file("fonts/FreeSerif.ttf", package = "rgl")

rglFonts(serif = c("FreeSerif.ttf", "FreeSerifBold.ttf", "FreeSerifItalic.ttf",
                 "FreeSerifBoldItalic.ttf"),
         sans  = c("FreeSans.ttf", "FreeSansBold.ttf", "FreeSansOblique.ttf",
                 "FreeSansBoldOblique.ttf"),
         mono  = c("FreeMono.ttf", "FreeMonoBold.ttf", "FreeMonoOblique.ttf",
                 "FreeMonoBoldOblique.ttf"),
         symbol= c("ESSTIX10.TTF", "ESSTIX12.TTF", "ESSTIX9_.TTF", 
                 "ESSTIX11.TTF"))
} 
}
