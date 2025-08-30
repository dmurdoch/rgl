\name{asRow}
\alias{asRow}
\alias{getWidgetId}
\title{
Convenience functions for RGL HTML layouts
}
\description{
The \code{asRow} function arranges objects in a row in the display;
the \code{getWidgetId} function extracts the HTML element ID
from an HTML widget.
}
\usage{
asRow(..., last = NA, height = NULL, colsize = 1)
getWidgetId(widget)
}
\arguments{
  \item{\dots}{
Either a single \code{"combineWidgets"} object produced by
\code{asRow} or a \code{\%>\%} pipe of RGL objects, 
or several objects intended for rearrangement.
}
  \item{last}{
If not \code{NA}, the number of objects from \code{...} that
are to be arranged in a row.  Earlier ones will remain in a column.
}
  \item{height}{
An optional height for the resulting row.  This is normally specified
in pixels, but will be rescaled as necessary to fit the display.
}
  \item{colsize}{
A vector of relative widths for the columns in the row.
}
  \item{widget}{
A single HTML widget from which to extract the HTML element ID.
  }
}
\details{
Using \code{asRow} requires that the \pkg{manipulateWidget}
package is installed.

\code{asRow} produces a \code{"combineWidgets"} object which
is a single column whose last element is another \code{"combineWidgets"} object which is a single row.

If \code{n} objects are given as input and \code{last} is given a value
less than \code{n}, the first \code{n - last} objects will be displayed
in a column above the row containing the \code{last} objects.
}
\value{
\code{asRow} returns a single \code{"combineWidgets"} object suitable for display or nesting
within a more complicated display.

\code{getWidgetId} returns a character string containing the 
HTML element ID of the widget.
}
\author{
Duncan Murdoch
}

\seealso{
\link{pipe} for the \code{\%>\%} operator.  The \HTMLVignette{WebGL}{}{User Interaction in WebGL} vignette
gives more details.
}
\examples{
if (requireNamespace("manipulateWidget", quietly = TRUE) &&
    require("crosstalk", quietly = TRUE)) {
  sd <- SharedData$new(mtcars)
  ids <- plot3d(sd$origData(), col = mtcars$cyl, type = "s")
  # Copy the key and group from existing shared data
  rglsd <- rglShared(ids["data"], key = sd$key(), group = sd$groupName())
  w <- rglwidget(shared = rglsd) \%>\%
       asRow("Mouse mode: ", rglMouse(getWidgetId(.)), 
             "Subset: ", filter_checkbox("cylinderselector", 
		               "Cylinders", sd, ~ cyl, inline = TRUE),
             last = 4, colsize = c(1,2,1,2), height = 60)
  if (interactive() || in_pkgdown_example())
    w
}
}
