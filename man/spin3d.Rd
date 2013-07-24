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
A function with header \code{function(time, base=M)}, where \code{M}
is the result of \code{par3d("userMatrix")} at the time the function
is created.  This function
calculates and returns a list containing \code{userMatrix} updated by
spinning the base matrix for \code{time} seconds at \code{rpm} revolutions per
minute about the specified \code{axis}.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{play3d}} to play the animation }
\examples{
# Spin one object
open3d()
plot3d(oh3d(col="lightblue", alpha=0.5))
if (!rgl.useNULL())
  play3d(spin3d(axis=c(1,0,0), rpm=20), duration=3)

# Show spinning sprites, and rotate the whole view
open3d()
spriteid <- NULL

spin1 <- spin3d(rpm=3 ) # the scene spinner
spin2 <- spin3d(rpm=6 ) # the sprite spinner

f <- function(time) {
    par3d(skipRedraw = TRUE) # stops intermediate redraws
    on.exit(par3d(skipRedraw=FALSE)) # redraw at the end

    rgl.pop(id=spriteid) # delete the old sprite
    cubeid <- shade3d(cube3d(), col="red")
    spriteid <<- sprites3d(0:1, 0:1, 0:1, shape=cubeid,
                   userMatrix=spin2(time, 
                     base=spin1(time)$userMatrix)$userMatrix)
    spin1(time)
}
if (!rgl.useNULL())
  play3d(f, duration=3)
}
\keyword{ dplot }
