\name{rgl.fns}
\alias{rgl.abclines}
\alias{rgl.planes}
\alias{rgl.clipplanes}
\alias{rgl.sprites}
\alias{rgl.spheres}
\alias{rgl.clear}
\alias{rgl.pop}
\alias{rgl.ids}
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
            shapes = NULL, userMatrix, fixedSize = FALSE, ...)
rgl.spheres(x, y = NULL, z = NULL, radius, fastTransparency = TRUE, ...)
rgl.clear( type = "shapes", subscene = 0 )
rgl.pop( type = "shapes", id = 0 )  
rgl.ids( type = "shapes", subscene = NA )
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
  \item{fastTransparency}{Sphere drawing strategy.}
  \item{type, id, subscene}{Selecting objects.}
  \item{...}{
Material properties.
}

}
\details{
See the corresponding \code{*3d} function: \code{\link{abclines3d}}, \code{\link{planes3d}}, \code{\link{clipplanes3d}}, \code{\link{sprites3d}}, \code{\link{spheres3d}}.
}
\keyword{internal}
