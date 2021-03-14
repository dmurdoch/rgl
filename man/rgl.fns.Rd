\name{rgl.fns}
\alias{rgl.abclines}
\alias{rgl.planes}
\alias{rgl.clipplanes}
\title{
Low level functions that should not be called by users.
}
\description{
These functions provide the implementation for various
\code{*3d} functions designed for users to call.
}
\usage{
rgl.abclines(x, y = NULL, z = NULL, a, b = NULL, c = NULL, ...)
rgl.planes(a, b = NULL, c = NULL, d = 0, ...)
rgl.clipplanes(a, b = NULL, c = NULL, d = 0)
}
\arguments{
  \item{x, y, z}{
Coordinates of points
} 
  \item{a, b, c}{
Coordinates of the direction vectors for the lines,
or normals for the planes.
}
  \item{d}{Plane offset.}
  \item{...}{
Material properties.
}

}
\details{
See the corresponding \code{*3d} function: \code{\link{abclines3d}}, \code{\link{planes3d}}, \code{\link{clipplanes3d}}.
}
\keyword{internal}