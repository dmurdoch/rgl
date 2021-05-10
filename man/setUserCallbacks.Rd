\name{setUserCallbacks}
\alias{setUserCallbacks}
\title{
Set callbacks in Javascript code
}
\description{
This function sets user callbacks in \code{\link{rglwidget}} displays.
}
\usage{
setUserCallbacks(button, 
                 begin = NULL, 
                 update = NULL, 
                 end = NULL, 
                 rotate = NULL,
                 javascript = NULL, 
                 subscene = scene$rootSubscene$id,
                 scene = scene3d(minimal = FALSE),
                 applyToScene = TRUE,
			           applyToDev = missing(scene))
}
\arguments{
  \item{button}{
Which button should this callback apply to? Can
be numeric from \code{1:5}, or character from \code{"left", "right", "center", "wheel", "default"}.
}
  \item{begin, update, end, rotate}{
Functions to call when events occur.  See Details.
}
  \item{javascript}{
Optional block of Javascript code to be
included (at the global level).
}
  \item{subscene}{
Which subscene do these callbacks apply to?
}
  \item{scene}{
Which scene?
}
  \item{applyToScene}{
Should these changes apply to the scene object?
}
  \item{applyToDev}{
Should these changes apply to the current device?
  }
}
\details{
If \code{applyToScene} is \code{TRUE}, this function adds Javascript 
callbacks to the \code{scene} object.  
If \code{applyToDev} is \code{TRUE}, it adds R
callbacks to the current RGL device.

For Javascript, 
the callbacks are specified as strings; these will be
evaluated within the browser in the global context to define the functions, 
which will then be called with the Javascript
\code{this} object set to the current
\code{rglwidgetClass} object.

For R, they may be strings or R functions.

Both options may be \code{TRUE}, in which case the
callbacks must be specified as strings which are 
both valid Javascript and valid R.  The usual way to
do this is to give just a function name, with the
function defined elsewhere, as in the Example below.

The \code{begin} and \code{update} functions should be 
of the form
\code{function(x, y) { ... }}.  The \code{end} function
will be called with no arguments.  

The \code{rotate} callback can only be set on the 
mouse wheel.  It is called when the mouse 
wheel is rotated.  It should be of the form
\code{function(away)}, where \code{away} will be 1
while rotating the wheel \dQuote{away} from you,
and 2 while rotating it towards you.  If \code{rotate}
is not set but other callbacks are set on the wheel
\dQuote{button}, then each click of the mouse wheel
will trigger all \code{start}, \code{update}, 
then \code{end} calls in sequence.

The \code{javascript} argument is an optional block 
of code which will be evaluated once during the 
initialization of the widget.  It can define functions
and assign them as members of the \code{window} object,
and then the names of those functions can be given 
in the callback arguments; this allows the callbacks
to share information.
}
\value{
Invisibly returns an \code{rglScene} object.  This
object will record the changes if \code{applyToScene}
is \code{TRUE}.

If \code{applyToDev} is \code{TRUE}, it will also 
have the side effect of attempting to install the
callbacks using \code{\link{rgl.setMouseCallbacks}}
and \code{\link{rgl.setWheelCallback}}.
}
\author{
Duncan Murdoch
}
\examples{
  id <- plot3d(rnorm(11), rnorm(11), rnorm(11), type = "s", main = "Click and move")["data"]
  
  # Define the R function to use within R
  rglupdate <- local({
    id <- id
    index <- 0
    coord <- 0
    jump <- 1
    radius <- rgl.attrib(id, "radii")[1]
    function(x, y) {
      save <- par3d(skipRedraw = TRUE)
      on.exit(par3d(save))
      verts <- rgl.attrib(id, "vertices")
      pop3d(id = id)
      verts[index+1, coord+1] <- verts[index+1, coord+1] + jump
      id <<- spheres3d(verts, radius = radius)
      index <<- (index + 1) \%\% 11
      coord <<- (coord + 1) \%\% 3
      jump <<- -jump
    }
  })
  
  # Define the Javascript function with the same name to use in WebGL
  js <-
   ' var startx, starty, id = \%id\%, index = 0, coord = 0, jump = 1;
   
     window.rglupdate = function(x, y) { 
       var obj;
       startx = x;
       starty = y;
       obj = this.getObj(id);
       obj.vertices[index][coord] += jump;
       obj.initialized = false;
       this.drawScene();
       index = (index + 1) \% 11;
       coord = (coord + 1) \% 3;
       jump = -jump;
     }; '
  js <- sub("\%id\%", id, js)  
    
  # Install both
  setUserCallbacks("left",
                    update = "rglupdate",
                    javascript = js)
                    
  rglwheel <- function(away) {
    cat("away = ", away, "\n")
  }
  js <- '
    window.rglwheel = function(away) {
      console.log("away = "+away);
    };
  '
  setUserCallbacks("wheel",
                   rotate = "rglwheel",
                   javascript = js)               
  rglwidget()
}
