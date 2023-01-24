\name{hover3d}
\alias{hover3d}
\title{
Display hover info in plot.
}
\description{
This adds text to identify points within a plot when the mouse is near 
them.
}
\usage{
hover3d(x, y = NULL, z = NULL, 
        labeller = NULL, 
        tolerance = 20, 
        persist = c("no", "one", "yes"), 
        labels = seq_along(x),
        adj = c(-0.2, 0.5),
        scene = scene3d(minimal = FALSE),
        applyToScene = TRUE,
        ...)
}
\arguments{
  \item{x, y, z}{
Coordinates of point to identify. Any reasonable way of defining the
coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}} for details.
}
  \item{labeller}{
A function to display information about identified points. \code{NULL}
indicates the default function, described in Details.
}
  \item{tolerance}{
How close (in pixels) the mouse should be to a point to display the
information.
}
  \item{persist}{
Should the label persist?  If \code{"no"} (the default), it will be removed
when the mouse moves away.  If \code{"one"}, it will be removed when 
another point is closer to the mouse.  If \code{"yes"}, it will 
not be removed.
}
  \item{labels}{
If the default \code{labeller} is used, these labels will be displayed.
}
  \item{adj}{
If the default \code{labeller} is used, this adjustment will be passed
to \code{\link{text3d}} to display the labels.
}
  \item{scene, applyToScene}{
Arguments to pass to \code{\link{setUserCallbacks}}.
The \code{applyToDev} argument to that function is always
\code{TRUE}.
}
  \item{\dots}{
Additional arguments that will be passed to the labeller.
}
}
\details{
If specified, the \code{labeller} argument should specify a
function with arguments
compatible with \code{function(index, ...)}.  It will be called with
\code{index} being the index of the point that was selected.  It should
plot the label, and return the \pkg{rgl} ids of the objects that were 
plotted.

When \code{applyToScene} is \code{TRUE}, all labels
or labelling objects will be created and attached to the scene.  You may want to
delete them (using the ids returned in \code{idverts} and
\code{idtexts}) once \code{\link{rglwidget}} has been called,
as they serve no purpose in the current device.

Only one hover handler is supported per scene or device.
}
\value{
A \code{\link{lowlevel}} vector of ids is returned invisibly.
If \code{applyToScene} is \code{TRUE}, it will contain the
ids of the temporary objects created for Javascript.
It will also have these attributes:
\item{oldPar}{Values of \code{\link{par3d}} parameters that were changed.
Currently only \code{"mouseMode"}.}
\item{oldDev}{The value of \code{cur3d()} at the time of calling, so that
\code{oldPar} can be restored to the right device.}
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{identify3d}} and \code{\link{selectpoints3d}}
work in the \pkg{rgl} device and return information
about the selections. \code{\link{setUserCallbacks}}
is the underlying function used by \code{hover3d}.
}
\examples{
# Create a labeller to show the coordinates of the selected point.
labelLocation <- function(x, y = NULL, z = NULL) {
  xyz <- xyz.coords(x, y, z)
  function(sel, ...) {
    p <- with(xyz, matrix(c(x[sel], y[sel], z[sel]), ncol = 3))
    c(text3d(p, texts = sprintf("x:\%.2f", p[1]), 
                  adj = c(-0.2, -0.6), ...),
      text3d(p, texts = sprintf("y:\%.2f", p[2]),
                  adj = c(-0.2, 0.5), ...),
      text3d(p, texts = sprintf("z:\%.2f", p[3]),
                  adj = c(-0.2, 1.6), ...))
  }
}

xyz <- matrix(rnorm(30), ncol = 3)
open3d()
plot3d(xyz)
hover3d(xyz, labeller = labelLocation(xyz), col = "red", cex = 0.8)
}
