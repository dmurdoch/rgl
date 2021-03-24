\name{shadow3d}
\alias{shadow3d}
\title{
Project shadows of mesh onto object.
}
\description{
Project a mesh onto a surface in a scene so that it appears to cast a shadow onto the surface.
}
\usage{
shadow3d(obj, mesh, plot = TRUE, up = c(0, 0, 1),
         P = projectDown(up), outside = FALSE,
         ...)
}
\arguments{
  \item{obj}{
The target object which will show the shadow.
}
  \item{mesh}{
The mesh which will cast the shadow.
}
  \item{plot}{
Whether to plot the result.
}
  \item{up}{
Which direction is \dQuote{up}?
  }
  \item{P}{
The projection to use for draping, a 2x3 matrix.  The default
annihilates the \code{up} vector while maintaining orientation.
}
  \item{outside}{
Should the function compute and (possibly) plot the region
outside of the shadow?
}
  \item{\dots}{
Other arguments to pass to \code{\link{filledContour3d}},
which will do the boundary calculations and plotting.
}
}
\details{
\code{shadow3d} internally constructs a function that 
is zero on the boundary of the shadow and positive inside, 
then draws filled contours of that function.  Because the
function is nonlinear, the boundaries will be approximate,
with the best approximation resulting from a large
value of \code{\link{filledContour3d}} parameter \code{minVertices}.

If \code{outside = TRUE}, the first color used by
\code{\link{filledContour3d}} will indicate the inside
of the shadow, and the second color will indicate the exterior.
}
\value{
The returned value from \code{\link{filledContour3d}}.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{drape3d}}, \code{\link{facing3d}}
}
\examples{
open3d()
obj <- translate3d(scale3d(oh3d(), 0.3, 0.3, 0.3), 0,0,2)
shade3d(obj, col = "red")
target <- icosahedron3d()

# We offset the target using polygon_offset = 1 so that the
# shadow on its surface will appear clearly.

shade3d(target, col = "white", polygon_offset = 1)

# minVertices = 1000 leaves noticeable artifacts on the edges
# of the shadow.  A larger value gives a better result, but is
# slower.

# We use facing3d(target) so the shadow and outside part only 
# appear on the upper side of the target

shadow3d(facing3d(target), obj, minVertices = 1000, plot=TRUE,
         col = c("yellow", "blue"), outside = TRUE)
}
