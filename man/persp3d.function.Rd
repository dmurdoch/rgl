\name{persp3d.function}
\alias{plot3d.function}
\alias{persp3d.function}
\title{
Plot a function of two variables
}
\description{
Plot a function \code{z(x, y)} or a parametric function
\code{(x(s, t), y(s, t), z(s, t))}.
}
\usage{
\method{persp3d}{function}(x, 
  xlim = c(0, 1), ylim = c(0, 1), 
  slim = NULL, tlim = NULL, 
  n = 101, 
  xvals = seq.int(min(xlim), max(xlim), length.out = n[1]), 
  yvals = seq.int(min(ylim), max(ylim), length.out = n[2]), 
  svals = seq.int(min(slim), max(slim), length.out = n[1]), 
  tvals = seq.int(min(tlim), max(tlim), length.out = n[2]), 
  xlab, ylab, zlab, 
  col = "gray", otherargs = list(), 
  normal = NULL, texcoords = NULL, \dots)
\method{plot3d}{function}(x, \ldots)
}
\arguments{
  \item{x}{
A function of two arguments.  See the details below.
}
  \item{xlim, ylim}{
By default, the range of x and y values.  For a parametric
surface, if these are not missing, they are used as limits
on the displayed x and y values.
}
  \item{slim, tlim}{
If not \code{NULL}, these give the range of s and t in the
parametric specification of the surface.  If
only one is given, the other defaults to \code{c(0, 1)}.
}
  \item{n}{
A one or two element vector giving the number of 
steps in the x and y (or s and t) grid.
}
  \item{xvals, yvals}{
The values at which to evaluate x and y.  Ignored for
a parametric surface.  If used, \code{xlim} and/or \code{ylim}
are ignored.
}
  \item{svals, tvals}{
The values at which to evaluate s and t for a parametric
surface.  Only used if
\code{slim} or \code{tlim} is not \code{NULL}.  As with 
\code{xvals} and \code{yvals}, these override the corresponding
\code{slim} or \code{tlim} specification.
}
  \item{xlab, ylab, zlab}{
The axis labels.  See the details below for the defaults.
}
  \item{col}{
The color to use for the plot.  See the details below.
}
  \item{otherargs}{
Additional arguments to pass to the function.
}
  \item{normal, texcoords}{
Functions to set surface normals or texture coordinates.  See
the details below.
}
  \item{\dots}{
Additional arguments to pass to \code{\link{persp3d}}.
}
}
\details{
The \code{"function"} method for \code{plot3d} simply passes
all arguments to \code{persp3d}.  Thus this description applies
to both.

The first argument \code{x} is required to be a function.  It
is named \code{x} only because of the requirements of the S3
system; in the remainder of this help page, we will assume
that the assignment \code{f <- x} has been made, and will 
refer to the function \code{f()}.

\code{persp3d.function} evaluates \code{f()} on a two-dimensional
grid of values, and displays the resulting surface.  The values
on the grid will be passed in as vectors in the 
first two arguments to the function, so \code{f()} needs
to be vectorized.  Other optional arguments to \code{f()}
can be specified in the \code{otherargs} list.

In the default form where \code{slim} and \code{tlim} are both
\code{NULL}, it is assumed that \code{f(x, y)} returns heights,
which will be plotted in the z coordinate.  The default axis labels
will be taken from the argument names to \code{f()} and the
expression passed as argument \code{x} to this function.

If \code{slim} or \code{tlim} is specified, a parametric
surface is plotted.  The function
\code{f(s, t)} must return a 3-column matrix, giving x, y and z 
coordinates of points on the surface.  The default axis
labels will be the column names if those are present.
In this case \code{xlim}, \code{ylim} and \code{zlim}
are used to define a clipping region only if specified;
the defaults are ignored.

The color of the surface may be specified as the name of a
color, or a vector or matrix of color names. In this case
the colors will be recycled across the points on the grid
of values.

Alternatively, a function may be given:  it should be a function
like \code{\link{rainbow}} that takes an integer argument and
returns a vector of colors.  In this case the colors are mapped
to z values.

The \code{normal} argument allows specification of a function
to compute normal vectors to the surface.  This function is
passed the same arguments as \code{f()} (incuding \code{otherargs}
if present), and should produce a 3-column matrix containing the
x, y and z coordinates of the normals.

The \code{texcoords} argument is a function similar to \code{normal}, but
it produces a 2-column matrix containing texture coordinates.

Both \code{normal} and \code{texcoords} may also contain matrices,
with 3 and 2 columns respectively, and rows corresponding to the
points that were passed to \code{f()}.
}
\value{
This function constructs a call to \code{\link{persp3d}}
and returns the value from that function.
}
\author{
Duncan Murdoch
}

\seealso{
The \code{\link{curve}} function in base graphics does
something similar for functions of one variable.  See the
example below for space curves.
}
\examples{
# (1) The Obligatory Mathematical surface.
#     Rotated sinc function, with colors

f <- function(x, y) { 
  r <- sqrt(x^2 + y^2)
  ifelse(r == 0, 10, 10 * sin(r)/r)
}
open3d()
plot3d(f, col = colorRampPalette(c("blue", "white", "red")), 
       xlab = "X", ylab = "Y", zlab = "Sinc( r )", 
       xlim = c(-10, 10), ylim = c(-10, 10),
       aspect = c(1, 1, 0.5))
       
# (2) A cylindrical plot

f <- function(s, t) {
  r <- 1 + exp( -pmin( (s - t)^2, 
                       (s - t - 1)^2, 
                       (s - t + 1)^2 )/0.01 )
  cbind(r*cos(t*2*pi), r*sin(t*2*pi), s)
}

open3d()
plot3d(f, slim = c(0, 1), tlim = c(0, 1), col = "red", alpha = 0.8)

# Add a curve to the plot, fixing s at 0.5.

plot3d(f(0.5, seq.int(0, 1, length.out = 100)), type = "l", add = TRUE, 
       lwd = 3, depth_test = "lequal")
}
\keyword{ graphics }
