\name{aspect3d}
\alias{aspect3d}
\title{Set the aspect ratios of the current plot}
\description{
This function sets the apparent ratios of the x, y, and z axes
of the current bounding box.
}
\usage{
aspect3d(x, y = NULL, z = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{The ratio for the x axis, or all three ratios, or \code{"iso"} }
  \item{y}{The ratio for the y axis }
  \item{z}{The ratio for the z axis }
}
\details{
If the ratios are all 1, the bounding box will be displayed as a cube approximately filling the display.
Values may be set larger or smaller as desired.  Aspect \code{"iso"} signifies that the
coordinates should all be displayed at the same scale, i.e. the bounding box should not be
rescaled.  (This corresponds to the default display before \code{aspect3d} has been called.)
Partial matches to \code{"iso"} are allowed.

This function works by modifying the \code{userMatrix} to adjust the \code{modelMatrix},
so it must be applied after other functions (e.g. \code{\link{par3d}}, \code{\link{view3d}} or \code{\link{rgl.viewpoint}}) 
that set the \code{userMatrix}.
}
\value{
The previous value of the \code{\link[par3d]{userMatrix}} is returned.
}
\author{Duncan Murdoch}
\seealso{\code{\link{plot3d}}}
\examples{
  x <- rnorm(100)
  y <- rnorm(100)*2
  z <- rnorm(100)*3
  
  open3d()
  plot3d(x, y, z)
  aspect3d(1,1,0.5)
  open3d()
  plot3d(x, y, z)
  aspect3d("iso")
}
\keyword{dynamic}
