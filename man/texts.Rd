\name{rgl.texts}
\alias{rgl.texts}
\title{add text set shape}
\description{
  Adds a set of text to scene, the text is positioned in 3D space. 
  A bitmap font is used, so that it is always oriented towards the camera.
}
\usage{
rgl.texts(x, y, z, text, justify, ...)
}
\arguments{
  \item{x, y, z}{point coordinates}
  \item{text}{text character vector to draw}
  \item{justify}{ a character string specifying the horizontal text layout,
    can be one of \code{"left"}, \code{"right"}, \code{"center"}.
  }
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
}
\details{
}
\examples{
rgl.texts(rnorm(10)*100,rnorm(10)*100,rnorm(10)*100,text=1:10,justify="center", color=heat.colors(10))
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
