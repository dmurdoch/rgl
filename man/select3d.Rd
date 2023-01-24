\name{select3d}
\alias{select3d}
\alias{selectionFunction3d}
\title{ Select a rectangle in an RGL scene }
\description{
  This function allows the user to use the mouse to
  select a region in an RGL scene.  
}
\usage{
select3d(button = c("left", "middle", "right"),
             dev = cur3d(), subscene = currentSubscene3d(dev))
selectionFunction3d(proj, region = proj$region)
}
\arguments{
  \item{ button }{ Which button to use for selection.}
  \item{ dev, subscene}{ The RGL device and subscene to work with }
  \item{proj}{An object returned from \code{\link{rgl.projection}}
  containing details of the current projection.}
  \item{region}{Corners of a rectangular region in the display.}
}

\details{
    
\code{select3d} selects 3-dimensional regions by allowing the
user to use a mouse to draw a rectangle showing
the projection of the region onto the screen.  It returns
a function which tests points for inclusion in the selected region.

\code{selectionFunction3d} constructs such a test function given 
coordinates and current transformation matrices.

If the scene is later moved or rotated, the selected region will 
remain the same, though no longer corresponding to a rectangle on the screen.
  
}
\value{
These return a function \code{f(x, y, z)} which tests whether each
of the points \code{(x, y, z)} is in the selected region, returning
a logical vector.  This function accepts input in a wide
variety of formats as it uses \code{\link[grDevices]{xyz.coords}} 
to interpret its parameters.
}
\author{ Ming Chen / Duncan Murdoch }
\seealso{ \code{\link{selectpoints3d}}, \code{\link{locator}} }
\examples{

# Allow the user to select some points, and then redraw them
# in a different color

if (interactive() && !in_pkgdown_example()) {
 x <- rnorm(1000)
 y <- rnorm(1000)
 z <- rnorm(1000)
 open3d()
 points3d(x, y, z)
 f <- select3d()
 if (!is.null(f)) {
   keep <- f(x, y, z)
   pop3d()
   points3d(x[keep], y[keep], z[keep], color = 'red')
   points3d(x[!keep], y[!keep], z[!keep])
 }
}
}
\keyword{dynamic}
