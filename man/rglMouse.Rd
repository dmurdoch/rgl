\name{rglMouse}
\alias{rglMouse}
\title{
Generate HTML code to select mouse mode.
}
\description{
This generates an HTML \code{select} element to 
choose among the mouse modes supported by \code{\link{rglwidget}}.
}
\usage{
rglMouse(sceneId, 
         choices = c("trackball", "selecting", 
                     "xAxis", "yAxis", "zAxis", 
                     "polar", "zoom", "fov", 
                     "none"), 
         labels = choices, 
         button = 1, 
         dev = rgl.cur(), 
         subscene = currentSubscene3d(dev), 
         default = par3d("mouseMode", dev = dev, subscene = subscene)[button],
         stayActive = FALSE,
         height = 40,
         ...)
}
\arguments{
  \item{sceneId}{
Either an \code{\link{rglwidget}} or the \code{elementId}
from one of them.
}
  \item{choices}{
Which mouse modes to support?
}
  \item{labels}{
How to label each mouse mode.
}
  \item{button}{
Which mouse button is being controlled.
}
  \item{dev}{
The rgl device used for defaults.
}
  \item{subscene}{
Which subscene is being modified.
}
  \item{default}{
What is the default entry to show in the control.
}
  \item{stayActive}{
Whether a selection brush should stay active if the
mouse mode is changed.
}
  \item{height}{
The (relative) height of the item in the output display.
}
  \item{...}{
Additional arguments to pass to \code{htmltools::tags$select()}, e.g. \code{id} or \code{class}.
}
}
\details{
A result of an \code{\link{rglwidget}} call can be passed
as the \code{sceneId} argument.  This allows the widget
to be \dQuote{piped} into the \code{rglMouse} call.
The widget will appear first, the selector next in
a \code{\link[htmltools:tag]{tagList}}.

If the \code{sceneId} is a character string, it should be
the \code{elementId} of a separately constructed
\code{\link{rglwidget}} result.

Finally, the \code{sceneId} can be omitted.  In this case
the \code{rglMouse} result needs to be passed into an
\code{\link{rglwidget}} call as part of the
\code{controllers} argument.  This will place the selector before the
widget on the resulting display.

If the mouse mode is changed while brushing the scene, 
by default the brush will be removed (and so the selection
will be cleared too).  If this is not desired, set
\code{stayActive = TRUE}.
}
\value{
A browsable value to put in a web page.
}
\author{
Duncan Murdoch
}
\examples{
if (interactive()) {
  open3d()
  xyz <- matrix(rnorm(300), ncol = 3)
  id <- plot3d(xyz, col = "red", type = "s")["data"]
  par3d(mouseMode = "selecting")
  share <- rglShared(id)

# This puts the selector below the widget.
  rglwidget(shared = share, width = 300, height = 300) \%>\% rglMouse()
  
# This puts the selector above the widget.
  rglMouse() \%>\% rglwidget(shared = share, width = 300, height = 300, controllers = .) 
}
}
