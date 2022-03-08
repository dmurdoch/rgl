\name{cylinder3d}
\alias{cylinder3d}
\encoding{UTF-8}
\title{
Create cylindrical or "tube" plots
}
\description{
This function converts a description of a space curve into a \code{\link[=mesh3d]{"mesh3d"}}
object forming a cylindrical tube around the curve.
}
\usage{
cylinder3d(center, radius = 1, twist = 0, e1 = NULL, e2 = NULL, e3 = NULL, 
	sides = 8, section = NULL, closed = 0, 
	rotationMinimizing = is.null(e2) && is.null(e3),
	debug = FALSE, keepVars = FALSE, ...)
}
\arguments{
  \item{center}{An n by 3 matrix whose columns are the x, y and z coordinates of the space curve.}
  \item{radius}{The radius of the cross-section of the tube at each point in the center.}
  \item{twist}{The amount by which the polygon forming the tube is twisted at each point.}
  \item{e1, e2, e3}{The local coordinates to use at each point on the space curve.  These default to a rotation
minimizing frame or Frenet coordinates.}
  \item{sides}{The number of sides in the polygon cross section.}
  \item{section}{The polygon cross section as a two-column matrix, or \code{NULL}.}  
  \item{closed}{Whether to treat the first and last points of the space curve as identical,
  and close the curve, or put caps on the ends.  See the Details.}
  \item{rotationMinimizing}{Use a rotation minimizing local
frame if \code{TRUE}, or a Frenet or user-specified frame if \code{FALSE}.}
  \item{debug}{If \code{TRUE}, plot the local Frenet coordinates at each point.}
  \item{keepVars}{If \code{TRUE}, return the local variables in attribute \code{"vars"}.}
  \item{...}{Additional arguments to set as material properties.}
}
\details{

The number of points in the space curve is determined by the vector lengths in \code{center},
after using \code{\link{xyz.coords}} to convert it to a list.  The other arguments
\code{radius}, \code{twist}, \code{e1}, \code{e2}, and \code{e3} are extended to the same
length.

The \code{closed} argument controls how the ends of the cylinder are
handled. If \code{closed > 0}, it represents the number of points of
overlap in the coordinates.  \code{closed == TRUE} is the same as 
\code{closed = 1}. If \code{closed > 0} but the ends don't actually 
match, a warning will be given and results will be somewhat 
unpredictable.

Negative values of \code{closed} indicate that caps should be put on the
ends of the cylinder.  If \code{closed == -1}, a cap will be put on the
end corresponding to \code{center[1, ]}.  If \code{closed == -2}, caps
will be put on both ends.

If \code{section} is \code{NULL} (the default), a regular
\code{sides}-sided polygon is used, and \code{radius} measures the
distance from the center of the cylinder to each vertex.  If not
\code{NULL}, \code{sides} is ignored (and set internally to
\code{nrow(section)}), and \code{radius} is used as a multiplier to
the vertex coordinates.  \code{twist} specifies the rotation of the
polygon.  Both \code{radius} and \code{twist} may be vectors, with
values recycled to the number of rows in \code{center}, while
\code{sides} and \code{section} are the same at every point along the
curve.

The three optional arguments \code{e1}, \code{e2}, and \code{e3}
determine the local coordinate system used to create the vertices at
each point in \code{center}.  If missing, they are computed by simple
numerical approximations.  \code{e1} should be the tangent coordinate,
giving the direction of the curve at the point.  The cross-section of
the polygon will be orthogonal to \code{e1}. When \code{rotationMinimizing} is \code{TRUE}, \code{e2} and \code{e3} are chosen to give
a rotation minimizing frame (see Wang et al., 2008).  When it is
\code{FALSE},  \code{e2} defaults to an
approximation to the normal or curvature vector; it is used as the
image of the \code{y} axis of the polygon cross-section.  \code{e3}
defaults to an approximation to the binormal vector, to which the
\code{x} axis of the polygon maps.  The vectors are orthogonalized and
normalized at each point.
}
\value{
A \code{\link[=mesh3d]{"mesh3d"}} object holding the cylinder, possibly with
attribute \code{"vars"} containing the local environment of the function.
}
\author{
Duncan Murdoch
}
\references{
Wang, W., Jüttler, B., Zheng, D. and Liu, Y. (2008).  
Computation of rotation minimizing frames.  
ACM Transactions on Graphics, Vol. 27, No. 1, Article 2.
}
\examples{
# A trefoil knot
open3d()
theta <- seq(0, 2*pi, length.out = 25)
knot <- cylinder3d(
      center = cbind(
        sin(theta) + 2*sin(2*theta), 
        2*sin(3*theta), 
        cos(theta) - 2*cos(2*theta)),
      e1 = cbind(
        cos(theta) + 4*cos(2*theta), 
        6*cos(3*theta), 
        sin(theta) + 4*sin(2*theta)),
      radius = 0.8, 
      closed = TRUE,
      color = "green")
                     
shade3d(addNormals(subdivision3d(knot, depth = 2)))  
}

\keyword{ dynamic }
