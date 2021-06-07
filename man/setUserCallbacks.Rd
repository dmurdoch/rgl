\name{setUserCallbacks}
\alias{setUserCallbacks}
\title{
Set mouse callbacks in R or Javascript code
}
\description{
This function sets user mouse callbacks in R or
\code{\link{rglwidget}} displays.
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
be numeric from \code{0:4}, or character from \code{"none", "left", "right", "center", "wheel"}.
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
\seealso{
\code{\link{setAxisCallbacks}} for user defined axes.
}
\author{
Duncan Murdoch
}
\examples{
  verts <- cbind(rnorm(11), rnorm(11), rnorm(11))
  idverts <- plot3d(verts, type = "s", col = "blue")["data"]
  
  # Plot some invisible text; the Javascript will move it
  idtext <- text3d(verts[1,,drop = FALSE], texts = 1, adj = c(0.5, -1.5), alpha = 0)
  
  # Define the R functions to use within R
  fns <- local({
    idverts <- idverts
    idtext <- idtext
    closest <- -1
    update <- function(x, y) {
      save <- par3d(skipRedraw = TRUE)
      on.exit(par3d(save))
      rect <- par3d("windowRect")
      size <- rect[3:4] - rect[1:2]
      x <- x / size[1];
      y <- 1 - y / size[2];
      verts <- rgl.attrib(idverts, "vertices")
      # Put in window coordinates
      vw <- rgl.user2window(verts)
      dists <- sqrt((x - vw[,1])^2 + (y - vw[,2])^2)
      newclosest <- which.min(dists)
      if (newclosest != closest) {
        if (idtext > 0)
          pop3d(id = idtext)
        closest <<- newclosest
        idtext <<- text3d(verts[closest,,drop = FALSE], texts = closest, adj = c(0.5, -1.5))
      }
    }
    end <- function() {
      if (idtext > 0)
        pop3d(id = idtext)
      closest <<- -1
      idtext <<- -1
    }
    list(rglupdate = update, rglend = end)
  })
  rglupdate <- fns$rglupdate
  rglend <- fns$rglend
  
  # Define the Javascript functions with the same names to use in WebGL
  js <-
   ' var idverts = \%id\%, idtext = \%idtext\%, closest = -1,
         subid = \%subid\%;
   
     window.rglupdate = function(x, y) { 
       var   obj = this.getObj(idverts), i, newdist, dist = Infinity, pt, newclosest;
       x = x/this.canvas.width;
       y = y/this.canvas.height;
       
       for (i = 0; i < obj.vertices.length; i++) {
         pt = obj.vertices[i].concat(1);
         pt = this.user2window(pt, subid);
         pt[0] = x - pt[0];
         pt[1] = y - pt[1];
         pt[2] = 0;
         newdist = this.vlen(pt);
         if (newdist < dist) {
           dist = newdist;
           newclosest = i;
         }
       }

       if (newclosest !== closest) {
         closest = newclosest
         var text = this.getObj(idtext);
         text.vertices[0] = obj.vertices[closest];
         text.colors[0][3] = 1; // alpha is here!
         text.texts[0] = (closest + 1).toString();
         text.initialized = false;
         this.drawScene();
       }
     };
     window.rglend = function() {
       var text = this.getObj(idtext);
       text.colors[0][3] = 0;
       text.initialized = false;
       this.drawScene();
     }'
  js <- sub("\%id\%", idverts, js)  
  js <- sub("\%subid\%", subsceneInfo()$id, js)
  js <- sub("\%idtext\%", idtext, js)
    
  # Install both
  setUserCallbacks("left",
                    begin = "rglupdate",
                    update = "rglupdate",
                    end = "rglend",
                    javascript = js)
  rglwidget()
}
