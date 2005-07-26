\name{sprites}
\alias{rgl.sprites}
\alias{sprites3d}
\title{add sprite set shape}
\description{
  Adds a sprite set shape node to the scene.
}
\usage{
sprites3d(x, y, z, radius = 1, ...)
rgl.sprites(x, y, z, radius = 1, ...)
}
\arguments{
  \item{ x, y, z }{point coordinates}
  \item{ radius } {vector or singe value defining the sphere radius}
  \item{ ... }{material properties, texture mapping is supported}
}
\details{
  Sprites are rectangle planes that are directed towards the viewpoint.
  Their primary use is for fast (and faked) atmospherical effects, e.g. particles and clouds
  using alpha blended textures.
}
\examples{
sprites3d(rnorm(500), rnorm(500), rnorm(500), color=rainbow(100), lit=FALSE,
            textype="alpha", texture=system.file("textures/particle.png", package="rgl"), 
            alpha=.2)
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
