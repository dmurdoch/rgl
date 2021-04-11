\name{figWidth}
\alias{figWidth}
\alias{figHeight}
\title{
Get R Markdown figure dimensions in pixels
}
\description{
In an R Markdown document, figure dimensions are normally
specified in inches; these are translated into pixel
dimensions when HTML output is requested and \code{\link{rglwidget}} is used.  These functions reproduce that
translation.
}
\usage{
figWidth()
figHeight()
}
\value{
When used in an R Markdown document, these functions
return the requested current dimensions of figures in pixels.  Outside such a document, \code{NULL}
is returned.
}
\author{
Duncan Murdoch
}

\examples{
# No useful return value outside of R Markdown:
figWidth()
figHeight()
}
