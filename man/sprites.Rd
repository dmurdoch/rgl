\name{sprites}
\alias{sprites3d}
\alias{particles3d}
\alias{rgl.sprites}
\title{add sprite set shape}
\description{
  Adds a sprite set shape node to the scene.
}
\usage{
sprites3d(x, y = NULL, z = NULL, radius = 1, ...)
particles3d(x, y = NULL, z = NULL, radius = 1, ...)
rgl.sprites(x, y = NULL, z = NULL, radius = 1, ...)
}
\arguments{
  \item{ x, y, z }{point coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{ radius }{vector or single value defining the sphere radius}
  \item{ ... }{material properties, texture mapping is supported}
}
\details{
  Sprites are rectangle planes that are directed towards the viewpoint.
  Their primary use is for fast (and faked) atmospherical effects, e.g. particles and clouds
  using alpha blended textures.
  Particles are Sprites using an alpha-blended particle texture giving
  the illusion of clouds and gasses.
  
  If any coordinate is \code{NA}, the sprite is not plotted.
}
\value{
  These functions are called for the side effect of displaying the sprites.
  The shape ID of the displayed object is returned.
}
\examples{
open3d()
particles3d( rnorm(100), rnorm(100), rnorm(100), color=rainbow(100) )
# is the same as
sprites3d( rnorm(100), rnorm(100), rnorm(100), color=rainbow(100),
  lit=FALSE, alpha=.2,
  textype="alpha", texture=system.file("textures/particle.png", package="rgl") )
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}

