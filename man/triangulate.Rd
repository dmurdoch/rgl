\name{triangulate}
\alias{triangulate}
\title{
Triangulate a two-dimensional polygon
}
\description{
This algorithm decomposes a general polygon into simple
polygons and uses the \dQuote{ear-clipping} algorithm to triangulate it.
Polygons with holes are supported.
}
\usage{
triangulate(x, y = NULL, z = NULL, random = TRUE, plot = FALSE, partial = NA)
}
\arguments{
  \item{x, y, z}{
Coordinates of a two-dimensional polygon in a format supported by \code{\link{xyz.coords}}.  
See Details for a description of proper input and
how \code{z} is handled.
}
  \item{random}{
Currently ignored, the triangulation
is deterministic.
}
  \item{plot}{
Whether to plot the triangulation; mainly for debugging purposes.
}
  \item{partial}{
Currently ignored. Improper input will lead to undefined 
results.
}
}
\details{
Normally \code{triangulate} looks only at the \code{x} and \code{y}
coordinates.  However, if one of those is constant, it is replaced
with the \code{z} coordinate if present.

The algorithm works as follows.  First, it breaks the polygon into 
pieces separated by \code{NA} values in \code{x} or \code{y}.
Each of these pieces should be a simple, non-self-intersecting
polygon, not intersecting the other pieces. 
(Though some minor exceptions to this rule may work, none
are guaranteed).  The nesting of these pieces is
determined:  polygons may contain holes, and the
holes may contain other polygons.  

Vertex order around the polygons does not affect
the results:  whether a polygon is on the outside 
or inside of a region is determined by nesting.

Polygons should not repeat vertices.  An attempt is 
made to detect if the final vertex matches the first
one.  If so, it will be deleted with a warning.

The \dQuote{outer} polygon(s) are then merged with the
polygons that they immediately contain, and each of these
pieces is triangulated using the ear-clipping algorithm from the references.

Finally, all the triangulated pieces are put together into one
result.
}
\value{
A three-by-n array giving the indices of the vertices of 
each triangle.  (No vertices are added; only the original
vertices are used in the triangulation.)

The array has an integer vector attribute \code{"nextvert"}
with one entry per vertex, giving the index of the next 
vertex to proceed counter-clockwise around outer
polygon boundaries, clockwise around inner boundaries.
}
\references{
This function uses the C++ version of the
\code{earcut} library from \url{https://github.com/mapbox/earcut.hpp}.
}
\author{
R wrapper code written by Duncan Murdoch; the
\code{earcut} library has numerous authors.
}
\note{
Not all inputs will succeed, though inputs satisfying
the rules listed in the Details section should.
}
\seealso{
\code{\link{extrude3d}} for a solid extrusion of a polygon, \code{\link{polygon3d}} for
a flat display; both use \code{triangulate}.
}
\examples{
theta <- seq(0, 2*pi, length.out = 25)[-25]
theta <- c(theta, NA, theta, NA, theta, NA, theta, NA, theta)
r <- c(rep(1.5, 24), NA, rep(0.5, 24), NA, rep(0.5, 24), NA, rep(0.3, 24), NA, rep(0.1, 24))
dx <- c(rep(0, 24), NA, rep(0.6, 24), NA, rep(-0.6, 24), NA, rep(-0.6, 24), NA, rep(-0.6, 24))
x <- r*cos(theta) + dx
y <- r*sin(theta)
plot(x, y, type = "n")
polygon(x, y)
triangulate(x, y, plot = TRUE)
open3d()
polygon3d(x, y, x - y, col = "red")
}
\keyword{ graphics }
