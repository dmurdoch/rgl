\name{rgl.fns}
\alias{rgl.spheres}
\title{
Low level functions that should not be called by users.
}
\description{
These functions provide the implementation for various
\code{*3d} functions designed for users to call.
}
\usage{
rgl.spheres(x, y = NULL, z = NULL, radius, fastTransparency = TRUE, ...)
}
\arguments{
  \item{x, y, z}{
Coordinates of points
} 
  \item{radius}{Size of sprites or spheres.}
  \item{fastTransparency}{Sphere drawing strategy.}
  \item{...}{
Material properties.
}

}
\details{
See the corresponding \code{*3d} function: \code{\link{abclines3d}}, \code{\link{planes3d}}, \code{\link{clipplanes3d}}, \code{\link{sprites3d}}, \code{\link{spheres3d}}.
}
\keyword{internal}
