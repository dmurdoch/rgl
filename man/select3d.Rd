\name{select3d}
\alias{select3d}
\alias{rgl.select3d}
\title{ Select a rectangle in an RGL scene }
\description{
  This function allows the user to use the mouse to
  select a region in an RGL scene.  
}
\usage{
select3d()
}
\details{
    
This function selects 3-dimensional regions by allowing the
user to use a mouse to draw a rectangle showing
the projection of the region onto the screen.  It returns
a function which tests points for inclusion in the selected region.

If the scene is later moved or rotated, the selected region will 
remain the same, no longer corresponding to a rectangle on the screen.
  
}
\value{
Returns a function \code{f(x,y,z)} which tests whether each
of the points \code{(x,y,z)} is in the selected region, returning
a logical vector.  This function accepts input in a wide
variety of formats as it uses \code{\link{xyz.coords}} 
to interpret its parameters.
}
\author{ Ming Chen / Duncan Murdoch }
\seealso{ \code{\link{locator}} }
\examples{

# Allow the user to select some points, and then redraw them
# in a different color

if (interactive()) {
 x <- rnorm(1000)
 y <- rnorm(1000)
 z <- rnorm(1000)
 rgl.open()
 points3d(x,y,z,size=2)
 f <- select3d()
 keep <- f(x,y,z)
 rgl.pop()
 points3d(x[keep],y[keep],z[keep],size=2,color='red')
 points3d(x[!keep],y[!keep],z[!keep],size=2)
}
}
\keyword{dynamic}
