\name{as.mesh3d}
\alias{as.mesh3d}
\alias{as.mesh3d.default}
\title{
Convert object to mesh object
}
\description{
The \code{as.mesh3d} generic function converts various objects
to \code{\link{mesh3d}} objects.  

The default method takes takes a matrix of vertices 
as input and (optionally) merges repeated vertices, producing a \code{\link{mesh3d}}
object as output.  It will contain either triangles or quads
according to the \code{triangles} argument.

If the generic is called without any argument, it will pass
all RGL ids from the current scene to the 
\code{\link{as.mesh3d.rglId}} method.
}
\usage{
as.mesh3d(x, ...)
\method{as.mesh3d}{default}(x, y = NULL, z = NULL, 
             triangles = length(x) \%\% 3 == 0, 
             smooth = FALSE, 
             tolerance = sqrt(.Machine$double.eps), 
             notEqual = NULL, 
             merge = TRUE,
             ...)
}
\arguments{
  \item{x, y, z}{
For the generic, \code{x} is the object to convert.
For the default method, \code{x}, \code{y} and \code{z} are
coordinates. Any reasonable way of defining the coordinates is
acceptable. See the function \code{\link{xyz.coords}} for details.
}
  \item{triangles}{
Logical value indicating whether the coordinates are for triangles
or quadrilaterals.
}
  \item{smooth}{
If \code{TRUE}, \code{\link{addNormals}} will be called on the mesh
object to make it render smoothly.
}  
  \item{tolerance}{
The numerical tolerance to be used in \code{\link{all.equal}} to
determine whether two vertices should be merged.
}
  \item{notEqual}{
If not \code{NULL}, an n by n matrix of logical values, where n is the
number of vertices as input.  \code{TRUE} entries indicate that the
corresponding pair of vertices should not be merged even if they appear equal.
}
  \item{merge}{
Should apparently equal vertices be merged?
  }
  \item{\dots}{
Material properties to pass to \code{\link{tmesh3d}} or \code{\link{qmesh3d}}.
}
}
\details{
The motivation for this function is the following problem:  I was
asked whether RGL could render a surface made up of triangles or 
quadrilaterals to look smooth.  It can do that, but needs normals at 
each vertex; they should be the average of the normals for each polygon 
sharing that vertex.  Then OpenGL will interpolate the normals across 
the polygons and give the illusion of smoothness.

To do this, it needs to know which polygons share each vertex.  If the 
surface is described as a list of triangles or quadrilaterals, that 
means identifying vertices that are in multiple polygons, and converting 
the representation to a \code{"\link{mesh3d}"} object (which is a matrix of vertices 
and a matrix of vertex numbers making up triangles or quads).  Then the 
\code{\link{addNormals}} function will add the normals.

Sometimes two polygons will share vertices (within numerical 
tolerance) without the user wanting them to be considered internal to 
the surface, or might want one sharp edge in an otherwise smooth 
surface.  This means I needed a way to declare that two vertices from 
the original list of vertices in the triangles or quads are "not equal", 
even when they test numerically equal.  That's what the \code{notEqual} matrix specifies.
}
\value{
A \code{"\link{mesh3d}"} object with the same faces as in the 
input, but (if \code{merge=TRUE}) with vertices that test equal to
within \code{tolerance} merged.  
}
\author{
Duncan Murdoch
}
\examples{
xyz <- matrix(c(-1, -1, -1,
                -1,  1, -1,
                 1,  1, -1,
                 1, -1, -1,
                -1,  1, -1,
                -1,  1,  1,
                 1,  1,  1,
                 1,  1, -1,
                 1, -1, -1,
                 1,  1, -1,
                 1,  1,  1,
                 1, -1,  1), byrow = TRUE, ncol = 3)
mesh <- as.mesh3d(xyz, triangles = FALSE, col = "red")
mesh$vb
mesh$ib
open3d()
shade3d(mesh)

# Stop vertices 2 and 5 from being merged
notEQ <- matrix(FALSE, 12, 12)
notEQ[2, 5] <- TRUE
mesh <- as.mesh3d(xyz, triangles = FALSE, notEqual = notEQ)
mesh$vb
mesh$ib
}
