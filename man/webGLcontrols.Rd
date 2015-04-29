\name{webGLcontrols}
\alias{subsetSlider}
\alias{subsetSetter}
\alias{clipplaneSlider}
\alias{toggleButton}
\title{
Write HTML/Javascript code to control a WebGL display.
}
\description{
These functions write out HTML code to control WebGL displays on the same page.
}
\usage{
subsetSlider(subsets, labels = names(subsets), 
             fullset = Reduce(union, subsets),
             subscenes = currentSubscene3d(), prefixes = "",
             ...)
             
subsetSetter(subsets, subscenes = currentSubscene3d(), prefixes = "", 
			 fullset = Reduce(union, subsets))
             
clipplaneSlider(a=NULL, b=NULL, c=NULL, d=NULL, 
                plane = 1, clipplaneids, prefixes = "", 
                labels = signif(values[,1],3), ...)
             
toggleButton(subset, subscenes = currentSubscene3d(), prefixes = "", 
             label = deparse(substitute(subset)), 
             id = paste0(basename(tempfile("input"))), name = id) 
}
\arguments{
  \item{subsets}{A list of vectors of object identifiers; the slider or setter
  will choose among them.}
  \item{labels}{Labels to display corresponding to each subset.  If \code{NULL},
  numeric labels will be shown.}
  \item{fullset}{Objects in the subscene which are not in \code{fullset}
  will not be touched.}
  \item{subscenes}{The subscenes to be controlled.}  
  \item{prefixes}{The prefixes of the WebGL scenes to be controlled.}
  \item{id}{The \code{id} of the input control that will be generated.}
  \item{name}{The name of the input control that will be generated.}
  \item{...}{Arguments to pass to \code{\link{propertySlider}}.}
  \item{a,b,c,d}{The parameter values to change.  Leave as \code{NULL}
  to hold the parameter constant.}
  \item{plane, clipplaneids}{The identifier of the particular clipplane
  to modify.}
  \item{subset}{The subset that the button should toggle.}
  \item{label}{The button label.}
}
\details{
\code{subsetSlider} and \code{clipplaneSlider} generate an HTML5 slider 
control with a text label.  To display no text, set the labels to blanks
in the \code{...} argument.

\code{subsetSetter} is a low-level function to produce the Javascript
code used by \code{subsetSlider}.  This code will not touch objects in the
subscene if they
are not in \code{fullset}.  \code{fullset} defaults to the union of 
all the object ids mentioned in \code{subsets}, so by default if an id is 
not mentioned in one of the subsets, it will not be controlled by the slider.

\code{toggleButton} generates a button that toggles the presence
of objects within a subscene.  If the first entry in \code{subset}
is in the subscene, all are deleted, otherwise all are added. 

\code{clipplaneSlider}  allows a clipping plane to be moved to a sequence
of positions.  Any non-\code{NULL} entries among \code{a, b, c, d} should be
vectors; the slider will set those parameters of the selected clipping
plane to corresponding values as the slider is moved.
}
\value{
\code{subsetSetter} returns a length-one character vector
of class \code{"propertySetter"}.  

The other functions 
use \code{\link{cat}} to write their output and invisibly return the 
\code{id} of the control that was generated.
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link{writeWebGL}}. See \code{\link{propertySlider}} and \code{\link{propertySetter}}
for lower level, more flexible functions.
}
\examples{
subsets <- list(1:3, 1:4, 1:5)
subsetSlider(subsets = subsets)
toggleButton(1:3)
clipplaneSlider(d = seq(0, 1, len=20), clipplaneid = 123)
}
