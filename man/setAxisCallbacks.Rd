\name{setAxisCallbacks}
\alias{setAxisCallbacks}
\title{
User-defined axis labelling callbacks.
}
\description{
This function sets user callbacks to construct axes in R or
\code{\link{rglwidget}} displays.
}
\usage{
setAxisCallbacks(axes, fns, 
                 javascript = NULL, 
                 subscene = scene$rootSubscene$id, 
                 scene = scene3d(minimal = FALSE), 
                 applyToScene = TRUE, 
                 applyToDev = missing(scene))
}
\arguments{
  \item{axes}{
Which axes?  Specify as number in \code{1:3} or letter in
\code{c("x", "y", "z")}.
}
  \item{fns}{
Function or list of functions or character vector giving
names of functions.
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

The functions should have a header of the form 
\code{function(margin)}.  The \code{margin} argument
will be a string like \code{"x++"} indicating which margin
would be chosen by R.  If RGL would not choose to draw any
axis annotations (which can happen if all edges along that
axis are hidden), only the letter will be passed,
e.g. \code{"x"}.

}
\value{
Invisibly returns an \code{rglScene} object.  This
object will record the changes if \code{applyToScene}
is \code{TRUE}.

If \code{applyToDev} is \code{TRUE}, it will also 
have the side effect of attempting to install the
callbacks.
}
\seealso{
\code{\link{setUserCallbacks}} for mouse callbacks.
}
\author{
Duncan Murdoch
}
\examples{
# Draw arrows instead of tick marks on axes

arrowAxis <- local({
  ids <- c(NA, NA, NA)
  bbox <- c(NA, NA, NA, NA, NA, NA)
  function(margin) {
    dim <- if (grepl("x", margin)) 1 else
           if (grepl("y", margin)) 2 else
           3
    inds <- 2*dim + (-1):0
    range <- par3d("bbox")[inds]
    if (!identical(bbox[inds], range)) {
      if (!is.na(ids[dim]))
        pop3d(id = ids[dim])
       
      bbox[inds] <<- range 
      center <- mean(range)
      from <- mean(c(range[1], center))
      to <- mean(c(center, range[2]))
      # margin should agree with suggestion, so use "x++" etc.
      margin <- gsub("-", "+", margin)
      ids[dim] <<- arrow3d(p0 = c(from, 1, 1), 
                         p1 = c(to, 1, 1),
                         n = 4,
                         type = "lines",
                         margin = margin,
                         floating = TRUE)
    }
  }
})

# Define the Javascript function with the same name to use in WebGL
# Since Javascript won't change the bounding box, this function
# doesn't need to do anything.
  
js <- "
window.arrowAxis = function(margin) {} ;
"

xyz <- matrix(rnorm(60), ncol = 3)
plot3d(xyz, xlab = "x", ylab = "y", zlab = "z")
setAxisCallbacks(1:3, "arrowAxis", javascript = js)
rglwidget()
}
