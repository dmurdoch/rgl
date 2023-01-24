\name{planes3d}
\alias{planes3d}
\alias{clipplanes3d}
\title{Add planes}
\description{
\code{planes3d} adds mathematical planes 
to a scene.  Their intersection with the current
bounding box will be drawn.  \code{clipplanes3d} 
adds clipping planes to a scene.
}
\usage{
planes3d(a, b = NULL, c = NULL, d = 0, ...)
clipplanes3d(a, b = NULL, c = NULL, d = 0)
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
Material properties. See \code{\link{material3d}} for details.  
}
}
\details{
\code{planes3d} draws planes using the parametrization
\eqn{a x + b y + c z + d = 0}.  Multiple planes may be specified
by giving multiple values for any of \code{a, b, c, d}; the other 
values will be recycled as necessary.

\code{clipplanes3d} defines clipping planes
using the same equations.  Clipping planes suppress the display of
other objects (or parts of them) in the subscene, based on their coordinates.
Points (or parts of lines or surfaces) where the coordinates \code{x, y, z}
satisfy \eqn{a x + b y + c z + d < 0} will be suppressed.

The number of clipping planes
supported by the OpenGL driver is implementation dependent; use
\code{par3d("maxClipPlanes")} to find the limit.
}
\value{
A shape ID of the planes or clipplanes object is returned invisibly.
}
\seealso{
\code{\link{abclines3d}} for mathematical lines.

\code{\link{triangles3d}} or the corresponding
functions for quadrilaterals may be used to draw sections of planes that
do not adapt to the bounding box.

The example in \link{subscene3d} shows how to combine clipping planes
to suppress complex shapes.
}
\examples{

# Show regression plane with z as dependent variable

open3d()
x <- rnorm(100)
y <- rnorm(100)
z <- 0.2*x - 0.3*y + rnorm(100, sd = 0.3)
fit <- lm(z ~ x + y)
plot3d(x, y, z, type = "s", col = "red", size = 1)

coefs <- coef(fit)
a <- coefs["x"]
b <- coefs["y"]
c <- -1
d <- coefs["(Intercept)"]
planes3d(a, b, c, d, alpha = 0.5)

open3d()
ids <- plot3d(x, y, z, type = "s", col = "red", size = 1, forceClipregion = TRUE) 
oldid <- useSubscene3d(ids["clipregion"])
clipplanes3d(a, b, c, d)
useSubscene3d(oldid)
}
\keyword{dynamic}
