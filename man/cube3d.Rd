\name{cube3d}
\alias{cube3d}
\alias{oh3d}
\alias{tetrahedron3d}
\alias{octahedron3d}
\alias{icosahedron3d}
\alias{dodecahedron3d}
\alias{cuboctahedron3d}

\title{Sample 3D mesh objects}
\description{
A collection of sample mesh objects.
}
\usage{
  cube3d(trans = identityMatrix(), ...)  
  tetrahedron3d(trans = identityMatrix(), ...)  
  octahedron3d(trans = identityMatrix(), ...)  
  icosahedron3d(trans = identityMatrix(), ...)
  dodecahedron3d(trans = identityMatrix(), ...)
  cuboctahedron3d(trans = identityMatrix(), ...)
  
  oh3d(trans = identityMatrix(), ...)    # an 'o' object

}

\arguments{
  \item{trans}{transformation to apply to objects}
  \item{...}{additional parameters to pass to \code{\link{mesh3d}}}
}
\details{

  These sample objects optionally take a 4x4 matrix transformation \code{trans} as 
  an argument.  This transformation is applied to all vertices of the default shape.
  The default is an identity transformation. 
}
\value{
Objects of class \code{c("mesh3d",
  "shape3d")}. 
}
\examples{
  # render all of the Platonic solids
  open3d()
  shade3d( translate3d( tetrahedron3d(col = "red"), 0, 0, 0) )
  shade3d( translate3d( cube3d(col = "green"), 3, 0, 0) )
  shade3d( translate3d( octahedron3d(col = "blue"), 6, 0, 0) )
  shade3d( translate3d( dodecahedron3d(col = "cyan"), 9, 0, 0) )
  shade3d( translate3d( icosahedron3d(col = "magenta"), 12, 0, 0) )
}
\seealso{
  \code{\link{mesh3d}}
}
\keyword{dynamic}
