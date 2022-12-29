\name{rgl.fns}
\alias{rgl.abclines}
\alias{rgl.planes}
\alias{rgl.clipplanes}
\alias{rgl.sprites}
\alias{rgl.spheres}
\alias{rgl.pop}
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
rgl.sprites(x, y = NULL, z = NULL, radius = 1, 
            shapes = NULL, userMatrix, fixedSize = FALSE,
            adj = 0.5, pos = NULL, offset = 0.25, 
            rotating = FALSE, ...)
rgl.spheres(x, y = NULL, z = NULL, radius, fastTransparency = TRUE, ...)
rgl.pop( type = "shapes", id = 0, tag = NULL )  
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
  \item{radius}{Size of sprites or spheres.}
  \item{fixedSize, rotating}{Fixed size, changing orientation.}
  \item{fastTransparency}{Sphere drawing strategy.}
  \item{type, id, subscene}{Selecting objects.}
  \item{adj, pos, offset}{Positioning.}
  \item{tag}{Select objects with material property
  \code{tag} in this vector.}
  \item{tags}{Whether to return tags.}
  \item{...}{
Material properties.
}

}
\details{
See the corresponding \code{*3d} function: \code{\link{abclines3d}}, \code{\link{planes3d}}, \code{\link{clipplanes3d}}, \code{\link{sprites3d}}, \code{\link{spheres3d}}.
}
\keyword{internal}
