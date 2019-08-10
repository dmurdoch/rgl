\name{as.mesh3d.ashape3d}
\alias{as.mesh3d.ashape3d}
\title{
Convert alpha-shape surface of a cloud of points to
mesh3d object.
}
\description{
The \code{\link[alphashape3d:ashape3d]{alphashape3d::ashape3d}}
function computes the
3D \eqn{\alpha}-shape of a cloud of points. This is an approximation
to the visual outline of the cloud.  It may include isolated
points, line segments, and triangular faces:  this function
converts the triangular faces to an \pkg{rgl} \code{\link{tmesh3d}} object.
}
\usage{
\method{as.mesh3d}{ashape3d}(x, 
                   alpha = x$alpha[1], 
                   tri_to_keep = 2L,
                   col = "gray", 
                   smooth = FALSE, normals = NULL,
                   texcoords = NULL, ...)
}
\arguments{
  \item{x}{
An object of class \code{"ashape3d"}.
}
  \item{alpha}{
Which \code{alpha} value stored in \code{x} should be converted?
}
  \item{tri_to_keep}{
Which triangles to keep.  Expert use only:  see \code{triang}
entry in \bold{Value} section of \link[alphashape3d]{ashape3d}
for details.
}
  \item{col}{
The surface colour.
}
  \item{smooth}{
Whether to attempt to add normals to make the surface
look smooth.  See the Details below.
}
  \item{normals, texcoords}{
Normals and texture coordinates at each vertex can be specified.
}
  \item{\dots}{
Additional arguments to pass to use as \code{\link{material3d}} properties on the resulting mesh.
}
}
\details{
Edelsbrunner and Mucke's (1994) \eqn{\alpha}-shape algorithm is 
intended to compute a surface of a general cloud of points.
Unlike the convex hull, the cloud may have voids, isolated points, and other oddities.  This function is designed to 
work in the case where the surface is made up of 
simple polygons.

If \code{smooth = TRUE}, this method attempts to orient all
of the triangles in the surface consistently and add normals
at each vertex by averaging the triangle normals.  
However, for some point clouds, the \eqn{\alpha}-shape will contain 
sheets of polygons with a few solid polyhedra embedded.
This does not allow a consistent definition of "inside"
and outside.  If this is detected, a warning is issued
and the resulting mesh will likely contain boundaries
where the assumed orientation of triangles changes, resulting
in ugly dark lines through the shape.  Larger values
of \code{alpha} in the call to \code{\link[alphashape3d:ashape3d]{alphashape3d::ashape3d}} may help.

Methods for \code{\link{plot3d}} and \code{\link{persp3d}}
are also defined:  they call the \code{\link{as.mesh3d}} method and then plot the result.  
}
\value{
A \code{"mesh3d"} object, suitable for plotting.
}
\references{
Edelsbrunner, H., Mucke, E. P. (1994). Three-Dimensional Alpha Shapes. ACM Transactions on Graphics, 13(1), pp.43-72.

Lafarge, T. and Pateiro-Lopez, B. (2017).
  alphashape3d: Implementation of the 3D Alpha-Shape
  for the Reconstruction of 3D Sets from a Point Cloud.
  R package version 1.3.
}
\author{
Duncan Murdoch
}

\examples{
if (requireNamespace("alphashape3d", quietly = TRUE)) {
  set.seed(123)
  xyz <- rbind(cbind(runif(1000), runif(1000), runif(1000)),
               cbind(runif(125, 1, 1.5), 
                     runif(125, 0.25, 0.75), 
                     runif(125, 0.25, 0.75)))
  ash <- suppressMessages(alphashape3d::ashape3d(xyz, alpha = 0.2))
  m <- as.mesh3d(ash, smooth = TRUE)
  open3d()
  mfrow3d(1, 2, sharedMouse = TRUE)
  plot3d(xyz, size = 1)
  plot3d(m, col = "red", alpha = 0.5)
  points3d(xyz, size = 1)
}
}