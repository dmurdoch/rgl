\name{setUserCallbacks}
\alias{setUserCallbacks}
\title{
Set callbacks in Javascript code
}
\description{
This function sets user callbacks in \code{\link{rglwidget}} displays.
}
\usage{
setUserCallbacks(button, begin = NULL, update = NULL, end = NULL, 
                 javascript = NULL, 
                 subscene = scene$rootSubscene$id, scene = scene3d(minimal), 
                 minimal = TRUE)
}
\arguments{
  \item{button}{
Which button should this callback apply to? Can
be numeric from \code{1:4}, or character from \code{"left", "right", "center", "default"}.
}
  \item{begin, update, end}{
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
  \item{minimal}{
Should scene be made minimal?
}
}
\details{
Currently this function only adds Javascript 
callbacks to \code{\link{scene3d}} objects.  Plans
are to have it handle R callbacks as well (currently
\code{rgl.setMouseCallbacks} does that).

The callbacks are specified as strings; these will be
evaluated within the browser in the global context to define the functions, 
which will then be called with the Javascript
\code{this} object set to the current
\code{rglwidgetClass} object.

The \code{begin} and \code{update} functions should be 
of the form
\code{function(x, y) { ... }}.  The \code{end} function
will be called with no arguments.

The \code{javascript} argument is an optional block 
of code which will be evaluated once during the 
initialization of the widget.  It can define functions
and assign them as members of the \code{window} object,
and then the names of those functions can be given 
in the callback arguments; this allows the callbacks
to share information.
}
\value{
Currently returns an \code{rglScene} object
recording the changes.
}
\author{
Duncan Murdoch
}
\examples{
  plot3d(rnorm(10), rnorm(10), rnorm(10), type = "s")
  js <-
   ' var startx, starty;
   
     window.rglbegin = function(x, y) { 
       startx = x;
       starty = y;
       console.log("start at ("+x,","+y+")");
     };
     
     window.rglupdate = function(x, y) { 
       console.log("move from ("+startx+","+starty+") to ("+x+","+y+")");
     };
     
     window.rglend = function() { 
       console.log("end");
     }; '
     
  scene <- setUserCallbacks("default",
                            begin = "rglbegin",
                            update = "rglupdate",
                            end = "rglend",
                            javascript = js)
  rglwidget(scene)
}
