\name{shiny}
\alias{rglwidgetOutput}
\alias{renderRglwidget}
\alias{playwidgetOutput}
\alias{renderPlaywidget}
\title{
Functions for integration of RGL widgets into
Shiny app
}
\description{
These functions allow an RGL scene to be embedded
in a Shiny app.
}
\usage{
rglwidgetOutput(outputId, width = "512px", height = "512px",
                altText = "Rotatable plot")
renderRglwidget(expr, env = parent.frame(), quoted = FALSE, outputArgs = list())

playwidgetOutput(outputId, width = "0px", height = "0px")
renderPlaywidget(expr, env = parent.frame(), quoted = FALSE, outputArgs = list())
}
\arguments{
  \item{outputId}{
The name for the control.
}
  \item{width, height}{
Width and height to display the control.
}
  \item{altText}{Fixed alternate text to display to screen readers.}
  \item{expr}{An R expression returning
a \code{\link{rglwidget}} (for \code{renderRglwidget}) or a \code{\link{playwidget}} (for \code{renderPlaywidget}) as output.}
  \item{env}{The environment in which to evaluate \code{expr}.}
  \item{quoted}{Is the expression already quoted?}
  \item{outputArgs}{A list containing arguments; see details below.}
}
\details{
Use \code{rglwidgetOutput} or \code{playwidgetOutput} as an output
object in a Shiny user
interface section; use \code{renderRglwidget} or \code{renderPlaywidget}
as the render
function in the server section.

In a dynamic R Markdown document with \code{runtime: shiny}, you 
only call the render function, and may optionally pass \code{width}
and \code{height} to the output function by putting them in
a list in \code{outputArgs}.  See the example below.
}
\note{
The \code{altText} argument is experimental.  Currently it will 
not work if 
it is specified in \code{rglwidget} in a Shiny display, it needs
to be in \code{rglwidgetOutput}.  But in the long run it really
belongs in \code{renderRglwidget}, where it could be a reactive
value. In some future version it will probably move there.
}
\value{
Used internally by Shiny.
}
\author{
Duncan Murdoch
}
\examples{
\dontrun{
# This could be used in a dynamic R Markdown document.  See
# demo("shinyDemo") and demo("simpleShinyRgl") for Shiny apps.

inputPanel(
  sliderInput("n", label = "n", min = 10, max = 100, value = 10, step = 10)
)

renderRglwidget({
    n <- input$n
    try(close3d())
    plot3d(rnorm(n), rnorm(n), rnorm(n))
    rglwidget()
  }, outputArgs = list(width = "auto", height = "300px"))

}
}

