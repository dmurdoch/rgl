\name{spin3d}
\alias{spin3d}
\title{ Create a function to spin a scene at a fixed rate }
\description{
This creates a function to use with \code{\link{play3d}} to
spin an rgl scene at a fixed rate.
}
\usage{
spin3d(axis = c(0, 0, 1), rpm = 5)
}
\arguments{
  \item{axis}{ The desired axis of rotation }
  \item{rpm}{ The rotation speed in rotations per minute }
}
\value{
A function with header \code{function(time)}.  This function
calculates and returns a list containing \code{userMatrix} updated by
spinning it for \code{time} seconds at \code{rpm} revolutions per
minute about the specified \code{axis}.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{play3d}} to play the animation }
\examples{
open3d()
plot3d(oh3d(col="lightblue", alpha=0.5))
play3d(spin3d(axis=c(1,0,0), rpm=20), duration=3)
}
\keyword{ dplot }
