\name{clipMesh3d}
\alias{clipMesh3d}
\alias{clipObj3d}
\title{
Clip mesh or \pkg{rgl} object to general region
}
\description{
Modifies a mesh3d object so that values of 
a function are bounded.
}
\usage{
clipMesh3d(mesh, fn, bound = 0, greater = TRUE, 
           attribute = "vertices",
           minVertices = 0)
clipObj3d(ids, fn, bound = 0, greater = TRUE,
           attribute = "vertices", 
           minVertices = 0,
           subscenes = currentSubscene3d())
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
  \item{minVertices}{
See Details below.
  }
  \item{ids}{
The \pkg{rgl} id value(s) of objects to clip.
  }
  \item{subscenes}{
Which subscenes should receive the modified object?
  }
}
\details{
These functions transform a mesh3d object or other
rgl objects. 

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

Modifications to triangles depend
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

Modifications to line segments are similar:  the segment
will be shortened if it crosses the boundary, or omitted
if it is entirely out of bounds.  Points, spheres, text
and sprites will just be kept or rejected.

The \code{minVertices} argument is used to improve the 
approximation to the boundary when \code{fn} is a non-linear
function.  In that case, the interpolation described above
can be inaccurate.  If \code{minVertices} is set to a
positive
number (e.g. \code{10000}), then each object is modified
by subdivision to have at least that number of vertices, 
so that pieces are smaller and the linear interpolation
is more accurate.  In the \code{clipObj3d} function, 
\code{minVertices} can be a vector, with entries corresponding
to each of the entries in \code{ids}.
}
}
\value{
\code{clipMesh3d} returns new mesh3d object in which all vertices (approximately) satisfy the
clipping condition.  Note that the order of vertices will likely
differ from the original order, and new vertices will be added near
the boundary (and if \code{minVertices > 0}, in the 
interior).

\code{clipObj3d} is called for the side effect of modifying
the scene.  It returns a list of new \pkg{rgl} id values
corresponding to the \code{ids} passed as arguments.
}
\author{
Duncan Murdoch
}
\references{
See \url{https://stackoverflow.com/q/56242470/2554330} for a
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

# Show the problem that minVertices solves:

cube <- cube3d(col = "red")
vecnorm <- function(vals) apply(vals, 1, function(row) sqrt(sum(row^2)))

open3d()
mfrow3d(2, 2, sharedMouse = TRUE)
id1 <- shade3d(cube)
# All vertices have norm sqrt(3), so this clips nothing:
clipObj3d(id1, fn = vecnorm, bound = sqrt(2))
next3d()
id2 <- wire3d(cube, lit = FALSE)
clipObj3d(id2, fn = vecnorm, bound = sqrt(2))

# This subdivides the cube, and does proper clipping:
next3d()
id3 <- shade3d(cube)
clipObj3d(id3, fn = vecnorm, bound = sqrt(2), minVertices = 200)
next3d()
id4 <- wire3d(cube, lit = FALSE)
clipObj3d(id4, fn = vecnorm, bound = sqrt(2), minVertices = 200)

}
