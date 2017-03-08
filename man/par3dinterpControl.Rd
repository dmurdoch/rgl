\name{par3dinterpControl}
\alias{par3dinterpControl}
\title{
Control rgl widget like par3dinterp().
}
\description{
This control works with \code{\link{playwidget}} to 
change settings in a WebGL display in the same way
as \code{\link{par3dinterp}} does within R.
}
\usage{
par3dinterpControl(fn, from, to, steps, subscene = NULL, omitConstant = TRUE, ...)
}
\arguments{
  \item{fn}{A function returned from \code{\link{par3dinterp}}.}
  \item{from, to, steps}{Values where \code{fn} should be evaluated.}
  \item{subscene}{Which subscene's properties should be modified?}
  \item{omitConstant}{If \code{TRUE}, do not set values that are
  constant across the range.}
  \item{...}{Additional parameters which will be passed
  to \code{\link{propertyControl}}.}
}
\details{
\code{par3dinterpSetter} sets parameters corresponding to values produced by the result of
\code{par3dinterp}.  
}
\value{
Returns controller data in a list of class "rglControl".
}
\author{
Duncan Murdoch
}
\examples{
example(plot3d)
M <- r3dDefaults$userMatrix
fn <- par3dinterp(times = (0:2)*0.75, userMatrix = list(M,
                                      rotate3d(M, pi/2, 1, 0, 0),
                                      rotate3d(M, pi/2, 0, 1, 0)),
                                      scale = c(0.5, 1, 2))
control <- par3dinterpControl(fn, 0, 3, steps = 15)
control      
if (interactive()) 
  rglwidget(width = 500, height = 250) \%>\%
  playwidget(control,
       step = 0.01, loop = TRUE, rate = 0.5)
}
