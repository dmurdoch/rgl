\name{playwidget}
\alias{playwidget}
\alias{playwidget.default}
\alias{playwidget.rglWebGL}
\alias{playwidget.rglPlayer}
\alias{playwidget.shiny.tag.list}
\title{
Add a widget to play animations.
}
\description{
This is a widget that can be put in a web page to allow
animations with or without Shiny.
}
\usage{
playwidget(sceneId, ...)

\S3method{playwidget}{default}(sceneId, controls,
            start = 0, stop = Inf, interval = 0.05, rate = 1,
            components = c("Reverse", "Play", "Slower", "Faster",
                           "Reset", "Slider", "Label"),
            loop = TRUE,
            step = 1, labels = NULL,
            precision = 3,
            elementId = NULL, respondTo = NULL,
            reinit = NULL,
            ...)

\S3method{playwidget}{rglWebGL}(sceneId, controls, elementId = NULL, ...)

\S3method{playwidget}{rglPlayer}(sceneId, controls, ...)

\S3method{playwidget}{shiny.tag.list}(sceneId, controls, elementId = NULL, ...)
}
\arguments{
  \item{sceneId}{
The HTML id of the rgl scene being controlled,
or an object.  See the Details below.
}
  \item{controls}{
A single \code{"rglControl"} object, e.g. \code{\link{propertyControl}}, or a list of several.
}
  \item{start, stop}{
The starting and stopping values of the animation.  If
\code{labels} is supplied \code{stop} will default to step
through the labels.
}
  \item{interval}{
The requested interval (in seconds) between updates.  Updates
may occur at longer intervals.
}
  \item{rate}{
The number of units of \dQuote{nominal} time per real world
second.
}
  \item{components}{
Which components should be displayed?  See Details below.
}
  \item{loop}{
When the player reaches the end of the interval,
should it loop back to the beginning?
}
  \item{step}{
Step size in the slider.
}
  \item{labels}{
Optional labels to use, corresponding to slider steps.  Set to
\code{NULL} for auto-generated labels.
}
  \item{precision}{
If \code{labels=NULL}, the precision to use when displaying
timer values.
}
  \item{elementId}{
The HTML id of the generated widget, containing buttons,
slider, etc.
}
  \item{respondTo}{
The HTML ID of a Shiny input control (e.g. a \code{\link[shiny]{sliderInput}}
control) to respond to.}

  \item{reinit}{
A vector of ids that will need re-initialization before
being drawn again.
}

  \item{...}{The default method passes additional arguments
to \code{htmlwidgets::\link{createWidget}}.}
}
\details{
The \code{components} are buttons to control the animation,
a slider for manual control, and a label to show the current
value.  They will be displayed in the order given in \code{components}.  Not all need be included.

The buttons have the following behaviour:
\describe{
\item{Reverse}{Reverse the direction.}
\item{Play}{Play the animation.}
\item{Slower}{Decrease the playing speed.}
\item{Faster}{Increase the playing speed.}
\item{Reset}{Stop the animation and reset to the start value.}
}

If \code{respondTo} is used, no \code{components} are shown, as it is assumed Shiny (or whatever control is being referenced) will provide the UI components.

The \code{sceneId} component can be another \code{playwidget} or a \code{\link{rglwidget}} result.  This allows you
to use a \pkg{magrittr}-style
\dQuote{pipe} command to join an \code{rglwidget} with one or more \code{\link{playwidget}}s.  If a \code{playwidget} comes
first, \code{sceneId} should be set to \code{NA}.  If
the \code{\link{rglwidget}} does not come first,
previous values should be piped into its \code{controllers}
argument.  Other HTML code (including other widgets)
can be used in the chain if wrapped in \code{htmltools::\link[htmltools]{tagList}}.
}
\section{Appearance}{
The appearance of the controls is set by the stylesheet
in \code{system.file("htmlwidgets/lib/rglClass/rgl.css")}.

The overall widget is of class \code{rglPlayer}, with id
set according to \code{elementId}.

The buttons are of HTML class \code{rgl-button}, the
slider is of class \code{rgl-slider}, and the label is of
class \code{rgl-label}.  Each element has an id prefixed
by the widget id, e.g. \code{elementId-button-Reverse},
\code{elementId-slider}, etc. (where \code{elementId}
should be replaced by the actual id).

The \code{reinit} parameter handles the case where
an object needs re-initialization after each change.  For
example, plane objects may need this if their intersection
with the bounding box changes shape.  Note that
re-initialization is generally incompatible with
the \code{\link{vertexControl}} as it modifies values
which are set during initialization.
}
\value{
A widget suitable for use in an \pkg{Rmarkdown}-generated web
page, or elsewhere.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{subsetControl}},
\code{\link{propertyControl}}, \code{\link{ageControl}} and
\code{\link{vertexControl}} are possible controls to use.
}
\examples{
saveopts <- options(rgl.useNULL = TRUE)

objid <- rgl::plot3d(1:10, 1:10, rnorm(10), col=c("red", "red"), type = "s")["data"]

control <- ageControl(value=0,
             births=1:10,
             ages = c(-5,0,5),
             colors = c("green", "yellow", "red"),
             objids = objid)

# This example uses explicit names

rglwidget(elementId = "theplot", controllers = "theplayer",
          height = 300, width = 300)
playwidget("theplot", control, start = -5, stop = 5,
           rate = 3, elementId = "theplayer",
           components = c("Play", "Slider"))

# This example uses pipes, and can skip the names

rglwidget(height = 300, width = 300) \%>\%
playwidget(control, start = -5, stop = 5,
           rate = 3, components = c("Play", "Slider"))


options(saveopts)
}
