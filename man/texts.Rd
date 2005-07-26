\name{texts}
\alias{rgl.texts}
\alias{text3d}
\title{add text}
\description{
  Adds text to the scene. The text is positioned in 3D space. 
  A bitmap font which is always oriented towards the camera is used.
}
\usage{
rgl.texts(x, y, z, text, adj = 0.5, justify, ...)
text3d(x, y, z, text, adj = 0.5, justify, ...) 
}
\arguments{
  \item{x, y, z}{point coordinates}
  \item{text}{text character vector to draw}
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
}
\examples{
text3d(rnorm(10)*100,rnorm(10)*100,rnorm(10)*100,text=1:10,adj = 0.5, color=heat.colors(10))
}
\seealso{
  \code{\link{r3d}}
}
\keyword{dynamic}
