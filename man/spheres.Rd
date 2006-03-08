\name{spheres}
\alias{rgl.spheres}
\alias{spheres3d}
\title{add sphere set shape}
\description{
  Adds a sphere set shape node to the scene
}
\usage{
spheres3d(x, y = NULL, z = NULL, radius = 1, ...)
rgl.spheres(x, y = NULL, z = NULL, radius, ...)
}
\arguments{
  \item{x, y, z}{Numeric vector of point coordinates corresponding to
   the center of each sphere.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{radius}{Vector or single value defining the sphere radius/radii}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}
}
\examples{
spheres3d(rnorm(10), rnorm(10), rnorm(10), radius=runif(10), color=rainbow(10))
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
