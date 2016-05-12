\name{pch3d}
\alias{pch3d}
\title{
Plot symbols similar to base graphics.
}
\description{
This function plots symbols similarly to 
what the base graphics function \code{\link{points}} does when \code{pch} is specified.
}
\usage{
pch3d(x, y = NULL, z = NULL, pch = 1, bg = material3d("color")[1], cex = 1, radius, ...)
}
\arguments{
  \item{x, y, z}{
The locations at which to plot in a form
suitable for use in \code{\link{xyz.coords}}.
}
  \item{pch}{
A vector of integers or single characters
describing the symbols to plot.
}
  \item{bg}{
The fill color to use for \code{pch} from 21 
to 25.
}
  \item{cex}{
A relative size of the symbol to plot.
}
  \item{radius}{
An absolute size of the symbol to plot 
in user coordinates.
}
  \item{\dots}{
Other material properties.
}
}
\details{
The list of symbols encoded by numerical
\code{pch} values is given in the \code{\link{points}} help page.  
}
\note{
This function is not a perfect match to how the \code{\link{points}} function works due
to limitations in \pkg{rgl} and OpenGL.  In
particular:

Symbols with numbers from 1 to 25 are drawn
as 3D sprites (see \code{\link{sprites3d}}),
so they will resize as the window is zoomed.
Letters and numbers from 32 to 255 (which are
mapped to letters) are drawn using \code{\link{text3d}}, 
so they maintain a fixed size.

A calculation somewhat like the one in \code{\link{plot3d}} that sets the size
of spheres is used to choose the size of
sprites based on \code{cex} and the 
current scaling.  This will likely need manual
tweaking.  Use the \code{radius} argument
for a fixed size.

No special handling is done for the case of 
\code{pch = "."}.  Use \code{points3d} for 
small dots.
}
\value{
A vector of object id values is returned invisibly.  Separate objects will be drawn
for each different \code{pch} value from 
0 to 25, and another holding all the character
symbols.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{points3d}}, \code{\link{text3d}},
\code{\link{plot3d}}, \code{\link{points}}.
}
\examples{
open3d()
i <- 0:25; x <- i \%\% 5; y <- rep(0, 26); z <- i \%/\% 5
pch3d(x, y, z, pch = i, bg = "green")
text3d(x, y, z + 0.3, i)
pch3d(x + 5, y, z, pch = i+65)
text3d(x + 5, y, z + 0.3, i+65)
}
