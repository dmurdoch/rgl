\name{text3d}
\alias{rgl.texts}
\alias{text3d}
\alias{texts3d}
\alias{rglFonts}
\title{add text}
\description{
  Adds text to the scene. The text is positioned in 3D space. 
  Text is always oriented towards the camera.
}
\usage{
rgl.texts(x, y = NULL, z = NULL, text, 
            adj = 0.5, justify, family = par3d("family"), font = par3d("font"), 
            cex = par3d("cex"), useFreeType = par3d("useFreeType"), ...)
text3d(x, y = NULL, z = NULL, texts, adj = 0.5, justify,
       usePlotmath = is.language(texts), ...) 
texts3d(x, y = NULL, z = NULL, texts, adj = 0.5, justify,
       usePlotmath = is.language(texts), ...) 
rglFonts(...)
}
\arguments{
  \item{x, y, z}{point coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{text}{text character vector to draw}
  \item{texts}{text character vector to draw}
  \item{adj}{ one value specifying the horizontal adjustment, or two, 
              specifying horizontal and vertical adjustment respectively. }.
  \item{justify}{(deprecated, please use adj instead) character string
specifying the horizontal adjustment; options are \code{"left"}, \code{"right"},
    \code{"center"}.  Ignored if \code{usePlotmath = TRUE}.
  }
  \item{ family }{A device-independent font family name, or "" }
  \item{ font }{A numeric font number from 1 to 5 }
  \item{ cex }{A numeric character expansion value }
  \item{ useFreeType }{logical.  Should FreeType be used to draw text? (See details below.)}
  \item{ usePlotmath }{logical.  Should \code{\link{plotmath3d}} be used for the text?}
  \item{ ... }{In \code{rgl.texts}, material properties; see \code{\link{rgl.material}} for details.
                 In \code{rglFonts}, device dependent font definitions for use with FreeType.
                 In the other functions, additional parameters to pass to \code{rgl.texts}.}  
}
\details{
The \code{adj} parameter determines the position of the text relative to the 
specified coordinate.  Use \code{adj = c(0, 0)} to place the left bottom corner at
\code{(x, y, z)}, \code{adj = c(0.5, 0.5)} to center the text there, and \code{adj = c(1, 1)}
to put the right top corner there. The optional second coordinate for vertical 
adjustment defaults to \code{0.5}.  Placement is done using the "advance" of
the string and the "ascent" of the font relative to the baseline, when these metrics
are known.

\code{text3d} and \code{texts3d} draw text using the \link{r3d}
conventions. These are synonyms; the former is singular to be
consistent with the classic 2-D graphics functions, and the latter is
plural to be consistent with all the other graphics primitives.  Take
your choice!

If any coordinate or text is \code{NA}, that text is not plotted.

If \code{usePlotmath} is \code{TRUE}, the work will be done
by the \code{\link{plotmath3d}} function instead of \code{rgl.texts}.  This is the default if the \code{texts}
parameter is \dQuote{language}, e.g. the result of
a call to \code{\link{expression}} or \code{\link{quote}}.
}
\section{Fonts}{
Fonts are specified using the \code{family}, \code{font}, \code{cex}, 
and \code{useFreeType} arguments.  Defaults for the currently active
device may be set using \code{\link{par3d}}, or for future devices
using \code{\link{r3dDefaults}}.

The \code{family} specification is the same as for standard graphics, i.e.
families \cr
\code{c("serif", "sans", "mono", "symbol")} \cr
are normally
available, but users may add additional families.  \code{font} numbers
are restricted to the range 1 to 4 for standard, bold, italic and bold italic
respectively; with font 5 recoded as family \code{"symbol"} font 1.  

Using an unrecognized value for \code{"family"} will result in
the system standard font as used in rgl up to version 0.76.  That font
is not resizable and \code{font} values are ignored.

If \code{useFreeType} is \code{TRUE}, then rgl will use the FreeType
anti-aliased fonts for drawing.  This is generally desirable, and it is the
default if rgl was built to support FreeType.  

FreeType fonts are specified using the \code{rglFonts} function.  This function
takes a vector of four filenames of TrueType font files which
will be used for the four styles regular, bold, italic and bold italic.  The
vector is passed with a name to be used as the family name, e.g.
\code{rglFonts(sans = c("/path/to/FreeSans.ttf", ...))}.  In order to 
limit the file size, \code{rgl} ships with just 3 font files, for 
regular versions of the \code{serif}, \code{sans} and \code{mono} families.  
Additional free font files are available from the Amaya project at
\url{http://dev.w3.org/cvsweb/Amaya/fonts/}.  See the example below for
how to specify a full set of fonts.

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
  The text drawing functions return the object ID of the text object (or sprites, in case of \code{usePlotmath = TRUE})
invisibly.

  \code{rglFonts} returns the current set of font definitions.
}
\examples{
open3d()
famnum <- rep(1:4, 8)
family <- c("serif", "sans", "mono", "symbol")[famnum]
font <- rep(rep(1:4, each = 4), 2)
cex <- rep(1:2, each = 16)
text3d(font, cex, famnum, text = paste(family, font), adj = 0.5, 
       color = "blue", family = family, font = font, cex = cex)
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
\seealso{
  \code{\link{r3d}}, \code{\link{plotmath3d}}
}
\keyword{dynamic}
