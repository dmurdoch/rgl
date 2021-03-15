\name{as.triangles3d}
\alias{as.triangles3d}
\alias{as.triangles3d.rglId}
\title{
Convert an object to triangles
}
\description{
This generic and its methods extract or creates a matrix of coordinates
of triangles from an object, suitable for passing to \code{\link{triangles3d}}.
}
\usage{
as.triangles3d(obj, ...)
\method{as.triangles3d}{rglId}(obj,
               attribute = c("vertices", "normals", "texcoords", "colors"),
               subscene = NA,
               ...)
}
\arguments{
  \item{obj}{
The object to convert.
}
  \item{attribute}{Which attribute of an RGL object to extract?}
  \item{subscene}{Which subscene is this object in?}
  \item{\dots}{
Additional arguments used by the methods.
}
}
\details{
The method for \code{"rglId"} objects can extract several different
attributes, organizing them as it would organize the vertices for
the triangles.
}
\value{
An \code{n x 3} matrix containing the vertices of triangles making
up the object.  Each successive 3 rows of the matrix corresponds to
a triangle.

If the attribute doesn't exist, \code{NULL} will be returned.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{as.mesh3d}} to also capture material properties.
}
\examples{
open3d()
x <- surface3d(x = 1:10, y = 1:10, z = rnorm(100), col = "red")
tri <- as.triangles3d(x)
open3d()
triangles3d(tri, col = "blue")
}
