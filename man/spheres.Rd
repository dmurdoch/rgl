\name{rgl.spheres}
\alias{rgl.spheres}
\title{add sphere set shape}
\description{
  Adds a sphere set shape node to the scene
}
\usage{
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
rgl.spheres(rnorm(10), rnorm(10), rnorm(10), radius=.2, color=rainbow(10))
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
