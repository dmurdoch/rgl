\name{shiny}
\alias{rglwidgetOutput}
\alias{renderRglwidget}
\alias{playwidgetOutput}
\alias{renderPlaywidget}
\title{
Functions for integration of \code{\link{rglwidget}} into
Shiny app.
}
\description{
These functions allow an \pkg{rgl} scene to be embedded
in a Shiny app.
}
\usage{
rglwidgetOutput(outputId, width = "512px", height = "512px")
renderRglwidget(expr, env = parent.frame(), quoted = FALSE)

playwidgetOutput(outputId, width = "0px", height = "0px")
renderPlaywidget(expr, env = parent.frame(), quoted = FALSE)
}
\arguments{
  \item{outputId}{
The name for the control.
}
  \item{width, height}{
Width and height to display the control.
}
  \item{expr}{An R expression returning
a \code{\link{rglwidget}} (for \code{renderRglwidget}) or a \code{\link{playwidget}} (for \code{renderPlaywidget}) as output.}
  \item{env}{The environment in which to evaluate \code{expr}.}
  \item{quoted}{Is the expression already quoted?}
}
\details{
Use \code{rglwidgetOutput} or \code{playwidgetOutput} as an output
object in a Shiny user
interface section; use \code{renderRglwidget} or \code{renderPlaywidget}
as the render
function in the server section.
}
\value{
Used internally by Shiny.
}
\author{
Duncan Murdoch
}
