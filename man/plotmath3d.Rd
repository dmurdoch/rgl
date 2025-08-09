\name{plotmath3d}
\alias{plotmath3d}
\alias{latex3d}
\title{
Draw text using base graphics math plotting or LaTeX
}
\description{
To plot mathematical text, \code{plotmath3d} uses base graphics
functions to plot it to a \file{.png} file, then uses that
file as a texture in a sprite.  \code{latex3d} uses the
\pkg{xdvir} package to render LaTeX code, then uses
the same approach to display it in \pkg{rgl}.
}
\usage{
plotmath3d(x, y = NULL, z = NULL, text, cex = par("cex"),
           adj = 0.5, pos = NULL, offset = 0.5,
           fixedSize = TRUE, startsize = 480, initCex = 5, 
           margin = "", floating = FALSE, tag = "", ...)
latex3d(x, y = NULL, z = NULL, text, cex = par("cex"), 
           adj = 0.5, pos = NULL, offset = 0.5,
           fixedSize = TRUE, startsize = 480, initCex = 5, 
           margin = "", floating = FALSE, tag = "", ...)
}
\arguments{
  \item{x, y, z}{Coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}  
  \item{text}{
A character vector or (in \code{plotmath3d}) expression.  See
\code{\link[grDevices]{plotmath}} for how expressions are
interpreted in \code{plotmath3d}.  In \code{latex3d} each
text entry should be a LaTeX fragment.
}
  \item{cex}{
Character size expansion.
}
  \item{adj}{ One value specifying the horizontal adjustment, or two, 
              specifying horizontal and vertical adjustment respectively, or three, for depth as well. }
  \item{pos, offset}{ Alternate way to specify \code{adj}; see \code{\link{text3d}}}
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
  \item{margin, floating, tag}{
\code{\link{material3d}} properties for the sprites.
  }
  \item{\dots}{
For \code{plotmath3d}, additional arguments to pass to  
\code{\link[graphics]{text}} when drawing the text.  For
\code{latex3d}, additional arguments to pass to 
\code{xdvir::\link[xdvir]{latexGrob}}.
}
}
\note{
The \code{\link{text3d}} function passes calls to
\code{plotmath3d} if its \code{usePlotmath} argument is 
\code{TRUE}.
This is the default value if its
\code{texts} argument looks like an expression.

The \code{latex3d} function produces nicer looking results
than \code{plotmath3d}, but it is much slower, especially 
on the first run.
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

if (requireNamespace("xdvir")) {

  xdvir::TeXstatus()
  
  options(tinytex.verbose = TRUE)
  
  # Do the same plot using latex3d()
  
  open3d()
  latex3d(4, 4, 4, "resizeable text", fixedSize = FALSE, verbose = TRUE)
  latex3d(1:3, 1:3, 1:3, c("$x_1 = 1$", "$x_2 = 2$", "$x_3 = 3$"))

}
}