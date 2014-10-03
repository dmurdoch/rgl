\name{polygon3d}
\alias{polygon3d}
\title{
Triangulate and draw a polygon in three dimensions.
}
\description{
This function takes a description of a flat polygon in x, y and z coordinates,
and draws it in three dimensions.
}
\usage{
polygon3d(x, y = NULL, z = NULL, fill = TRUE, plot = TRUE, 
          coords = 1:2, random = TRUE, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x, y, z}{
Vertices of the polygon in a form accepted by \code{\link{xyz.coords}}.
}
  \item{fill}{
logical; should the polygon be filled?
}
  \item{plot}{
logical; should the polygon be displayed?
}
  \item{coords}{
Which two coordinates (\code{x=1}, \code{y=2}, \code{z=3}) describe the
polygon.  
}
  \item{random}{
Should a random triangulation be used?
}
  \item{\dots}{
Other parameters to pass to \code{\link{lines3d}} or \code{\link{shade3d}} if \code{plot = TRUE}.
}
}
\details{
The function triangulates the two dimensional polygon described by \code{coords}, then
applies the triangulation to all three coordinates.  No check is made that the polygon
is actually all in one plane, but the results may be somewhat unpredictable
(especially if \code{random = TRUE}) if it is not.

Polygons need not be simple; use \code{NA} to indicate separate closed pieces.  For
\code{fill = FALSE} there are no other restrictions on the pieces, but for 
\code{fill = TRUE} the resulting two-dimensional polygon needs to be one that
\code{\link{triangulate}} can handle.
}
\value{
If \code{plot = TRUE}, the id number of the lines (for \code{fill = FALSE}) or triangles
(for \code{fill = TRUE}) that have been plotted.

If \code{plot = FALSE}, then for \code{fill = FALSE}, a vector of indices into
the XYZ matrix that could be used to draw the polygon.  For \code{fill = TRUE}, 
a triangular mesh object representing the triangulation.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{extrude3d}} for a solid extrusion of a polygon, \code{\link{triangulate}} for
the triangulation.
}
\examples{
theta <- seq(0, 4*pi, len=50)
r <- theta + 1
r <- c(r[-50], rev(theta*0.8) + 1)
theta <- c(theta[-50], rev(theta))
x <- r*cos(theta)
y <- r*sin(theta)
plot(x,y,type="n")
polygon(x, y)
polygon3d(x, y, x+y, col = "blue")
}
\keyword{ graphics }
