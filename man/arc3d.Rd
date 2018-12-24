\name{arc3d}
\alias{arc3d}
\title{
Draw arcs.
}
\description{
Given starting and ending points on a sphere and the center of the
sphere, draw the
great circle arc between the starting and ending points.  If
the starting and ending points have different radii, a segment of a
logarithmic spiral will join them.
}
\usage{
arc3d(from, to, center, radius, n, circle = 50, base = 0,
plot = TRUE, ...)
}
\arguments{
  \item{from}{
One or more points from which to start arcs.
}
  \item{to}{
One or more destination points.
}
  \item{center}{
One or more center points.
}
  \item{radius}{
If not missing, a vector of length \code{n} giving the
radii at each point between \code{from} and \code{to}.
If missing, the starting and ending points will be joined by
a logarithmic spiral.
}
  \item{n}{
If not missing, how many segments to use between the first and last point.  If missing, a value will be calculated based on the
angle between starting and ending points as seen from the center.
}
  \item{circle}{
How many segments would be used if the arc went completely around
a circle.
}
  \item{base}{
See Details below.
  }
  \item{plot}{
Should the arcs be plotted, or returned as a matrix?
  }
  \item{\dots}{
Additional parameters to pass to \code{\link{points3d}}.
}
}
\details{
If any of \code{from}, \code{to} or \code{center} is an n by 3
matrix with n > 1, multiple arcs will be drawn by recycling
each of these parameters to the number of rows of the longest
one.

If the vector lengths of \code{from - center} and
\code{to - center} differ, then instead of a spherical
arc, the function will draw a segment of a logarithmic spiral joining
the two points.

By default, the arc is drawn along the shortest great 
circle path from \code{from} to \code{to}, but the
\code{base} parameter can be used to modify this.  
If \code{base = 1} is used, the longer arc will be followed.
Larger positive integer values will result in \code{base - 1}
loops in that direction completely around the sphere.  
Negative values will draw the curve in the same direction
as the shortest arc, but with \code{abs(base)} full loops.
It doesn't make much sense to ask for such loops unless
the radii of \code{from} and \code{to} differ, because
spherical arcs would overlap.
Normally the \code{base} parameter is left at its default
value of \code{0}.  

When \code{base} is non-zero, the curve will be constructed in multiple
pieces, between \code{from}, \code{to}, \code{-from} and \code{-to},
for as many steps as necessary.  If \code{n} is specified, it
will apply to each of these pieces.
}
\value{
If \code{plot = TRUE}, called mainly for the side effect of drawing arcs.  Invisibly
returns the object ID of the collection of arcs. 

If \code{plot = FALSE}, returns a 3 column matrix containing
the points that would be drawn as the arcs.
}
\author{
Duncan Murdoch
}

\examples{
normalize <- function(v) v/sqrt(sum(v^2))

# These vectors all have the same length

from <- t(apply(matrix(rnorm(9), ncol = 3), 1, normalize))
to <- normalize(rnorm(3))
center <- c(0, 0, 0)

open3d()
spheres3d(center, radius = 1, col = "white", alpha = 0.2)

arc3d(from, to, center, col = "red")
arc3d(from, 2*to, center, col = "blue")

text3d(rbind(from, to, center, 2*to), 
       text = c(paste0("from", 1:3), "to", "center", "2*to"),
       depth_mask = FALSE, depth_test = "always")
}
