\name{abclines3d}
\alias{rgl.abclines}
\alias{abclines3d}
\title{
Lines intersecting the bounding box
}
\description{
This adds mathematical lines to a scene.  Their intersection with the current
bounding box will be drawn.
}
\usage{
rgl.abclines(x, y = NULL, z = NULL, a, b = NULL, c = NULL, ...)
abclines3d(x, y = NULL, z = NULL, a, b = NULL, c = NULL, ...)
}
\arguments{
  \item{x,y,z}{
Coordinates of points through which each line passes.  
} 
  \item{a,b,c}{
Coordinates of the direction vectors for the lines.
}
  \item{...}{
Material properties.
}

}
\details{
These functions draw the segment of a line that intersects the current
bounding box of the scene using the parametrization
\eqn{ (x,y,z) + (a,b,c) * s } where \eqn{s} is a real number.

Any reasonable way of defining the
coordinates \code{x,y,z} and \code{a,b,c} is acceptable.  
See the function \code{\link[grDevices]{xyz.coords}}
for details.
}
\value{
A shape ID of the object is returned invisibly.
}

\seealso{
\code{\link{planes3d}}, \code{\link{rgl.planes}} for mathematical planes.

\code{\link{segments3d}} draws sections of lines that
do not adapt to the bounding box.

}
\examples{
plot3d(rnorm(100), rnorm(100), rnorm(100))
abclines3d(0,0,0, a=diag(3), col="gray")
}
\keyword{ dynamic }
