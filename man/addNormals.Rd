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
}
\arguments{
  \item{x}{An object to which to add normals.}
  \item{\dots}{Additional parameters which will be passed to the methods.  Currently unused.}
}
\details{
Currently methods are supplied for \code{\link[=mesh3d]{"mesh3d"}} and 
\code{\link[=shapelist3d]{"shapelist3d"}} classes.
}
\value{
A new object of the same class as \code{x}, with normals added.
}
\author{
Duncan Murdoch
}
\examples{
open3d()
y <- subdivision3d(tetrahedron3d(col="red"), depth=3)
shade3d(y) # No normals
y <- addNormals(y)
shade3d(translate3d(y, x=1, y=0, z=0)) # With normals
}
\keyword{dynamic}
