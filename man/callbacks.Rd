\name{rgl.setMouseCallbacks}
\alias{rgl.setMouseCallbacks}
\alias{rgl.getMouseCallbacks}
\alias{rgl.setWheelCallback}
\alias{rgl.getWheelCallback}
\title{ User callbacks on mouse events }
\description{
  Set and get user callbacks on mouse events.
}
\usage{
rgl.setMouseCallbacks(button, begin = NULL, update = NULL, end = NULL, 
                      dev = cur3d(), subscene = currentSubscene3d(dev))
rgl.getMouseCallbacks(button, 
                      dev = cur3d(), subscene = currentSubscene3d(dev))

rgl.setWheelCallback(rotate, 
                      dev = cur3d(), subscene = currentSubscene3d(dev))

rgl.getWheelCallback(dev = cur3d(), subscene = currentSubscene3d(dev))

}
\arguments{
  \item{button}{ Which button? Use 4 for \dQuote{default} handler. }
  \item{begin}{ Called when mouse down event occurs }
  \item{update}{ Called when mouse moves }
  \item{end}{ Called when mouse is released }
  \item{rotate}{ Called when mouse wheel is rotated }
  \item{dev, subscene}{The RGL device and subscene to work with }
}
\details{
The set functions set event handlers on mouse events that occur within the current RGL window.
The \code{begin} and \code{update} events should be functions taking two arguments; these
will be the mouse coordinates when the event occurs.  The \code{end} event handler
takes no arguments.  The \code{rotate} event takes a single argument, which will be 
equal to \code{1} if the user pushes the wheel away by one click, and \code{2} if 
the user pulls the wheel by one click.

Alternatively, the handlers may be set to \code{NULL}, the default value, in which case
no action will occur.

If a subscene has multiple listeners, the user action will still only be called for the
subscene that received the mouse event.  It should consult \code{\link{par3d}("listeners")}
if it makes sense to take action on the whole group of subscenes.

The get function retrieves the callbacks that are currently set.

The \dQuote{default} mouse handler may be set by
specifying \code{button = 4}.  The \code{begin}
function will be called the first time the mouse
moves within the subscene, and the \code{update}
function will be called repeatedly as it moves.  The
\code{end} function will never be called.
}
\value{
The set functions are called for the side effect of setting the mouse event handlers.

The \code{rgl.getMouseCallbacks} function returns a list containing the callback functions or \code{NULL} if no user callback is set.
The \code{rgl.getWheelCallback} returns the callback function or \code{NULL}.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{par3d}} to set built-in handlers }
\examples{

 pan3d <- function(button, dev = cur3d(), subscene = currentSubscene3d(dev)) {
   start <- list()
   
   begin <- function(x, y) {
     activeSubscene <- par3d("activeSubscene", dev = dev)
     start$listeners <<- par3d("listeners", dev = dev, subscene = activeSubscene)
     for (sub in start$listeners) {
       init <- par3d(c("userProjection","viewport"), dev = dev, subscene = sub)
       init$pos <- c(x/init$viewport[3], 1 - y/init$viewport[4], 0.5)
       start[[as.character(sub)]] <<- init
     }
   }
   
   update <- function(x, y) {
     for (sub in start$listeners) {
       init <- start[[as.character(sub)]]
       xlat <- 2*(c(x/init$viewport[3], 1 - y/init$viewport[4], 0.5) - init$pos)
       mouseMatrix <- translationMatrix(xlat[1], xlat[2], xlat[3])
       par3d(userProjection = mouseMatrix \%*\% init$userProjection, dev = dev, subscene = sub )
      }
   }
   rgl.setMouseCallbacks(button, begin, update, dev = dev, subscene = subscene)
   cat("Callbacks set on button", button, "of RGL device", dev, "in subscene", subscene, "\n")
 }
 open3d()
 shade3d(icosahedron3d(), col = "yellow")
 # This only works in the internal display...
 pan3d(1)
}
\keyword{ dynamic }
