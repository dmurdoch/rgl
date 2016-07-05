\name{elementId2Prefix}
\alias{elementId2Prefix}
\title{
Use widget with old-style controls.
}
\description{
The \code{\link{rglwidget}} control is designed to work in the
\pkg{htmlwidgets} framework.  Older \pkg{rgl} web pages that
used \code{\link{writeWebGL}} or \pkg{knitr} used a different
method of linking the controls to the scene.  This is a partial
bridge between the two systems.
}
\usage{
elementId2Prefix(elementId, prefix = elementId)
}
\arguments{
  \item{elementId}{
An element identifier from a \code{\link{rglwidget}} call.
}
  \item{prefix}{
The prefix to use in the old-style control.
}
}
\details{
Because of the order of initialization, this isn't a perfect
bridge.  The old-style control will not set the scene to the initial
value from the control, but subsequent changes to the control
should be passed to the widget.
}
\value{
This function generates Javascript code, so it should be
used in an \code{results = "asis"} block in a \pkg{knitr} document.
}
\author{
Duncan Murdoch
}
\examples{
\dontrun{
rglwidget(elementId = "thewidget")
elementId2Prefix("thewidget", "theprefix")
subsetSlider(subsets = as.list(1:5),
             prefixes = "theprefix", subscenes = 1)
}
}
