\name{bgplot3d}
\alias{bgplot3d}
\alias{legend3d}
\title{Use base graphics for RGL background}
\description{
Add a 2D plot or a legend in the background of an RGL window.
}
\usage{
bgplot3d(expression, bg.color = getr3dDefaults()$bg$color, ...)
legend3d(...)
}
\arguments{
  \item{expression}{
Any plotting commands to produce a plot.
}
  \item{bg.color}{
The color to use for the background.
}
  \item{...}{
Arguments to pass to the \code{\link{bg3d}} or \code{\link{legend}} function.
}
}
\details{
The \code{bgplot3d} function opens a \code{\link{png}} device and executes \code{expression},
producing a plot there.  This plot is then used as a bitmap background for the current
RGL subscene.

The \code{legend3d} function draws a standard 2D legend to the background of the current
subscene by calling \code{bgplot3d} to open a device, and setting up a plot region there 
to fill the whole display.
}
\value{
The \code{bgplot3d} function invisibly returns the ID of the background object that was created,
with attribute \code{"value"} holding the value returned when the \code{expression} was
evaluated.

The \code{legend3d} function does similarly.  The \code{"value"} attribute is the result
of the call to \code{\link{legend}}.   The scaling of the coordinates runs from 0 to 1 
in X and Y.
}
\author{
Duncan Murdoch
}
\note{
Because the background plots are drawn as bitmaps, they do not resize very gracefully.
It's best to size your window first, then draw the background at that size.
}


\seealso{
\code{\link{bg3d}} for other background options.
}
\examples{
x <- rnorm(100)
y <- rnorm(100)
z <- rnorm(100)
open3d()
# Needs to be a bigger window than the default
par3d(windowRect = c(100, 100, 612, 612))
parent <- currentSubscene3d()
mfrow3d(2, 2)
plot3d(x, y, z)
next3d(reuse = FALSE)
bgplot3d(plot(y, z))
next3d(reuse = FALSE)
bgplot3d(plot(x, z))
next3d(reuse = FALSE)
legend3d("center", c("2D Points", "3D Points"), pch = c(1, 16))
useSubscene3d(parent)
}
\keyword{ graphics }
