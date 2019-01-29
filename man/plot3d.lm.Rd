\name{plot3d.lm}
\alias{plot3d.lm}
\title{
Method for plotting simple linear fit.
}
\description{
This function provides several plots of the result of
fitting a simple two-predictor linear model.
}
\usage{
\method{plot3d}{lm}(x, 
       which = 1, 
       plane.col = "gray", plane.alpha = 0.5,
       sharedMouse = TRUE, ...)
}
\arguments{
  \item{x}{
An object of class \code{"lm"} resulting from fitting
a two-predictor linear model.
}
  \item{which}{
Which plot to show?  See Details below.
}
  \item{plane.col, plane.alpha}{
All plots draw a plane; these parameters control
its colour and transparency respectively.
}
  \item{sharedMouse}{
If multiple plots are requested, should they share
mouse controls, so that they move in sync?
}
  \item{\dots}{
Other parameters to pass to the default \code{\link{plot3d}} method, to control the appearance of aspects of the plot
other than the plane.
}
}
\details{
Three plots are possible, depending on the value(s) in \code{which}:
\enumerate{
\item{(default) Show the points and the fitted plane.}
\item{Show the residuals and the plane at \code{z = 0}.}
\item{Show the predicted values on the fitted plane.}
}
}
\note{
This function can only handle fairly simple linear models,
the same ones handled by \code{\link{xyz.coords}}:  a single
response variable and two predictor variables, e.g. \code{
z ~ x + y}.
}
\value{
Called for the side effect of drawing one or more plots.

Invisibly returns a high-level vector of object ids.  Names of
object ids have the plot number (in drawing order) appended.
}
\author{
Duncan Murdoch
}
\examples{
ids <- plot3d(lm(mpg ~ wt + qsec, data = mtcars), which = 1:3)
names(ids)
}
