\name{spheres3d}
\alias{rgl.spheres}
\alias{spheres3d}
\title{add sphere set shape}
\description{
  Adds a sphere set shape node to the scene
}
\usage{
spheres3d(x, y = NULL, z = NULL, radius = 1, ...)
rgl.spheres(x, y = NULL, z = NULL, radius, ...)
}
\arguments{
  \item{x, y, z}{Numeric vector of point coordinates corresponding to
   the center of each sphere.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{radius}{Vector or single value defining the sphere radius/radii}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}
}
\details{
If a non-isometric aspect ratio is chosen, these functions will still draw
objects that appear to the viewer to be spheres.  Use \code{\link{ellipse3d}} 
to draw shapes that are spherical in the data scale.

When the scale is not isometric, the radius is measured in an average scale.
In this case the bounding box calculation is iterative, since rescaling the
plot changes the shape of the spheres in user-coordinate, which changes
the bounding box.  Versions of \code{rgl} prior to 0.92.802 did not do 
this iterative adjustment.

If any coordinate or radius is \code{NA}, the sphere is not plotted.
} 
\value{
  A shape ID of the spheres object is returned.
}
\examples{
open3d()
spheres3d(rnorm(10), rnorm(10), rnorm(10), radius=runif(10), color=rainbow(10))
}
\seealso{
  \code{\link{rgl.material}}, \code{\link{aspect3d}} for setting non-isometric scales
}
\keyword{dynamic}
