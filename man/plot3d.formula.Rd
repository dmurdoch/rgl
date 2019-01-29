\name{plot3d.formula}
\alias{plot3d.formula}
\alias{persp3d.formula}
\title{
Methods for formulas
}
\description{
These functions provide a simple formula-based interface
to \code{\link{plot3d}} and \code{\link{persp3d}}.
}
\usage{
\method{plot3d}{formula}(x, data = NULL, xlab, ylab, zlab, ...)
\method{persp3d}{formula}(x, data = NULL, xlab, ylab, zlab, ...)
}
\arguments{
  \item{x}{
A formula like \code{z ~ x + y}.
}
  \item{data}{
An optional dataframe or list in which to find the components
of the formula.
}
  \item{xlab, ylab, zlab}{
Optional axis labels to override the ones automatically
obtained from the formula.
}
  \item{\dots}{
Additional arguments to pass to the default \code{plot3d}
method, or the \code{persp3d} method for \code{"deldir"}
objects.
}
}
\details{
Only simple formulas (the ones handled by the \code{\link{xyz.coords}} function) are supported:  a single variable on the left hand side (which will be plotted on the Z axis),
and a sum of two variables on the right hand side (which
will be the X and Y axis variables in the plot.)
}
\note{
The \code{persp3d} method requires that the suggested package \pkg{deldir} is installed.
}
\value{
These functions are called for the side effect of drawing
the plots. The \code{plot3d} method draws a scatterplot.  The \code{persp3d} method draws a surface plot.

Return values are as given by the \code{\link{plot3d.default}} method or the \code{\link{persp3d.deldir}} 
methods.
}
\author{
Duncan Murdoch
}
\examples{
open3d()
mfrow3d(1, 2, sharedMouse = TRUE)
plot3d(mpg ~ wt + qsec, data = mtcars)
if (requireNamespace("deldir"))
  persp3d(mpg ~ wt + qsec, data = mtcars)
}
