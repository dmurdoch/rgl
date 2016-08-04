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
rgl.setMouseCallbacks(button, begin = NULL, update = NULL, end = NULL)
rgl.getMouseCallbacks(button)
rgl.setWheelCallback(rotate)
rgl.getWheelCallback()
}
\arguments{
  \item{button}{ Which button?  }
  \item{begin}{ Called when mouse down event occurs }
  \item{update}{ Called when mouse moves }
  \item{end}{ Called when mouse is released }
  \item{rotate}{ Called when mouse wheel is rotated }
}
\details{
The set functions set event handlers on mouse events that occur within the current rgl window.
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
}
\value{
The set functions are called for the side effect of setting the mouse event handlers.

The \code{rgl.getMouseCallbacks} function returns a list containing the callback functions or \code{NULL} if no user callback is set.
The \code{rgl.getWheelCallback} returns the callback function or \code{NULL}.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{par3d}} to set built-in handlers }
\examples{

## Not quite right --- this doesn't play well with rescaling

 pan3d <- function(button) {
   start <- list()
   
   begin <- function(x, y) {
       start$userMatrix <<- par3d("userMatrix")
       start$viewport <<- par3d("viewport")
       start$scale <<- par3d("scale")
       start$projection <<- rgl.projection()
       start$pos <<- rgl.window2user( x/start$viewport[3], 1 - y/start$viewport[4], 0.5, 
                                      projection = start$projection)
   }
   
   update <- function(x, y) {
        xlat <- (rgl.window2user( x/start$viewport[3], 1 - y/start$viewport[4], 0.5,
                                 projection = start$projection) - start$pos)*start$scale
        mouseMatrix <- translationMatrix(xlat[1], xlat[2], xlat[3])
        par3d(userMatrix = start$userMatrix \%*\% t(mouseMatrix) )
   }
   rgl.setMouseCallbacks(button, begin, update)
   cat("Callbacks set on button", button, "of rgl device", rgl.cur(), "\n")
 }
 shade3d(icosahedron3d(), col = "yellow")
 pan3d(3)
}
\keyword{ dynamic }
