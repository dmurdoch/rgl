\name{rgl.pixels}
\alias{rgl.pixels}
\title{ Extract pixel information from window }
\description{
This function extracts single components of the pixel information from the 
topmost window.
}
\usage{
rgl.pixels(component = c("red", "green", "blue"), 
        viewport = par3d("viewport"), top = TRUE)
}
\arguments{  
  \item{component}{ Which component(s)? }
  \item{viewport}{ Lower left corner and size of desired region. }
  \item{top}{ Whether to bring window to top before reading. }
}
\details{
The possible components are \code{"red"}, \code{"green"}, \code{"blue"}, 
\code{"alpha"}, \code{"depth"}, and \code{"luminance"} (the sum of the three
colors).  All are scaled from 0 to 1.

Note that the luminance is kept below 1 by truncating the sum; this is the 
definition used for the \code{GL_LUMINANCE} component in OpenGL.
}
\value{
A vector, matrix or array containing the desired components.  If one component
is requested, a vector or matrix will be returned depending on the size of
block requested (length 1 dimensions are dropped); if more, an array, whose last dimension
is the list of components.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{rgl.snapshot}} to write a copy to a file,
\code{demo("stereo")} for functions that make use of this to draw
a random dot stereogram and an anaglyph. }
\examples{
example(surface3d)
depth <- rgl.pixels(component = "depth")
if (length(depth) && is.matrix(depth)) # Protect against empty or single pixel windows
    contour(depth)
}
\keyword{ dynamic }
