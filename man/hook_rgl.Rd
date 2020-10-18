\name{setupKnitr}
\alias{hook_rgl}
\alias{hook_webgl}
\alias{hook_rglchunk}
\alias{setupKnitr}
\title{
Displaying \pkg{rgl} scenes in \pkg{knitr} documents.
}
\description{
These functions allow \pkg{rgl} graphics to be embedded in \pkg{knitr}
documents.

The simplest method is to run \code{setupKnitr(autoprint = TRUE)}
early in the document.  That way \pkg{rgl} commands act a lot
like base graphics commands:  plots will be automatically inserted
where appropriate, according to the \code{fig.keep} chunk option.
By default (\code{fig.keep = "high"}), only high-level plots
are kept, after low-level changes have been merged into them.
See the \pkg{knitr} documentation 
\url{https://yihui.org/knitr/options/#plots} for more details.  To suppress auto-printing, the \pkg{rgl} calls
can be wrapped in \code{\link{invisible}()}.  
Similarly to \pkg{grid} graphics (used by \pkg{lattice}
and \pkg{ggplot2}), automatic inclusion requires the object
to be printed:  only the last statement in a code block
in braces is automatically printed.  Unlike those 
packages, auto-printing is the only way to get this to
work:  calling \code{\link{print}} explicitly doesn't
work.

Other functions allow embedding either as bitmaps (\code{hook_rgl} with format \code{"png"}),
fixed vector graphics (\code{hook_rgl} with format \code{"eps"}, \code{"pdf"} or
\code{"postscript"}), or interactive WebGL graphics (\code{hook_webgl}).  \code{hook_rglchunk} is not normally invoked by the 
user; it is the hook that supports automatic creation and 
deletion of rgl scenes.
}

\note{The \code{setupKnitr(autoprint = TRUE)} method assumes
\emph{all} printing of \pkg{rgl} objects happens through 
auto-printing of objects produced by the \code{\link{lowlevel}}
or \code{\link{highlevel}} functions.  All \pkg{rgl} functions that
produce graphics do this, but functions in other packages that
call them may not return values appropriately.

If you have multiple calls to \code{setupKnitr()}, all
should have the same arguments.  If any differ, a 
warning will be issued, and the first set of arguments
will be used.

Mixing explicit calls
to \code{\link{rglwidget}} with auto-printing is likely to lead to failure of some
scenes to display.  To avoid this, set \code{options(rgl.printRglwidget = FALSE)} before using such explicit calls.  Similarly,
use that option before calling the \code{\link{example}} function
in a code chunk if the example prints \pkg{rgl} objects.
}

\usage{
setupKnitr(autoprint = FALSE,
           rgl.newwindow = autoprint,
           rgl.closewindows = autoprint,
           reset = FALSE)
hook_rgl(before, options, envir)
hook_webgl(before, options, envir)
hook_rglchunk(before, options, envir)
}
\arguments{
  \item{autoprint}{If true, \code{rgl} commands
  automatically plot (with low level plots suppressed by
  the default value of the \code{fig.keep} chunk option.)}
  \item{rgl.newwindow, rgl.closewindows}{Default values
  for the \pkg{knitr} chunk options.}
  \item{reset}{Reset the \pkg{knitr} hooks before setting them.}
  \item{before, options, envir}{
Standard \pkg{knitr} hook function arguments.
}
}
\details{
The \code{setupKnitr()} function needs to be called once
at the start of the document to install the \pkg{knitr} hooks.
If it is called twice in the same session, it will issue a 
warning, unless \code{reset = TRUE}.

The following chunk options are supported:
\itemize{
  \item \code{rgl.newwindow}:  Whether to open a new window for the chunk.  Default is set by `setupKnitr` argument.
  
  \item \code{rgl.closewindows}: Whether
to close windows at the end of the chunk.  Default is set by `setupKnitr` argument.

  \item \code{rgl.margin} (default 100):  number of pixels by which to indent the
  WebGL window.
  
  \item \code{snapshot}: Logical value:  when autoprinting
  in HTML, should a snapshot be used instead of the dynamic 
  WebGL display?  Corresponds to \code{rglwidget(snapshot = TRUE, webgl = FALSE)}.  Ignored in LaTeX, where a snapshot
  will always be produced (unless \code{fig.keep} specifies
  no figure at all).

  \item \code{dpi}, \code{fig.retina}, \code{fig.width}, \code{fig.height}:  standard \pkg{knitr} chunk
  options used to set the size of the output.
  
  \item \code{fig.keep}, \code{fig.hold}, \code{fig.beforecode}:  standard \pkg{knitr} chunk options used to control the
display of plots.
  
  \item \code{dev}:  used by \code{hook_rgl} to set 
  the output format.  May be \code{"eps"}, \code{"postscript"},
  \code{"pdf"} or \code{"png"} (default:  \code{"png"}).
  
  \item \code{rgl.keepopen}:  no longer used.  Ignored
  with a warning.

}
}
\value{
A string to be embedded into the output, or \code{NULL} if called
when no output is available.
}
\author{
The \code{hook*} functions are originally by Yihui Xie in the \pkg{knitr} package; and have been modified by
Duncan Murdoch.  Some parts of the \code{setupKnitr} function
duplicate source code from \pkg{knitr}.
}
\keyword{ utilities }
