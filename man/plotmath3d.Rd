\name{plotmath3d}
\alias{plotmath3d}
\title{
Draw text using base graphics math plotting
}
\description{
To plot mathematical text, this function uses base graphics
functions to plot it to a \file{.png} file, then uses that
file as a texture in a sprite.
}
\usage{
plotmath3d(x, y = NULL, z = NULL, text, cex = par("cex"),
           adj = 0.5, pos = NULL, offset = 0.5,
           fixedSize = TRUE, startsize = 480, initCex = 5, ...)
}
\arguments{
  \item{x, y, z}{coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}  
  \item{text}{
A character vector or expression.  See
\code{\link[grDevices]{plotmath}} for how expressions are
interpreted.
}
  \item{cex}{
Character size expansion.
}
  \item{adj}{ one value specifying the horizontal adjustment, or two, 
              specifying horizontal and vertical adjustment respectively, or three, for depth as well. }
  \item{pos, offset}{ alternate way to specify \code{adj}; see \code{\link{text3d}}}
  \item{fixedSize}{
Should the resulting sprite behave like the default
ones, and resize with the scene, or like text, and
stay at a fixed size?
}
  \item{startsize, initCex}{
These parameters are unlikely to be needed by users.
\code{startsize} is an over-estimate of the size (in pixels) of the 
largest expression.  Increase this if large expressions
are cut off.  \code{initCex} is the size of text used
to form the bitmap.  Increase this if letters look too blurry
at the desired size.
}

  \item{\dots}{
Additional arguments to pass to  
\code{\link[graphics]{text}} when drawing the text.
}
}
\note{
The \code{\link{text3d}} function passes calls to this
function if its \code{usePlotmath} argument is \code{TRUE}.
The default value is determined by examining its
\code{texts} argument; if it looks like an expression, 
\code{plotmath3d} is used.
}
\value{
Called for the side effect of displaying the sprites.
The shape ID of the displayed object is returned.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{text3d}}
}
\examples{
open3d()
plotmath3d(1:3, 1:3, 1:3, expression(x[1] == 1, x[2] == 2, x[3] == 3))
# This lets the text resize with the plot
text3d(4, 4, 4, "resizeable text", usePlotmath = TRUE, fixedSize = FALSE)
}