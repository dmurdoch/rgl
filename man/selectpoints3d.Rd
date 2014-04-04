\name{selectpoints3d}
\alias{selectpoints3d}
\title{
Select points from a scene
}
\description{
This function uses the \code{\link{select3d}} function to allow the user to choose a
point or region in the scene, then reports on all the vertices in or near that selection.
}
\usage{
selectpoints3d(objects = rgl.ids()$id, value = TRUE, closest = TRUE, % $
               multiple = FALSE, ...)
}
\arguments{
  \item{objects}{
A vector of object id values to use for the search.
}
  \item{value}{
If \code{TRUE}, return the coordinates of the points; otherwise, return
their indices.
}
  \item{closest}{
If \code{TRUE}, return the points closest to the selection of no points are
exactly within it.
}
  \item{multiple}{
If \code{TRUE} or a function, do multiple selections.  See the Details below.
}
  \item{\dots}{
Other parameters to pass to \code{\link{select3d}}.
}
}
\details{
The \code{multiple} argument may be a logical value or a function.  If logical, 
it controls whether multiple selections will be performed.  If 
\code{multiple} is \code{FALSE}, a single selection will be performed;
it might contain multiple points.  If \code{TRUE}, multiple selections 
will occur and the results will be combined into a single matrix.  

If \code{multiple} is a function, it should take a single argument.
This function will be called with the argument set to a matrix
containing newly added rows to the value, i.e. 
it will contain coordinates of the newly selected points (if 
\code{value = TRUE}), or the indices of the points (if \code{value =
FALSE}).  It should return a logical value, \code{TRUE} to indicate
that selection should continue, \code{FALSE} to indicate that it
should stop.

In either case, if multiple selections are being performed, the \code{ESC} key will 
stop the process.
}
\value{
If \code{value} is \code{TRUE}, a 3-column matrix giving the coordinates of the 
selected points.  All rows in the matrix will be unique even if multiple vertices
have the same coordinates.

If \code{value} is \code{FALSE}, a 2-column matrix containing columns:
\item{id}{The object id containing the point.}
\item{index}{The index of the point within \code{\link{rgl.attrib}(id, "vertices")}.
If multiple points have the same coordinates, all indices will be returned.}

}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{select3d}} to return a selection function.
}
\examples{
\donttest{
xyz <- cbind(rnorm(20), rnorm(20), rnorm(20))
ids <- plot3d( xyz )

# Click near a point to select it and put a sphere there.
# Press ESC to quit...

# This version returns coordinates
selectpoints3d(ids["data"], 
   multiple = function(x) {
      spheres3d(x, color = "red", alpha = 0.3, radius = 0.2)
      TRUE
   })
}

# This one returns indices
selectpoints3d(ids["data"], value = FALSE,
   multiple = function(ids) {
      spheres3d(xyz[ids[, "index"],,drop=FALSE], color = "blue", 
                alpha = 0.3, radius = 0.2)
      TRUE
   })
}
\keyword{ graphics }
