\name{tkpar3dsave}
\alias{tkpar3dsave}
\alias{par3dsave}
\title{ Modal dialog for saving par3d settings }
\description{
This function opens a TCL/TK modal dialog to allow particular views of an \code{rgl} scene
to be saved.
}
\usage{
tkpar3dsave(params = c("userMatrix", "scale", "zoom", "FOV"),
          times = FALSE, dev = cur3d(), ...)
}
\arguments{
  \item{params}{ Which parameters to save }
  \item{times}{ Should times be saved as well? }
  \item{dev}{ Which \code{rgl} device to work with }
  \item{...}{ Additional parameters to pass to \code{\link[tcltk:TkWidgets]{tktoplevel}}}
}
\details{
This opens a TCL/TK modal dialog box with \code{Record} and \code{Quit} buttons.  Each time
\code{Record} is clicked, a snapshot is taken of current \code{\link[rgl]{par3d}} settings.  When
\code{Quit} is clicked, the dialog closes and the values are returned in a list.

If \code{times == TRUE}, then the times at which the views are recorded will also be saved, so that
the \code{\link[rgl]{play3d}} function will play back with the same timing.
}
\value{
A list of the requested components.  Each one will consist of a list of values that were
current when the \code{Record} button was clicked.  These are suitable to be passed directly
to the \code{\link[rgl]{par3dinterp}} function.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{par3d}}, \code{\link{par3dinterp}}}
\examples{
if (interactive() && !in_pkgdown_example()) {

  # Record a series of positions, and then play them back immediately
  # at evenly spaced times, in an oscillating loop
  example(plot3d)
  play3d( par3dinterp( tkpar3dsave() ) )

  # As above, but preserve the click timings

  # play3d( par3dinterp( tkpar3dsave(times=TRUE) ) )
}
}
