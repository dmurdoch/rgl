\name{texts}
\alias{rgl.texts}
\alias{text3d}
\alias{texts3d}
\title{add text}
\description{
  Adds text to the scene. The text is positioned in 3D space. 
  A bitmap font which is always oriented towards the camera is used.
}
\usage{
rgl.texts(x, y = NULL, z = NULL, text, adj = 0.5, justify, ...)
text3d(x, y = NULL, z = NULL, texts, adj = 0.5, justify, ...) 
texts3d(x, y = NULL, z = NULL, texts, adj = 0.5, justify, ...) 
}
\arguments{
  \item{x, y, z}{point coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{text}{text character vector to draw}
  \item{texts}{text character vector to draw}
  \item{adj}{ one value specifying the horizontal adjustment }.
  \item{justify}{(deprecated, please use adj instead) character string
specifying the horizontal adjustment; options are \code{"left"}, \code{"right"},
    \code{"center"}.
  }
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
}
\details{
The \code{adj} parameter determines the position of the text relative to the 
specified coordinate.  Use \code{adj = 0} to place the left bottom corner at
\code{(x,y,z)}, \code{adj = 0.5} to center the text there, and \code{adj = 1}
to put the right bottom corner there.

\code{text3d} and \code{texts3d} draw text using the \link{r3d}
conventions. These are synonyms; the former is singular to be
consistent with the classic 2-D graphics functions, and the latter is
plural to be consistent with all the other graphics primitives.  Take
your choice!

}
\value{
  The object ID of the text object is returned invisibly.
}
\examples{
open3d()
text3d(rnorm(10)*100,rnorm(10)*100,rnorm(10)*100,text=1:10,adj = 0.5, color=heat.colors(10))
}
\seealso{
  \code{\link{r3d}}
}
\keyword{dynamic}
