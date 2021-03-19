\name{drape3d}
\alias{drape3d}
\alias{drape3d.default}
\alias{drape3d.mesh3d}
\title{
Drape lines and intersections between surfaces over a scene.
}
\description{
Project a line onto the surface in a scene so that it appears to drape itself
onto the surface.
The line
may be specified as a series of line segments.
}
\usage{
drape3d(obj, ...)
\method{drape3d}{mesh3d}(obj, x, y = NULL, z = NULL, plot = TRUE, ...)
\method{drape3d}{default}(obj, ...)
}
\arguments{
  \item{obj}{
The object(s) upon which to drape lines.
}
  \item{x,y,z}{Coordinates of the line segments
to be draped.  Any reasonable way of defining the
coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}} for details.}
  \item{plot}{
Should the result be plotted, or returned as a data frame?
}
  \item{P}{
The projection to use for draping, a 2x3 matrix.  The default drops the z coordinate for a vertical projection.
  }
  \item{\dots}{
For the \code{"mesh3d"} method, additional parameters to pass to \code{\link{segments3d}}
when drawing the draped lines.
For the \code{"default"} method, additional parameters to pass to the
\code{"mesh3d"} method.
}
}
\value{
If \code{plot = TRUE}, 
it invisibly returns the object ID of the collection of segments. 

If \code{plot = FALSE}, returns a data frame containing "x", "y" and "z"
values for the line(s) with NA separating each segment
(for use with \code{\link{lines3d}}),
or a data frame containing discontinuous segments
(for use with \code{\link{segments3d}}). 
For lines, if the resulting "x" and "y" values contain NA, the line segment
ends and a new one starts with the next point.  Segments are defined by
successive pairs of points and are unordered.
}
\author{
George Helffrich and Duncan Murdoch
}

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

segs <- data.frame(x=range(x)+c(100,-100),y=range(y)+c(150,-100),z=325)
drape3d(id, segs, col='yellow', lwd=3)
lines3d(segs, col='red', lwd=3)

}
