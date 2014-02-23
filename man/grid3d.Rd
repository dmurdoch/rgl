\name{grid3d}
\alias{grid3d}
\title{Add a grid to a 3D plot }
\description{
This function adds a reference grid to an RGL plot.
}
\usage{
grid3d(side, at = NULL, col = "gray", lwd = 1, lty = 1, n = 5)
}
\arguments{
  \item{side}{ Where to put the grid; see the Details section. }
  \item{at}{ How to draw the grid; see the Details section. }
  \item{col}{ The color of the grid lines. }
  \item{lwd}{ The line width of the grid lines. (Currently only
  \code{lty = 1} is supported.)}
  \item{lty}{ The line type of the grid lines. }
  \item{n}{ Suggested number of grid lines; see the Details section. }
}
\details{
This function is similar to \code{\link{grid}} in classic graphics,
except that it draws a 3D grid in the plot.

The grid is drawn in a plane perpendicular to the coordinate axes. The
first letter of the \code{side} argument specifies the direction of
the plane: \code{"x"}, \code{"y"} or \code{"z"} (or uppercase
versions) to specify the coordinate which is constant on the plane.

If \code{at = NULL} (the default), the grid is drawn at the limit of 
the box around the data.  If the second letter of the \code{side} argument
is \code{"-"} or is not present, it is the lower limit; if \code{"+"}
then at the upper limit.  The grid lines are drawn at values
chosen by \code{\link{pretty}} with \code{n} suggested locations.
The default locations should match those chosen by \code{\link{axis3d}}
with \code{nticks = n}.

If \code{at} is a numeric vector, the grid lines are drawn at those values.

If \code{at} is a list, then the \code{"x"} component is used to
specify the x location, the \code{"y"} component specifies the y location, and
the \code{"z"} component specifies the z location.  Missing components
are handled using the default as for \code{at = NULL}.

Multiple grids may be drawn by specifying multiple values for \code{side}
or for the component of \code{at} that specifies the grid location.
}
\note{
If the scene is resized, the grid will not be resized; use \code{\link{abclines3d}}
to draw grid lines that will automatically resize.
}
\value{ A vector or matrix of object ids is returned invisibly. }
\author{ Ben Bolker and Duncan Murdoch }
\seealso{ \code{\link{axis3d}} }
\examples{
x <- 1:10
y <- 1:10
z <- matrix(outer(x-5,y-5) + rnorm(100), 10, 10)
open3d()
persp3d(x, y, z, col="red", alpha=0.7, aspect=c(1,1,0.5))
grid3d(c("x", "y+", "z"))
}
\keyword{ dynamic }
