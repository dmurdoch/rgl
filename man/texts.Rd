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
       usePlotmath = is.language(texts), ...) 
texts3d(x, y = NULL, z = NULL, texts, adj = 0.5, pos = NULL, offset = 0.5,
       usePlotmath = is.language(texts), ...) 
}
\arguments{
  \item{x, y, z}{point coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{texts}{text character vector to draw}
  \item{adj}{ one value specifying the horizontal adjustment, or two, 
              specifying horizontal and vertical adjustment respectively. }
  \item{pos}{ a position specifier for the text.  If specified, this
  overrides any \code{adj} value given. Values of 1, 2, 3 and 4, respectively indicate positions below, to the left of, above and to the right of the specified coordinates.}
  \item{offset}{ when \code{pos} is specified, this value gives the offset of the label from the specified coordinate in fractions of a character width.}
  \item{ usePlotmath }{logical.  Should \code{\link{plotmath3d}} be used for the text?}
  \item{ ... }{In the other functions, additional parameters to pass to \code{rgl.texts}.}  
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
\value{
  The text drawing functions return the object ID of the text object (or sprites, in case of \code{usePlotmath = TRUE})
invisibly.
}
\seealso{\code{\link{rglExtrafonts}} for adding fonts}
\examples{
open3d()
famnum <- rep(1:3, 8)
family <- c("serif", "sans", "mono")[famnum]
font <- rep(rep(1:4, each = 3), 2)
cex <- rep(1:2, each = 12)
text3d(font, cex, famnum, text = paste(family, font), adj = 0.5, 
       color = "blue", family = family, font = font, cex = cex)
}
\seealso{
  \code{\link{r3d}}, \code{\link{rgl.texts}}, \code{\link{plotmath3d}}
}
\keyword{dynamic}
