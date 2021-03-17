\name{drape3d3d}
\alias{drape3d}
\title{
Drape lines and intersections between surfaces over a scene.
}
\description{
A line projected is projected onto the surface in a scene so that it appears
to drape itself onto the surface.
If the surface is a function where z = f(x,y) (like topography), then the line
may be specified as a series of line segments.
If the surface is a more general object, then the line is specified by the
intersection of an arbitrary function (a plane, sphere, paraboloid) with the
object.
}
\usage{
drape3d(obj, x, y = NULL, log = NULL, minVertices = 0, plot = TRUE,
    z_offset = 0, ...)
}
\arguments{
  \item{obj}{
The object(s) upon which to drape lines.
}
  \item{x}{
\itemize{
\item{ a function }
\item{ any object that, along with \code{y}, is recognized by
   \code{xy.coords} as yielding a set of (x,y) coordinate pairs }
}
One or more destination points.
}
  \item{log}{
Logarithmic \code{x} or \code{y} data.
See \code{xy.coords} for more information.
}
  \item{minVertices}{
Improve the approximation to the surface when the function is non-linear.
See Details below.
}
  \item{plot}{
Should the lines be plotted, or returned as a data frame?
}
  \item{z_offset}{
Amount to offset the lines painted on the surface from the surface itself.
This can help improve the visibility of apparently intermittent lines on rough
surfaces.
}
  \item{\dots}{
For the \code{"mesh3d"} methods, additional parameters to pass to \code{\link{segments3d}} or \code{\link{lines3d}} 
when drawing the draped lines.
For the \code{"rglId"} methods, additional parameters to pass to the
\code{"mesh3d"} methods.
}
}
\details{
If the resulting \code{x} and \code{y} values contain NA, the line segment
ends and a new one starts with the next point.

If \code{x} is a function, then it must accept a single matrix argument
containing the \code{(x,y,z)} coordinates of each point \code{p[i]}, as shown
in the following tableau:
\preformatted{

 / x[1]  x[2]  x[3] ... x[n] \
 | y[1]  y[2]  y[3] ... y[n] |  .
 \ z[1]  z[2]  z[3] ... z[n] /

}
It should return a vector \code{f(p[1]) ... f(p[n])}.  The intersection with
the object is given by \code{f() = 0}.

The \code{minVertices} argument is used to improve the
approximation to the draping line when the function is non-linear.
In that case, the interpolation between vertices
can be inaccurate.  If \code{minVertices} is set to a positive
number (e.g. \code{10000}), then the mesh is modified
by subdivision to have at least that number of vertices,
so that pieces are smaller and the linear interpolation
is more accurate.
}
\value{
If \code{plot = TRUE}, called mainly for the side effect of draping lines,
it invisibly returns the object ID of the collection of lines. 

If \code{plot = FALSE}, returns a data frame containing "x", "y" and "z"
values for the line(s) (with NA separating each segment), or a data frame
containing discontinuous segments
}
\author{
George Helffrich
}

\examples{

     # Drape a line over volcano topography, then intersect it with a
     # ball of 125 m radius

     z <- 2 * volcano        # Exaggerate the relief
     x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
     y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

     open3d()
     id <- persp3d(x, y, z, aspect = "iso",
           axes = FALSE, box = FALSE, polygon_offset = 1)

     segs <- list(x=range(x),y=range(y)+150)
     drape3d(id, segs, col='yellow', lwd=3)
     lines3d(list(x=segs$x,y=segs$y,z=rep(325,2)), col='red', lwd=3)

     ball <- function(r,o){
         function(x,R=r,O=o){
             apply((x-matrix(O,3,ncol(x)))^2,2,sum)-R^2
         }
     }
     drape3d(id, ball(125,c(350,200,320)), col='orange', lwd=3)

     contourLines3d(id)     # "z" is the default function
     filledContour3d(id, polygon_offset = 1, nlevels = 10, replace = TRUE)

}
