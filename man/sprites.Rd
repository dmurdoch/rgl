\name{rgl.sprites}
\alias{rgl.sprites}
\title{add sprite set shape}
\description{
  Adds a sprite set shape node to the scene.
}
\usage{
rgl.sprites(x, y, z, radius, ...)
}
\arguments{
  \item{ x, y, z }{point coordinates}
  \item{ radius } {vector or singe value defining the sphere radius}
  \item{ ... }{material properties, texture mapping is supported}
}
\details{
  Sprites are rectangle planes that are billboarded towards the viewpoint.
  Its primary used for fast faked atmospherical effects e.g. particles and clouds
  using alpha blending textures.
}
\examples{
rgl.sprites(rnorm(500),rnorm(500),rnorm(500),color=rainbow(100),lit=FALSE,textype="alpha",texture=system.file("textures/particle.png",package="rgl"),alpha=0.2)
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
