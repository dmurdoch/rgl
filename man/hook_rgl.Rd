\name{hook_rgl}
\alias{hook_rgl}
\alias{hook_webgl}
\alias{setupKnitr}
\title{
Hook functions to use with \pkg{knitr}
}
\description{
These functions allow \pkg{rgl} graphics to be embedded in \pkg{knitr}
documents, either as bitmaps (\code{hook_rgl} with format \code{"png"}),
fixed vector graphics (\code{hook_rgl} with format \code{"eps"}, \code{"pdf"} or
\code{"postscript"}), or interactive WebGL graphics (\code{hook_webgl}).
}
\usage{
setupKnitr()
hook_rgl(before, options, envir)
hook_webgl(before, options, envir)
}
\arguments{
  \item{before, options, envir}{
Standard \pkg{knitr} hook function arguments.
}
}
\details{
The \code{setupKnitr()} function needs to be called once
at the start of the document to install the \pkg{knitr} hooks
and to initialize \code{hook_webgl}.

The following chunk options are supported:
\itemize{
  \item \code{rgl.keepopen}:  no longer used.  Ignored
  with a warning.
  
  \item \code{rgl.newwindow} (default \code{FALSE}):  Whether to open a new window for the display.
  
  \item \code{rgl.margin} (default 100):  number of pixels by which to indent the
  WebGL window.
  
  \item \code{dpi}, \code{fig.retina}, \code{fig.width}, \code{fig.height}:  standard \pkg{knitr} chunk
  options used to set the size of the output.
  
  \item \code{dev}:  used by \code{hook_rgl} to set 
  the output format.  May be \code{"eps"}, \code{"postscript"},
  \code{"pdf"} or \code{"png"} (default:  \code{"png"}).
}
}
\value{
A string to be embedded into the output, or \code{NULL} if called
when no output is available.
}
\author{
Originally by Yihui Xie in the \pkg{knitr} package; modified by
Duncan Murdoch.
}
\seealso{
\code{\link{rgl.Sweave}} embeds fixed images in Sweave documents.
}
\keyword{ utilities }
