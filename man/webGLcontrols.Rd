\name{webGLcontrols}
\alias{propertySlider}
\alias{subsetSlider}
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
             prefix = "", subscene = currentSubscene3d(), 
             init = 1, 
             id = paste0(basename(tempfile("input"))), name = id,
             fullset = Reduce(union, subsets))
propertySlider(values, property, entries, 
	     labels = seq_len(NROW(values)), 
	     prefix = "", objid, init = 1,
	     id = paste0(basename(tempfile("input"))), name = id) 
clipplaneSlider(a=NULL, b=NULL, c=NULL, d=NULL, labels = signif(values[,1],3), 
             clipplaneid, plane = 1, ...)
toggleButton(subset, label = deparse(substitute(subset)), 
	     prefix = "", subscene = currentSubscene3d(), 
	     id = paste0(basename(tempfile("input"))), name = id)
}
\arguments{
  \item{subsets}{A list of vectors of object identifiers; the slider
  will choose among them.}
  \item{labels}{Labels to display corresponding to each subset.  If \code{NULL},
  numeric labels will be shown.}
  \item{prefix}{The prefix of the WebGL scene to be controlled.}
  \item{subscene}{The subscene to be controlled.}
  \item{init}{The index of the initial subset to show.}
  \item{id}{The \code{id} of the input control that will be generated.}
  \item{name}{The name of the input control that will be generated.}
  \item{fullset}{Objects in the subscene which are not in \code{fullset}
  will not be touched.}
  \item{values}{An array of values; rows correspond to slider positions.}
  \item{property}{A character variable giving the property to set.}
  \item{entries}{A numeric vector of indices into the property to change.}
  \item{objid}{The identifier of the object to modify.}
  \item{a,b,c,d}{The parameter values to change.  Leave as \code{NULL}
  to hold the parameter constant.}
  \item{clipplaneid, plane}{The identifier of the particular clipplane
  to modify.}
  \item{...}{Other parameters to pass to \code{propertySlider}.}
  \item{subset}{The subset that the button should toggle.}
  \item{label}{The button label.}
}
\details{
\code{subsetSlider} and \code{clipplaneSlider} generate an HTML5 slider 
control with a text label.  To display no text, set the labels to blanks.

\code{subsetSlider} will not touch objects in the subscene if they
are not in \code{fullset}.  \code{fullset} defaults to the union of 
all the object ids mentioned in \code{subsets}, so by default if an id is 
not mentioned, it will not be deleted.  

\code{toggleButton} generates a button that toggles the presence
of objects within a subscene.  If the first entry in \code{subset}
is in the subscene, all are deleted, otherwise all are added. 

\code{clipplaneSlider}  allows a clipping plane to be moved to a sequence
of positions.  Any non-\code{NULL} entries among \code{a, b, c, d} should be
vectors; the slider will set those parameters of the selected clipping
plane to corresponding values as the slider is moved.

\code{propertySlider} is a low-level general purpose function for modifying
properties of objects in the scene.  It is mainly for internal use.
}
\value{
The \code{id} of the control that was generated.
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link{writeWebGL}}
}
\examples{
subsets <- list(1:3, 1:4, 1:5)
subsetSlider(subsets)
toggleButton(1:3)
clipplaneSlider(d = seq(0, 1, len=20), clipplaneid=123)
}