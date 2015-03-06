\name{webGLcontrols}
\alias{subsetSlider}
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
             id = paste0(basename(tempfile("input"))), name = id)
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
  \item{subset}{The subset that the button should toggle.}
  \item{label}{The button label.}
}
\details{
\code{subsetSlider} generates an HTML5 slider control.  To display
no text, set the labels to blanks.
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
}