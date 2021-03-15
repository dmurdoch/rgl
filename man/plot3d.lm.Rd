\name{plot3d.lm}
\alias{plot3d.lm}
\title{
Method for plotting simple linear fit
}
\description{
This function provides several plots of the result of
fitting a two-predictor model.
}
\usage{
\method{plot3d}{lm}(x, 
       which = 1, 
       plane.col = "gray", plane.alpha = 0.5,
       sharedMouse = TRUE, 
       use_surface3d, 
       do_grid = TRUE,
       grid.col = "black", 
       grid.alpha = 1,
       grid.steps = 5,
       sub.steps = 4,
       vars = get_all_vars(terms(x), x$model),
       clip_to_density = 0,
       ...)
}
\arguments{
  \item{x}{
An object inheriting from class \code{"lm"} obtained by fitting
a two-predictor model.
}
  \item{which}{
Which plot to show?  See Details below.
}
  \item{plane.col, plane.alpha}{
These parameters control
the colour and transparency of a plane or surface.
}
  \item{sharedMouse}{
If multiple plots are requested, should they share
mouse controls, so that they move in sync?
}
  \item{use_surface3d}{
Use the \code{\link{surface3d}} function to plot the surface
rather than \code{\link{planes3d}}.  This allows curved
surfaces to be shown.  The default is \code{FALSE} if the model
looks like a simple 2 parameter linear fit, otherwise \code{TRUE}.
  }
  \item{do_grid}{Plot a grid.}
  \item{grid.col, grid.alpha, grid.steps}{
Characteristics of the grid.
  }
  \item{sub.steps}{If \code{use_surface3d} is \code{TRUE}, 
use an internal grid of \code{grid.steps*sub.steps} to draw
the surface.  \code{sub.steps > 1} allows curvature within facets.
Similarly, if \code{do_grid} is \code{TRUE}, it allows 
curvature within grid lines.}
  \item{vars}{A dataframe containing the variables to plot
in the first three columns, with the response assumed to be in
column 1.  See the Note below.}
  \item{clip_to_density}{
If positive, the surface, plane or grid will be clipped to a region with sufficient data.
  }
  \item{\dots}{
Other parameters to pass to the default \code{\link{plot3d}} method, to control the appearance of aspects of the plot
other than the plane.
}
}
\details{
Three plots are possible, depending on the value(s) in \code{which}:
\enumerate{
\item{(default) Show the points and the fitted plane or surface.}
\item{Show the residuals and the plane at \code{z = 0}.}
\item{Show the predicted values on the fitted plane or surface.}
}

If \code{clip_to_density} is positive, then the
surface, plane or grid will be clipped to 
the region where a non-parametric density estimate
(using \code{MASS::\link{kde2d}}), normalized to have a
maximum value of 1, is greater than the given value.
This will suppress parts of the plot that aren't 
supported by the observed data.  
}
\value{
Called for the side effect of drawing one or more plots.

Invisibly returns a high-level vector of object ids.  Names of
object ids have the plot number (in drawing order) appended.
}
\note{
The default value for the \code{vars} argument will handle
simple linear models with a response and two predictors, and
some models with functions of those two predictors.  For 
models that fail (e.g. models using \code{\link{poly}}), you
can include the observed values as in the third example below.

If \code{clip_to_density > 0},
\enumerate{
\item{The clipping is
approximate, so it may not agree perfectly between
surfaces, planes and grids.}
\item{This option requires the suggested packages
\pkg{MASS} and \pkg{akima}, and will be ignored with
a warning if either is not installed.}
}
}
\author{
Duncan Murdoch
}
\examples{
open3d()
ids <- plot3d(lm(mpg ~ wt + qsec, data = mtcars), which = 1:3)
names(ids)

open3d()
plot3d(lm(mpg ~ wt + I(wt^2) + qsec, data = mtcars))

open3d()
# Specify vars in the order:  response, pred1, pred2.
plot3d(lm(mpg ~ poly(wt, 3) + qsec, data = mtcars), 
       vars = mtcars[,c("mpg", "wt", "qsec")])
       
open3d()
# Clip parts of the plot with few (wt, qsec) points
plot3d(lm(mpg ~ poly(wt, 3) + qsec, data = mtcars), 
       vars = mtcars[,c("mpg", "wt", "qsec")],
       clip_to_density = 0.1)       
}
