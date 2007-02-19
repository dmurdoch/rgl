\name{ellipse3d}
\alias{ellipse3d}
\alias{ellipse3d.default}
\alias{ellipse3d.lm}
\alias{ellipse3d.glm}
\alias{ellipse3d.nls}
\title{
Make an ellipsoid
}
\description{
A generic function and several methods
returning an ellipsoid or other outline of a confidence region
for three parameters.  
}
\usage{
ellipse3d(x, \dots)
\method{ellipse3d}{default}(x, scale = c(1, 1, 1), centre = c(0, 0, 0), level = 0.95, 
            t = sqrt(qchisq(level, 3)), which = 1:3, subdivide = 3, smooth = TRUE, ...)
\method{ellipse3d}{lm}(x, which = 1:3, level = 0.95, t = sqrt(3 * qf(level, 
                                                3, x$df.residual)), ...)     
\method{ellipse3d}{glm}(x, which = 1:3, level = 0.95, t, dispersion, ...) 
\method{ellipse3d}{nls}(x, which = 1:3, level = 0.95, t = sqrt(3 * qf(level, 
                                                3, s$df[2])), ...) 
}
\arguments{
\item{x}{
An object. In the default method the parameter \code{x} should be a 
square positive definite matrix at least 3x3
in size. It will be treated as the correlation or covariance 
of a multivariate normal distribution.
}
\item{\dots}{
Additional parameters to pass to the default method or to \code{\link{qmesh3d}}.
}
\item{scale}{
If \code{x} is a correlation matrix, then the standard deviations of each
parameter can be given in the scale parameter.  This defaults to \code{c(1, 1, 1)},
so no rescaling will be done.
}
\item{centre}{
The centre of the ellipse will be at this position.
}
\item{level}{
The confidence level of a simulataneous confidence region.  The default is
0.95, for a 95\% region.  This is used to control the size of the ellipsoid.
}
\item{t}{
The size of the ellipse may also be controlled by specifying the value
of a t-statistic on its boundary.  This defaults to the appropriate
value for the confidence region.
}
\item{which}{
This parameter selects which variables from the object will be
plotted.  The default is the first 3.
}
\item{subdivide}{
This controls the number of subdivisions (see \code{\link{subdivision3d}})
used in constructing the ellipsoid.  Higher numbers give a smoother shape.
}
\item{smooth}{
If \code{TRUE}, smooth interpolation of normals is used; if \code{FALSE}, 
a faceted ellipsoid will be displayed.
}
\item{dispersion}{
The value of dispersion to use.  If specified, it is treated as fixed,
and chi-square limits for \code{t} are used. If missing, it is 
taken from \code{summary(x)}.
}
}
\value{
A \code{\link{qmesh3d}} object representing the ellipsoid.
}
\examples{
# Plot a random sample and an ellipsoid of concentration corresponding to a 95\% 
# probability region for a
# trivariate normal distribution with mean 0, unit variances and 
# correlation 0.8.
if (require(MASS)) {
  Sigma <- matrix(c(10,3,0,3,2,0,0,0,1), 3,3)
  Mean <- 1:3
  x <- mvrnorm(1000, Mean, Sigma)
  
  open3d()
  
  plot3d(x, size=3, box=FALSE)
  
  plot3d( ellipse3d(Sigma, centre=Mean), col="green", alpha=0.5, add = TRUE)
}  

# Plot the estimate and joint 90\% confidence region for the displacement and cylinder
# count linear coefficients in the mtcars dataset

data(mtcars)
fit <- lm(mpg ~ disp + cyl , mtcars)

open3d()
plot3d(ellipse3d(fit, level = 0.90), col="blue", alpha=0.5, aspect=TRUE)
}
\keyword{dplot}
