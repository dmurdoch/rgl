\name{rgl.user2window}
\alias{rgl.user2window}
\alias{rgl.window2user}
\title{ Convert between rgl user and window coordinates }
\description{
This function converts from 3-dimensional user coordinates
to 3-dimensional window coordinates.
}
\usage{
rgl.user2window(x, y, z, projection = rgl.projection())
rgl.window2user(x, y, z = 0, projection = rgl.projection())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x, y, z}{Input coordinates }
  \item{projection}{The rgl projection to use }
}
\details{
These functions convert between user coordinates and window coordinates.

Window coordinates run from 0 to 1 in X, Y, and Z.  X runs from 0 on the
left to 1 on the right; Y runs from 0 at the bottom to 1 at the top;
Z runs from 0 foremost to 1 in the background.  \code{rgl} does not currently
do clipping, so values of Z that are negative or bigger than 1 are possible.
}
\value{
A matrix with columns corresponding to the X, Y, and Z coordinates.
}
\author{ Ming Chen / Duncan Murdoch}
\seealso{\code{\link{select3d}} }
\examples{
rgl.clear()
points3d(rnorm(100), rnorm(100), rnorm(100))
# Calculate a square in the middle of the display and plot it
square <- rgl.window2user(c(0.25, 0.25, 0.75, 0.75, 0.25), c(0.25, 0.75, 0.75, 0.25, 0.25), 0)
lines3d(square[,1], square[,2], square[,3])

}
\keyword{ dynamic }
