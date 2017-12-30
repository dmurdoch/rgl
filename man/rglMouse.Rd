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
         default = par3d("mouseMode", dev = dev, subscene = subscene)[button])
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
}
\details{
A result of an \code{\link{rglwidget}} call can be passed
as the \code{sceneId} argument.  This allows the widget
to be \dQuote{piped} into the \code{rglMouse} call,
but piping is not a requirement.

If the \code{sceneId} is an rgl widget, the function will return both the widget and the selector
in a \code{\link[htmltools]{tagList}}.  To place the
selector in a different location, extract the \code{elementId} from the widget and use it as the \code{sceneId}
argument instead, as in the second example below.
}
\value{
A browsable value to put in a web page.
}
\author{
Duncan Murdoch
}
\examples{
open3d()
xyz <- matrix(rnorm(300), ncol = 3)
id <- plot3d(xyz, col = "red", type = "s")["data"]
par3d(mouseMode = "selecting")
share <- rglShared(id)

# This puts the selector below the widget.
if (interactive())
  rglwidget(shared = share, width = 300, height = 300) \%>\% rglMouse()
  
# This puts the selector above the widget.
w <- rglwidget(shared = share, width = 300, height = 300)
htmltools::browsable(htmltools::tagList(rglMouse(w$elementId), w))
}
