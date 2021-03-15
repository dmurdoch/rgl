\name{spheres3d}
\alias{spheres3d}
\title{add sphere set shape}
\description{
  Adds a sphere set shape node to the scene
}
\usage{
spheres3d(x, y = NULL, z = NULL, radius = 1, fastTransparency = TRUE, ...)
}
\arguments{
  \item{x, y, z}{Numeric vector of point coordinates corresponding to
   the center of each sphere.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{radius}{Vector or single value defining the sphere radius/radii}
  \item{fastTransparency}{logical value indicating whether
fast sorting should be used for transparency.  See the Details.}
  \item{ ... }{Material properties. See \code{\link{material3d}} for details.}
}
\details{
If a non-isometric aspect ratio is chosen, these functions will still draw
objects that appear to the viewer to be spheres.  Use \code{\link{ellipse3d}} 
to draw shapes that are spherical in the data scale.

When the scale is not isometric, the radius is measured in an average scale.
In this case the bounding box calculation is iterative, since rescaling the
plot changes the shape of the spheres in user-coordinates, which changes
the bounding box.  Versions of \code{rgl} prior to 0.92.802 did not do 
this iterative adjustment.

If any coordinate or radius is \code{NA}, the sphere is not plotted.

If a texture is used, its bitmap is wrapped around the 
sphere, with the top edge at the maximum y coordinate, 
and the left-right edges joined at the maximum in the
z coordinate, centred in x.

If the \code{alpha} material value of the spheres is less than 
the default \code{1}, they need to be drawn in order from
back to front.  When \code{fastTransparency} is \code{TRUE}, this is approximated by sorting the centers and drawing
complete spheres in that order.  This produces acceptable
results in most cases, but artifacts may be visible, 
especially if the \code{radius} values vary, or they 
intersect other transparent objects.  Setting 
\code{fastTransparency = FALSE} will cause the sorting 
to apply to each of the 512 facets of individual spheres.
This is much slower, but may produce better
output.
} 
\value{
  A shape ID of the spheres object is returned.
}
\examples{
open3d()
spheres3d(rnorm(10), rnorm(10), rnorm(10), 
          radius = runif(10), color = rainbow(10))
}
\seealso{
  \code{\link{material3d}}, \code{\link{aspect3d}} for setting non-isometric scales
}
\keyword{dynamic}
