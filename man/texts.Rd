\name{text3d}
\alias{text3d}
\alias{texts3d}
\title{Add text to plot}
\description{
  Adds text to the scene. The text is positioned in 3D space. 
  Text is always oriented towards the camera.
}
\usage{
text3d(x, y = NULL, z = NULL, texts, adj = 0.5, pos = NULL, offset = 0.5,
       usePlotmath = is.language(texts), 
       family = par3d("family"), font = par3d("font"), 
			 cex = par3d("cex"), useFreeType = par3d("useFreeType"),
			...) 
texts3d(x, y = NULL, z = NULL, texts, adj = 0.5, pos = NULL, offset = 0.5,
       usePlotmath = is.language(texts),
       family = par3d("family"), font = par3d("font"), 
			 cex = par3d("cex"), useFreeType = par3d("useFreeType"),
			...)       
}
\arguments{
  \item{x, y, z}{point coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{texts}{text character vector to draw}
  \item{adj}{ one value specifying the horizontal adjustment, or two, 
              specifying horizontal and vertical adjustment respectively, or three, specifying adjustment in all
              three directions.}
  \item{pos}{ a position specifier for the text.  If specified, this
  overrides any \code{adj} value given. Values of 0, 1, 2, 3, 4, 5, 6 respectively indicate positions at, below, to the left of, above, to the right of, in front of, and behind the specified coordinates.}
  \item{offset}{ when \code{pos} is specified, this value gives the offset of the label from the specified coordinate in fractions of a character width.}
  \item{ usePlotmath }{logical.  Should \code{\link{plotmath3d}} be used for the text?}
  \item{ family }{A device-independent font family name, or "" }
  \item{ font }{A numeric font number from 1 to 4 }
  \item{ cex }{A numeric character expansion value }
  \item{ useFreeType }{logical.  Should FreeType be used to draw text? (See details below.)}
  \item{ ... }{Material properties; see \code{\link{material3d}} for details.} 
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
by the \code{\link{plotmath3d}} function.  This is the default
if the \code{texts}
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
respectively.  Font 5 is recoded as family \code{"symbol"}
font 1, but that is not supported unless specifically
installed, so should be avoided.

Using an unrecognized value for \code{"family"} will result in
the system standard font as used in RGL up to version 0.76.  That font
is not resizable and \code{font} values are ignored.

If \code{useFreeType} is \code{TRUE}, then RGL will use the FreeType
anti-aliased fonts for drawing.  This is generally desirable, and it is the
default on non-Windows systems if RGL was built to support FreeType.

FreeType fonts are specified using the \code{\link{rglFonts}} function. 
}
\value{
  The text drawing functions return the object ID of the text object (or sprites, in case of \code{usePlotmath = TRUE})
invisibly.
}
\examples{
open3d()
famnum <- rep(1:3, 8)
family <- c("serif", "sans", "mono")[famnum]
font <- rep(rep(1:4, each = 3), 2)
cex <- rep(1:2, each = 12)
text3d(font, cex, famnum, texts = paste(family, font), adj = 0.5, 
       color = "blue", family = family, font = font, cex = cex)
}
\seealso{
  \code{\link{r3d}}, \code{\link{plotmath3d}}, \code{\link{rglExtrafonts}} for adding fonts
}
\keyword{dynamic}
