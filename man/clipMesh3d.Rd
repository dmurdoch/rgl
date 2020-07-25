\name{clipMesh3d}
\alias{clipMesh3d}
\title{
Clip mesh to general region
}
\description{
Modifies a mesh3d object so that values of 
a function are bounded.
}
\usage{
clipMesh3d(mesh, fn, bound = 0, greater = TRUE, 
           attribute = "vertices")
}
\arguments{
  \item{mesh}{
A \code{\link{mesh3d}} object.
}
  \item{fn}{
A function used to determine clipping, or a vector of values from such
a function, with one value per vertex in the mesh.
}
  \item{bound}{
The value(s) of \code{fn} on the clipping boundary.
}
  \item{greater}{
Logical; whether to keep \code{fn >= bound} or not.
}
  \item{attribute}{
Which attribute(s) to pass to \code{fn}?  Possible values
are \code{c("vertices", "normals", "texcoords", "index")}.
}
}
\details{
This function transforms a mesh3d object. 

First, all quads are converted to triangles.

Next, each vertex is checked against the condition.  If \code{fn}
is a numeric vector, with one value per vertex, those values will be
used in the test.
If it is a function, it will be passed a matrix, whose columns are 
the specified attribute(s), with one row per vertex.  It should return
a vector of values, one per vertex, to check against the bound.
The \code{"vertices"} and \code{"normals"} values will be converted to
Euclidean coordinates.  \code{"index"} will be an integer from 1
to the number of vertices.  

Modifications to the triangles depend
on how many of the vertices satisfy the condition 
(\code{fn >= bound} or \code{fn <= bound}, depending on \code{greater})
for inclusion.
\itemize{
\item If no vertices in a triangle satisfy the condition, the triangle is omitted.
\item If one vertex satisfies the condition, the other two vertices
in that triangle are shrunk towards it by assuming \code{fn}
is locally linear.
\item If two vertices satisfy the condition, the third vertex
is shrunk along each edge towards each other vertex, forming a
quadrilateral made of two new triangles.
\item If all vertices satisfy the condition, they are included
with no modifications.
}
}
\value{
A new mesh3d object in which all vertices (approximately) satisfy the
clipping condition.  Note that the order of vertices will likely
differ from the original order, and new vertices will be added near
the boundary.
}
\author{
Duncan Murdoch
}
\references{
See \url{https://stackoverflow.com/q/56242470/2554330} for the 
motivating example.
}
\examples{
if (requireNamespace("misc3d")) {
  # Togliatti surface equation: f(x,y,z) = 0
  # Due to Stephane Laurent
  f <- function(x,y,z){
    w <- 1
    64*(x-w)*
      (x^4-4*x^3*w-10*x^2*y^2-4*x^2*w^2+16*x*w^3-20*x*y^2*w+5*y^4+16*w^4-20*y^2*w^2) -
      5*sqrt(5-sqrt(5))*(2*z-sqrt(5-sqrt(5))*w)*(4*(x^2+y^2-z^2)+(1+3*sqrt(5))*w^2)^2
  }
  # make grid
  # The original had 220 instead of 20, this is coarse to be quicker
  nx <- 20; ny <- 20; nz <- 20
  x <- seq(-5, 5, length=nx)
  y <- seq(-5, 5, length=ny)
  z <- seq(-4, 4, length=nz)
  g <- expand.grid(x=x, y=y, z=z)
  # calculate voxel
  voxel <- array(with(g, f(x,y,z)), dim = c(nx,ny,nz))
  
  # compute isosurface
  open3d(useNULL = TRUE)
  surf <- as.mesh3d(misc3d::contour3d(voxel, maxvol=max(voxel), level=0, x=x, y=y, z=z))
  close3d()
  
  surf$normals <- NULL
  surf <- mergeVertices(surf)
  surf <- addNormals(surf)
  
  fn <- function(x) {
    rowSums(x^2)
  }
  
  open3d()
  shade3d(clipMesh3d(surf, fn, bound = 4.8^2,
                     greater = FALSE), col="red")
}
}
