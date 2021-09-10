\name{bgplot3d}
\alias{bgplot3d}
\alias{legend3d}
\title{Use base graphics for RGL background}
\description{
Add a 2D plot or a legend in the background of an RGL window.
}
\usage{
bgplot3d(expression, bg.color = getr3dDefaults("bg", "color"),
         magnify = 1, manual_mip = FALSE, 
         texmipmap = manual_mip, texminfilter = "linear",
         envir = parent.frame(), ...)
legend3d(...)
}
\arguments{
  \item{expression}{
Any plotting commands to produce a plot.
}
  \item{bg.color}{
The color to use for the background.
}
  \item{magnify}{
Multiplicative factor to apply to size of window when producing background 
plot.
  }
  \item{manual_mip}{
Whether to evaluate the expression multiple times for
different levels of display.  See Details below.
  }
  \item{texmipmap, texminfilter}{
Material properties to use in the texture.  If 
\code{texmipmap} is \code{TRUE}, the \code{texminfilter}
default changes to \code{"linear.mipmap.nearest"}.
  }
  \item{envir}{The parent of the environment in which
  to evaluate the expression.}
  \item{...}{
For \code{legend3d}, arguments to pass to \code{bgplot3d}
or \code{\link{legend}}; for \code{bgplot3d}, 
arguments to pass to \code{\link{bg3d}}.
}
}
\details{
The \code{bgplot3d} function opens a \code{\link{png}} device and executes \code{expression},
producing a plot there.  This plot is then used as a bitmap background for the current
RGL subscene.

If \code{manual_mip} is \code{TRUE}, this is repeated as the
window is shrunk by dividing its width and height by 2
and a new smaller image is saved.  This continues until
an error occurs or a 1x1 image is produced.  The sequence of images
will be used as a \dQuote{mipmap}, in which the display will
be chosen depending on the final display size. See the 
example below for a use of this with \code{legend3d}.

The \code{expression} will be executed in an environment
containing variables \code{bgplot3d_width} and
\code{bgplot3d_height}, with parent environment
\code{envir} (by default the caller's frame).

The \code{legend3d} function draws a standard 2D legend to the background of the current
subscene by calling \code{bgplot3d} to open a device, and setting up a plot region there 
to fill the whole display.
}
\value{
The \code{bgplot3d} function invisibly returns the ID of the background object that was created,
with attribute \code{"value"} holding the value returned when the \code{expression} was
evaluated if \code{manual_mip = FALSE}, or a list of the
values if \code{manual_mip = TRUE}.

The \code{legend3d} function does similarly.  The \code{"value"} attribute is the result
of the call to \code{\link{legend}}.   The scaling of the coordinates runs from 0 to 1 
in X and Y.
}
\author{
Duncan Murdoch
}
\note{
Because the background plots are drawn as bitmaps, they do not resize very gracefully, even with \code{manual_mip = TRUE}.
It's best to size your window first, then draw the background at that size.
}


\seealso{
\code{\link{bg3d}} for other background options.
}
\examples{
x <- rnorm(100)
y <- rnorm(100)
z <- rnorm(100)
open3d()
# Needs to be a bigger window than the default
par3d(windowRect = c(100, 100, 612, 612))
parent <- currentSubscene3d()
mfrow3d(2, 2)
plot3d(x, y, z)
next3d(reuse = FALSE)
bgplot3d(plot(y, z))
next3d(reuse = FALSE)
bgplot3d(plot(x, z))
next3d(reuse = FALSE)
legend3d("center", 
         c("2D Points", "3D Points"), 
         pch = c(1, 16), 
         manual_mip = TRUE, magnify = 4)
useSubscene3d(parent)
}
\keyword{ graphics }
