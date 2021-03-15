\name{webGLcontrols}
\alias{subsetSlider}
\alias{subsetSetter}
\alias{clipplaneSlider}
\alias{toggleButton}
\title{
Obsolete functions to write HTML/Javascript code to control a WebGL display
}
\description{
These functions write out HTML code to control WebGL displays on the same page.  They are deprecated; most documentation has
now been removed.
}
\usage{
subsetSlider(subsets, labels = names(subsets), 
             fullset = Reduce(union, subsets),
             subscenes = currentSubscene3d(), prefixes = "",
             accumulate = FALSE, ...)
             
subsetSetter(subsets, subscenes = currentSubscene3d(), prefixes = "", 
			 fullset = Reduce(union, subsets),
                         accumulate = FALSE)
             
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
  \item{accumulate}{If \code{TRUE}, the subsets will accumulate (by union)
  as the value increases.}
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
\code{\link{playwidget}} and \code{\link{toggleWidget}}
for a newer, preferred method of inserting controls
into a scene.
}
