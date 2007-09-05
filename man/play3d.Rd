\name{play3d}
\alias{play3d}
\title{ Play animation of rgl scene }
\description{
\code{play3d} calls a function repeatedly, passing it the elapsed
time in seconds, and using the result of the function to
reset the viewpoint.
}
\usage{
play3d(f, duration = Inf, dev = rgl.cur(), ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{f}{ A function returning a list that may be passed to \code{\link{par3d}} }
  \item{duration}{ The duration of the animation }
  \item{dev}{ Which rgl device to select }
  \item{\dots}{ Additional parameters to pass to the function. }
}
\details{
The function will be called in a loop with the first argument being the time in
seconds since the start (where the start is measured after all 
arguments have been evaluated).  

It is likely to place a high load
on the CPU; if this is a problem, calls to \code{\link{Sys.sleep}}
should be made within the function to release time to other processes.
}
\value{
This function is called for the side effect of its repeated calls to \code{f}.
It returns \code{NULL} invisibly.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{par3dinterp}} returns a function suitable to use as \code{f}. }
\examples{
open3d()
plot3d( cube3d(col="green") )
M <- par3d("userMatrix")
play3d( par3dinterp( userMatrix=list(M,
                                     rotate3d(M, pi/2, 1, 0, 0),
                                     rotate3d(M, pi/2, 0, 1, 0) ) ), 
        duration=4 )
}
\keyword{ dplot }
