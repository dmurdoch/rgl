\name{addNormals}
\alias{addNormals}
\alias{addNormals.mesh3d}
\alias{addNormals.shapelist3d}
\title{
Add normal vectors to objects so they render more smoothly.
}
\description{
This generic function adds normals at each of the vertices
of a polyhedron by averaging the normals of each incident face.  This has the
effect of making the surface of the object appear smooth rather than faceted
when rendered.
}
\usage{
addNormals(x, ...)
\method{addNormals}{mesh3d}(x, angleWeighted = TRUE, ...)
}
\arguments{
  \item{x}{An object to which to add normals.}
  \item{\dots}{Additional parameters which will be passed to the methods.}
  \item{angleWeighted}{See Details below.}
}
\details{
Currently methods are supplied for \code{\link[=mesh3d]{"mesh3d"}} and 
\code{\link[=shapelist3d]{"shapelist3d"}} classes.

These methods work by averaging the normals on the faces incident at 
each vertex.  By default these are weighted according to the angle 
in the polygon at that vertex.
If \code{angleWeighted = FALSE}, a slightly faster
but less accurate weighting by the triangle area is used.  

Prior to \pkg{rgl} version 0.104.12 an incorrect weighting was used; 
it can be partially reproduced by using \code{angleWeighted = NA}, 
but not all the bugs in that scheme will be kept.
}
\value{
A new object of the same class as \code{x}, with normals added.
}
\author{
Duncan Murdoch
}
\examples{
open3d()
y <- subdivision3d(tetrahedron3d(col = "red"), depth = 3)
shade3d(y) # No normals
y <- addNormals(y)
shade3d(translate3d(y, x = 1, y = 0, z = 0)) # With normals
}
\keyword{dynamic}
