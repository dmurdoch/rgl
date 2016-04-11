\name{persp3d.deldir}
\alias{persp3d.deldir}
\alias{plot3d.deldir}
\alias{as.mesh3d.deldir}
\title{
Plot a Delaunay triangulation.
}
\description{
The \code{\link[deldir]{deldir}()} function in the \pkg{deldir} package computes a Delaunay triangulation of a set
of points.  These functions display it as a surface.
}
\usage{
\method{persp3d}{deldir}(x, ...)
\method{plot3d}{deldir}(x, ...)
\method{as.mesh3d}{deldir}(x, col = "gray", coords = c("x", "y", "z"), 
    smooth = TRUE, normals = NULL, texcoords = NULL, ...)
}
\arguments{
  \item{x}{
A \code{"deldir"} object, produced by the \code{\link[deldir]{deldir}()} function.  It must contain \code{z} values.
}
  \item{col}{
Colors to apply to each vertex in the triangulation.
Will be recycled as needed.
}
  \item{coords}{
See Details below.
}
  \item{smooth}{
Whether to average normals at vertices for
a smooth appearance.
}
  \item{normals}{
User-specified normals at each vertex.  Requires \code{smooth = FALSE}.
}
  \item{texcoords}{
Texture coordinates at each vertex.
}
  \item{...}{
Additional parameters to pass to \code{\link{plot3d.mesh3d}} and \code{\link{tmesh3d}} for plotting.
}
}
\details{
These functions construct a \code{\link{mesh3d}} object
corresponding to the triangulation in \code{x}.  The
\code{plot3d} and \code{persp3d} methods plot it.

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
  # Do it without smoothing and with a different orientation.
  persp3d(dxyz, col = col, coords = c("z", "x", "y"), smooth = FALSE)
}
}
\keyword{graphics}
