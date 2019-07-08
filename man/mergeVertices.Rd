\name{mergeVertices}
\alias{mergeVertices}
\title{
Merge duplicate vertices in mesh object
}
\description{
A mesh object can have the same vertex listed twice.  Each copy is
allowed to have separate normals, texture coordinates, and color.
However, it is more efficient to have just a single copy if those
differences aren't needed.  For automatic smoothing using 
\code{\link{addNormals}}, triangles and quads need to share vertices.
This function merges identical (or similar) vertices to achieve this.
}
\usage{
mergeVertices(mesh, 
              notEqual = NULL, 
              attribute = "vertices", 
              tolerance = sqrt(.Machine$double.eps))
}
\arguments{
  \item{mesh}{
A \code{\link{mesh3d}} object.
}
  \item{notEqual}{
A logical matrix indicating that certain pairs should not be merged
even if they appear identical.
}
  \item{attribute}{
Which attribute(s) should be considered in comparing vertices? 
A vector chosen from \code{c("vertices", "colors", "normals", "texcoords"))}
}
  \item{tolerance}{
When comparing vertices using \code{\link{all.equal}}, this tolerance
will be used to ignore rounding error.
}
}

\value{
A new mesh object.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{as.mesh3d.rglId}}, which often constructs mesh
objects containing a lot of duplication.
}
\examples{
(mesh1 <- cube3d())
id <- shade3d(mesh1, col = rainbow(6), meshColor = "face")
(mesh2 <- as.mesh3d(id))
(mesh3 <- mergeVertices(mesh2))
}