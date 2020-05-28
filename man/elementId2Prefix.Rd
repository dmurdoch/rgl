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
bridge between the two systems.  You should adopt the new system, not use this function.
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
\value{
This function generates Javascript code, so it should be
used in an \code{results = "asis"} block in a \pkg{knitr} document.
}
\author{
Duncan Murdoch
}
