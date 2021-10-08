\name{toggleWidget}
\alias{toggleWidget}
\title{
An HTML widget to toggle display of elements of a scene
}
\description{
This function produces a button in an HTML scene
that will toggle the display of items in the scene.
}
\usage{
toggleWidget(sceneId, 
             ids = tagged3d(tags), tags = NULL, hidden = integer(),
             subscenes = NULL, 
             label, 
             ...)
}
\arguments{
  \item{sceneId}{
The HTML id of the RGL scene being controlled,
or an object as in \code{\link{playwidget}}.
}
  \item{ids, hidden}{
The RGL id numbers of the objects to toggle.  Those in \code{ids}
are initially shown; those in \code{hidden} are initially hidden.
}
  \item{tags}{
  Alternate way to specify \code{ids}.  Ignored if \code{ids} is
given.
  }
  \item{subscenes}{
The subscenes in which to toggle the objects.
}
  \item{label}{
The label to put on the button.  The default is set
from the expression passed to \code{ids} or the value of \code{tags}. 
}
  \item{\dots}{
Additional arguments to pass to \code{\link{playwidget}}.
}
}
\details{
Like \code{\link{playwidget}}, this function is designed
to work within the \pkg{htmlwidgets} framework.  
If the value is printed, the button will be inserted
into the output.

It is also designed to work with \pkg{magrittr}-style
pipes:  the result of \code{\link{rglwidget}} or
other widgets can be piped into it to add it 
to a display.  It can also appear first in the 
pipeline, if \code{sceneId} is set to \code{NA}.
}
\value{
A widget suitable for use in an \pkg{Rmarkdown}-generated web
page, or elsewhere.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{toggleButton}} for the older style
of HTML control.
}
\examples{
theplot <- plot3d(rnorm(100), rnorm(100), rnorm(100), col = "red")
widget <- rglwidget(height = 300, width = 300) \%>\%
  toggleWidget(theplot["data"], 
               hidden = theplot[c("xlab", "ylab", "zlab")], 
               label = "Points")
if (interactive() || in_pkgdown_example())
  widget
}
