\name{planes}
\alias{rgl.planes}
\alias{planes3d}
\alias{rgl.clipplanes}
\alias{clipplanes3d}
\title{add planes}
\description{
\code{planes3d} and \code{rgl.planes} add mathematical planes 
to a scene.  Their intersection with the current
bounding box will be drawn.  \code{clipplanes3d} and \code{rgl.clipplanes}
add clipping planes to a scene.
}
\usage{
planes3d(a, b = NULL, c = NULL, d = 0, ...)
rgl.planes(a, b = NULL, c = NULL, d = 0, ...)
clipplanes3d(a, b = NULL, c = NULL, d = 0)
rgl.clipplanes(a, b = NULL, c = NULL, d = 0)
}
\arguments{
  \item{a, b, c}{
Coordinates of the normal to the plane.  Any reasonable way of defining the
coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
for details.
}
  \item{d}{
Coordinates of the "offset".  See the details.
}
  \item{\dots}{
Material properties. See \code{\link{rgl.material}} for details.  
}
}
\details{
\code{planes3d} and \code{rgl.planes} draw planes using the parametrization
\eqn{a x + b y + c z + d = 0}.  Multiple planes may be specified
by giving multiple values for any of \code{a, b, c, d}; the other 
values will be recycled as necessary.

\code{clipplanes3d} and \code{rgl.clipplanes} define clipping planes
using the same equations.  The number of clipping planes
supported by the OpenGL driver is implementation dependent; use
\code{par3d("maxClipPlanes")} to find the limit.
}
\note{
The clip plane code is experimental and currently only partially
implemented, so is subject to change.
}
\value{
A shape ID of the planes object is returned invisibly.
}
\seealso{
\code{\link{abclines3d}}, \code{\link{rgl.abclines}} for mathematical lines.

\code{\link{triangles3d}}, \code{\link{rgl.triangles}} or the corresponding
functions for quadrilaterals may be used to draw sections of planes that
do not adapt to the bounding box.
}
\examples{

# Show regression plane with z as dependent variable

open3d()
x <- rnorm(100)
y <- rnorm(100)
z <- 0.2*x - 0.3*y + rnorm(100, sd=0.3)
fit <- lm(z ~ x + y)
plot3d(x,y,z, type="s", col="red", size=1)

coefs <- coef(fit)
a <- coefs["x"]
b <- coefs["y"]
c <- -1
d <- coefs["(Intercept)"]
planes3d(a, b, c, d, alpha=0.5)

open3d()
plot3d(x,y,z, type="s", col="red", size=1)
clipplanes3d(a, b, c, d)

}
\keyword{dynamic}
