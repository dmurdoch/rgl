\name{rgl.user2window}
\alias{rgl.user2window}
\alias{rgl.window2user}
\alias{rgl.projection}
\title{ Convert between rgl user and window coordinates }
\description{
This function converts from 3-dimensional user coordinates
to 3-dimensional window coordinates.
}
\usage{
rgl.user2window(x, y = NULL, z = NULL, projection = rgl.projection())
rgl.window2user(x, y = NULL, z = 0, projection = rgl.projection())
rgl.projection()
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x, y, z}{Input coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{projection}{The rgl projection to use }
}
\details{
These functions convert between user coordinates and window coordinates.

Window coordinates run from 0 to 1 in X, Y, and Z.  X runs from 0 on the
left to 1 on the right; Y runs from 0 at the bottom to 1 at the top;
Z runs from 0 foremost to 1 in the background.  \code{rgl} does not currently
display vertices plotted outside of this range, but in normal circumstances will automatically resize the
display to show them.  In the example below this has been suppressed.

}
\value{
The coordinate conversion functions produce a matrix with columns corresponding 
to the X, Y, and Z coordinates.

\code{rgl.projection()} returns a list containing the model matrix, projection matrix
and viewport.  See \code{\link{par3d}} for more details.
}
\author{ Ming Chen / Duncan Murdoch}
\seealso{\code{\link{select3d}} }
\examples{
open3d()
points3d(rnorm(100), rnorm(100), rnorm(100))
if (interactive() || !.Platform$OS=="unix") {
# Calculate a square in the middle of the display and plot it
square <- rgl.window2user(c(0.25, 0.25, 0.75, 0.75, 0.25), 
                          c(0.25, 0.75, 0.75, 0.25, 0.25), 0.5)
par3d(ignoreExtent = TRUE)
lines3d(square)
par3d(ignoreExtent = FALSE)
}
}
\keyword{ dynamic }
