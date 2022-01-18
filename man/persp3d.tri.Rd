\name{persp3d.triSht}
\alias{persp3d.triSht}
\alias{plot3d.triSht}
\alias{as.mesh3d.triSht}
\alias{persp3d.tri}
\alias{plot3d.tri}
\alias{as.mesh3d.tri}
\title{
Plot an interp or tripack Delaunay triangulation
}
\description{
The \code{\link[interp]{tri.mesh}()} functions in the
\pkg{interp} and \pkg{tripack} packages compute a Delaunay triangulation of a set
of points.  These functions display it as a surface.
}
\usage{
\method{plot3d}{triSht}(x, z, ...)
\method{persp3d}{triSht}(x, z, ..., add = FALSE)
\method{as.mesh3d}{triSht}(x, z, col = "gray", coords = c("x", "y", "z"), 
    smooth = TRUE, normals = NULL, texcoords = NULL, ...)
\method{plot3d}{tri}(x, z, ...)
\method{persp3d}{tri}(x, z, ..., add = FALSE)
\method{as.mesh3d}{tri}(x, z, col = "gray", coords = c("x", "y", "z"), 
    smooth = TRUE, normals = NULL, texcoords = NULL, ...)    
}
\arguments{
  \item{x}{
A \code{"triSht"} or \code{"tri"} object, produced by the \code{\link[interp]{tri.mesh}()} function in the \pkg{interp} or \pkg{tripack} packages respectively.  
}
  \item{z}{
z coordinate values corresponding to each of the nodes in \code{x}.  
  }
  \item{add}{
Whether to add surface to existing plot (\code{add = TRUE})
or create a new plot (\code{add = FALSE}, the default).
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
See Details below.
}
}
\details{
These functions construct a \code{\link{mesh3d}} object
corresponding to the triangulation in \code{x}.  The
\code{plot3d} and \code{persp3d} methods plot it.

The \code{coords} parameter allows surfaces to be 
plotted over any coordinate plane.  It should be
a permutation of the column names \code{c("x", "y", "z")}.
The first will be used
as the x coordinate, the second as the y coordinate, 
and the third as the z coordinate.

The \code{...} parameters in \code{plot3d.triSht} and \code{plot3d.tri} 
are passed to \code{persp3d}; in \code{persp3d.triSht}
and \code{persp3d.tri} they are
passed to both \code{as.mesh3d} and \code{persp3d.mesh3d}; 
in \code{as.mesh3d.triSht} and \code{as.mesh3d.tri} they are used as material parameters
in a \code{\link{tmesh3d}} call.

\code{"tri"} objects may contain constraints.  These appear
internally as extra nodes, representing either the inside
or outside of boundaries on the region being triangulated.
Each of these nodes should also have a \code{z} value, but 
triangles corresponding entirely to constraint nodes will not
be drawn.  In this way complex, non-convex regions can
be triangulated.  See the second example below.
}
\note{
If there are duplicate points, the \code{tri.mesh()} functions
will optionally delete some of them.  If you choose this option,
the \code{z} values must correspond to the nodes \emph{after}
deletion, not before.
}
\examples{
x <- rnorm(200, sd = 5)
y <- rnorm(200, sd = 5)
r <- sqrt(x^2 + y^2)
z <- 10 * sin(r)/r
col <- cm.colors(20)[1 + round(19*(z - min(z))/diff(range(z)))]
save <- NULL
if ((haveinterp <- requireNamespace("interp", quietly = TRUE))) {
  save <- options(rgl.meshColorWarning = FALSE)
  dxy <- interp::tri.mesh(x, y)
  open3d()
  persp3d(dxy, z, col = col, meshColor = "vertices")
}
if (haveinterp) {
  open3d()
  # Do it without smoothing and with a different orientation.
  persp3d(dxy, z, col = col, coords = c("z", "x", "y"), smooth = FALSE)
}
if (requireNamespace("tripack", quietly = TRUE)) {
  if (is.null(save))
    save <- options(rgl.meshColorWarning = FALSE)

  # Leave a circular hole around (3, 0)
  theta <- seq(0, 2*pi, length.out = 30)[-1]
  cx <- 2*cos(theta) + 3
  cy <- 2*sin(theta)
  keep <- (x - 3)^2 + y^2 > 4
  dxy2 <- tripack::tri.mesh(x[keep], y[keep])
  dxy2 <- tripack::add.constraint(dxy2, cx, cy)
  z <- dxy2$x^2 - dxy2$y^2
  col <- terrain.colors(20)[1 + round(19*(z - min(z))/diff(range(z)))]
  open3d()
  persp3d(dxy2, z, col = col)
}
options(save)
}
\keyword{graphics}
