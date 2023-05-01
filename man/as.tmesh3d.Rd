\name{as.tmesh3d}
\alias{as.tmesh3d}
\alias{as.tmesh3d.default}
\alias{as.tmesh3d.mesh3d}
\title{
Convert object to a triangular mesh
}
\description{
Converts the quads in a mesh version of an object to
triangles by splitting them up.  Optionally drops any
point or segment components.
}
\usage{
as.tmesh3d(x, ...)
\method{as.tmesh3d}{default}(x, drop = FALSE, ...)
\method{as.tmesh3d}{mesh3d}(x, drop = FALSE, recordOrig = FALSE, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
An object from which to create a triangular mesh object.
}
  \item{drop}{
If \code{TRUE}, drop any point or segment components.
  }
  \item{recordOrig}{
Whether to include the \code{"orig"} component in the output.
  }
  \item{\dots}{
Ignored in the \code{mesh3d} method, passed to 
\code{as.mesh3d} in the default method.
}
}
\details{
The default method simply calls \code{\link{as.mesh3d}(x, ...)}
and passes the result to the \code{"mesh3d"} method.
}
\note{
Older versions of \pkg{rgl} had a \code{"tmesh3d"} class
for meshes of triangles.  That class is no longer used:
\code{as.tmesh3d} and \code{\link{tmesh3d}} both produce
\code{"mesh3d"} objects.
}
\value{
A \code{"mesh3d"} object containing no quads.  If \code{drop = TRUE}, it will only contain triangles.  

If \code{recordOrig = TRUE}, an \code{"orig"} element will be 
added to the result.  By default it shows the correspondence between
the elements of 
the input mesh (in the same order as used when shading with 
\code{meshColor == "faces"}) and the output mesh, but if
\code{mesh$orig} is non-\code{NULL}
on input, it may be any vector with appropriate length and 
the output will propagate values to the new mesh.
}
\author{
Duncan Murdoch
}

\seealso{
\code{as.triangles3d} to get just the coordinates.
}
\examples{
x <- cuboctahedron3d()
x             # has quads and triangles
as.tmesh3d(x) # has only triangles
}