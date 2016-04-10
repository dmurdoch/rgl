\name{persp3d.deldir}
\alias{persp3d.deldir}
\alias{plot3d.deldir}
\title{
Plot a Delaunay triangulation.
}
\description{
The \code{\link[deldir]{deldir}()} function in the \pkg{deldir} package computes a Delaunay triangulation of a set
of points.  This function displays it as a surface.
}
\usage{
\method{persp3d}{deldir}(x, col = "gray", coords = c("x", "y", "z"), ...)
\method{plot3d}{deldir}(x, ...)
}
\arguments{
  \item{x}{
A \code{"deldir"} object, produced by the \code{\link[deldir]{deldir}()} function, that contains \code{z} values.
}
  \item{col}{
Colors to apply to each vertex in the triangulation.
Will be recycled as needed.
}
  \item{coords}{
See Details below.
}
  \item{...}{
Additional parameters to pass to \code{plot3d} and \code{triangles3d} for plotting.
}
}
\details{
The \code{coords} parameter allows surfaces to be 
plotted over any coordinate plane.  It should be
a permutation of the column names \code{c("x", "y", "z")}
from the \code{"deldir"} object.  The first will be used
as the x coordinate, the second as the y coordinate, 
and the third as the z coordinate.
}
\examples{
x <- rnorm(200, sd = 5)
y <- rnorm(200, sd = 5)
r <- sqrt(x^2 + y^2)
z <- 10 * sin(r)/r
col <- cm.colors(20)[1 + round(19*(z - min(z))/diff(range(z)))]
if (requireNamespace("deldir", quietly = TRUE)) {
  dxyz <- deldir::deldir(x, y, z = z, suppressMsge = TRUE)
  persp3d(dxyz, col = col)
  open3d()
  # Do the same with a different orientation.
  persp3d(dxyz, col = col, coords = c("z", "x", "y"))
}
}
\keyword{graphics}
