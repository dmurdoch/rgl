\name{subdivision3d}
\alias{subdivision3d}
\alias{subdivision3d.mesh3d}
\alias{divide.mesh3d}
\alias{normalize.mesh3d}
\alias{deform.mesh3d}
\title{Subdivide a mesh}
\description{
The subdivision surface algorithm divides and refines (deforms) a
given mesh recursively to certain degree (depth).
The mesh3d algorithm consists of two stages: divide and deform.
The divide step generates for each triangle or quad four new triangles or quads, the deform
step drags the points (refinement step).
}
\usage{
  subdivision3d( x,  ...)
  \method{subdivision3d}{mesh3d}( x, depth = 1, normalize = FALSE, deform = TRUE, ... )
  divide.mesh3d(mesh,  vb = mesh$vb, ib = mesh$ib, it = mesh$it )
  normalize.mesh3d(mesh)
  deform.mesh3d(mesh, vb = mesh$vb, ib = mesh$ib, it = mesh$it )
}
\arguments{
  \item{x}{3d geometry mesh}
  \item{mesh}{3d geometry mesh}
  \item{depth}{recursion depth}
  \item{normalize}{normalize mesh3d coordinates after division if \code{deform} is \code{TRUE}}
  \item{deform}{deform mesh}
  \item{it}{indices for triangular faces}
  \item{ib}{indices for quad faces}
  \item{vb}{matrix of vertices: 4 x n matrix (rows x, y, z, h) or equivalent
    vector, where h indicates scaling of each plotted quad}
  \item{...}{other arguments (unused)}
}
\details{
\code{subdivision3d} takes
a mesh object and replaces each triangle or quad with 4 new ones
by adding vertices half-way along the edges (and one in the
centre of a quad).  The positions of the vertices are 
deformed so that the resulting surface is smoother than the original.  These operations are repeated \code{depth} times.

The other functions do the individual steps of the subdivision.
\code{divide.mesh3d} adds the extra vertices.  \code{deform.mesh3d}
does the smoothing by replacing each vertex with the average of each of its neighbours. \code{normalize.mesh3d} 
normalizes the homogeneous coordinates, by setting the 
4th coordinate to 1.  (The 4th coordinate is used as a
weight in the deform step.)
}
\examples{
  open3d()
  shade3d( subdivision3d( cube3d(), depth = 3 ), color = "red", alpha = 0.5 )
}
\seealso{
  \code{\link{r3d}}
  \code{\link{mesh3d}}
}
\keyword{dynamic}
