\name{hook_rgl}
\alias{hook_rgl}
\alias{hook_webgl}
\title{
Hook functions to use with \pkg{knitr}
}
\description{
These functions allow \pkg{rgl} graphics to be embedded in \pkg{knitr}
documents, either as bitmaps (\code{hook_rgl} with format \code{"png"}),
fixed vector graphics (\code{hook_rgl} with format \code{"eps"} or
\code{"postscript"}), or interactive WebGL graphics (\code{hook_webgl}).
}
\usage{
hook_rgl(before, options, envir)
hook_webgl(before, options, envir)
}
\arguments{
  \item{before, options, envir}{
Standard \pkg{knitr} hook function arguments.
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
