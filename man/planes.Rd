\name{planes}
\alias{rgl.planes}
\alias{planes3d}
\title{add planes}
\description{
This adds mathematical planes to a scene.  Their intersection with the current
bounding box will be drawn.
}
\usage{
planes3d(a, b = NULL, c = NULL, d = 0, ...)
rgl.planes(a, b = NULL, c = NULL, d = 0, ...)
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
This draws planes using the parametrization
\eqn{a x + b y + c z + d = 0}.  Multiple planes may be specified
by giving multiple values for any of \code{a, b, c, d}; the other 
values will be recycled as necessary.
}
\value{
A shape ID of the planes object is returned invisibly.
}
\seealso{
\code{\link{triangles3d}}, \code{\link{rgl.triangles}} or the corresponding
functions for quadrilaterals may be used to draw sections of planes that
do not adapt to the bounding box.
}
\examples{

# Show regression plane with z as dependent variable

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

}
\keyword{dynamic}
