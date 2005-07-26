\name{spheres}
\alias{rgl.spheres}
\alias{spheres3d}
\title{add sphere set shape}
\description{
  Adds a sphere set shape node to the scene
}
\usage{
spheres3d(x, y, z, radius, ...)
rgl.spheres(x, y, z, radius, ...)
}
\arguments{
  \item{x, y, z}{Point coordinates}
  \item{radius}{Vector or singe value defining the sphere radius}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}
}
\details{
}
\examples{
spheres3d(rnorm(10), rnorm(10), rnorm(10), radius=runif(10), color=rainbow(10))
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
