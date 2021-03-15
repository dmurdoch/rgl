\name{thigmophobe3d}
\alias{thigmophobe3d}
\title{
Find the direction away from the closest point in a 3d projection.
}
\description{
Jim Lemon's \code{\link[plotrix]{thigmophobe}} function in the 
\code{\link[plotrix:plotrix-package]{plotrix}} package
computes good directions for labels in a 2D plot.  This function
does the same for a particular projection in a 3D plot by
projecting down to 2D and calling his function.
}
\usage{
thigmophobe3d(x, y = NULL, z = NULL, 
              P = par3d("projMatrix"), 
              M = par3d("modelMatrix"),
              windowRect = par3d("windowRect"))
}
\arguments{
  \item{x, y, z}{point coordinates.  Any reasonable way of defining
  the coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}} for details.
}
  \item{P, M, windowRect}{
The projection and modelview matrices, and the size and position of 
the display in pixels.
}
}
\details{
Since \code{thigmophobe3d} projects using fixed \code{P} and \code{M},
it will not necessarily choose good directions if the user rotates
the display or makes any other change to the projection.}

\note{
The example
below shows how to update the directions during an animation; 
I find that the moving labels are distracting, and prefer to live with 
fixed ones.
}
\value{
A vector of values from 1 to 4 to be used as the \code{pos} argument
in \code{\link{text3d}}.
}
\references{
\CRANpkg{plotrix}
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{text3d}}
}
\examples{
if (requireNamespace("plotrix", quietly = TRUE)) {
  # Simulate some data
  xyz <- matrix(rnorm(30), ncol = 3)
  
  # Plot the data first, to establish the projection
  plot3d(xyz)
  
  # Now thigmophobe3d can choose directions
  textid <- text3d(xyz, texts = 1:10, pos = thigmophobe3d(xyz))
  
  # Update the label positions during an animation
  if (interactive() && !rgl.useNULL()) {
    spin <- spin3d(rpm = 5)
    f <- function(time) {
      par3d(skipRedraw = TRUE)
      on.exit(par3d(skipRedraw = FALSE))
      pop3d(id = textid)
      # Need to rotate before thigmophobe3d is called
      result <- spin(time)
      par3d(userMatrix = result$userMatrix)
      textid <<- text3d(xyz, texts = 1:10, pos = thigmophobe3d(xyz))
      result
    }
    play3d(f, duration = 5)
  } else
    textid   # just print the static display
}
}
