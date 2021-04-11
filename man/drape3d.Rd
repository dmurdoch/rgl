\name{drape3d}
\alias{drape3d}
\alias{drape3d.default}
\alias{drape3d.mesh3d}
\title{
Drape lines over a scene.
}
\description{
Project a line onto the surface in a scene so that it appears to drape itself
onto the surface.
}
\usage{
drape3d(obj, ...)
\method{drape3d}{mesh3d}(obj, x, y = NULL, z = NULL, plot = TRUE,
                         up = c(0, 0, 1),
                         P = projectDown(up), ...)
\method{drape3d}{default}(obj, ...)
}
\arguments{
  \item{obj}{
The object(s) upon which to drape lines.
}
  \item{x,y,z}{Coordinates of the line segments
to be draped.  Any reasonable way of defining the
coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}} for details.
}
  \item{plot}{
Should the result be plotted, or returned as a data frame?
}
  \item{up}{
The direction to consider as \dQuote{up}.
  }
  \item{P}{
The projection to use for draping, a 4x4 matrix.
  }
  \item{\dots}{
For the \code{"mesh3d"} method, additional parameters to pass to \code{\link{segments3d}}
when drawing the draped lines.
For the \code{"default"} method, additional parameters to pass to the
\code{"mesh3d"} method.
}
}
\details{
The default method converts \code{obj} to a mesh
using \code{\link{as.mesh3d}}, then uses the \code{"mesh3d"}
method.

The current implementation constructs the segments to drape
across the surface using the same method as
\code{\link{lines3d}} uses:  each successive point is
joined to the previous one.  Use \code{NA} coordinates to
indicate breaks in the line.

The \code{P} matrix is used to project points to a plane as
follows:  They are transformed by \code{P} in 
homogeneous coordinates, then only first two (Euclidean)
coordinates are kept.
}
\value{
If \code{plot = TRUE}, 
plots the result and invisibly returns the object ID of the collection of segments. 

If \code{plot = FALSE}, returns a matrix containing "x", "y" and "z"
values for the line(s) 
(for use with \code{\link{segments3d}}),
}
\author{
George Helffrich and Duncan Murdoch
}
\seealso{\code{\link{shadow3d}}, \code{\link{facing3d}}}
\examples{
#
# volcano example taken from "persp"
#

z <- 2 * volcano        # Exaggerate the relief

x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

zlim <- range(z)
zlen <- zlim[2] - zlim[1] + 1

colorlut <- terrain.colors(zlen) # height color lookup table

col <- colorlut[ z - zlim[1] + 1 ] # assign colors to heights for each point

open3d()
id <- surface3d(x, y, z, color = col, polygon_offset = 1)

segs <- data.frame(x = range(x) + c(100, -100),
                   y = range(y) + c(150, -100), z = 325)
drape3d(id, segs, col = 'yellow', lwd = 3)
lines3d(segs, col='red', lwd=3)

p <- c(350, 205)         # (x,y) of strike & dip reading
off <- 20*c(-1, +1)      # X-marks-the-spot offset
segs <- data.frame(
    x = c(p[1] + off, NA, p[1] + off),
    y = c(p[2] + off, NA, p[2] - off),
    z = rep(350, 5)
    )
drape3d(id, segs, col = "yellow", lwd = 3)
}
