\name{rgl.primitive}
\alias{rgl.primitive}
\alias{rgl.points}
\alias{rgl.lines}
\alias{rgl.linestrips}
\alias{rgl.triangles}
\alias{rgl.quads}
\title{Add primitive set shape}
\description{
These 
functions are deprecated and should not be called by users.
}
\usage{
rgl.points(x, y = NULL, z = NULL, ... )
rgl.lines(x, y = NULL, z = NULL, ... )
rgl.linestrips(x, y = NULL, z = NULL, ...)
rgl.triangles(x, y = NULL, z = NULL, normals = NULL, texcoords = NULL, ... )
rgl.quads(x, y = NULL, z = NULL, normals = NULL, texcoords = NULL, ... )
}
\arguments{
  \item{x, y, z}{coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{normals}{Normals at each point.}
  \item{texcoords}{Texture coordinates at each point.}
  \item{ ... }{Material properties (see \code{\link{material3d}} for details) or \code{indices} (see \code{\link{points3d}} for details).}  
}
\details{
  Adds a shape node to the scene.
  
Users should never call these functions, which are supplied only
for back-compatibility.
}

\value{
   Each primitive function returns the integer object ID of the shape that
   was added to the scene.  These can be passed to \code{\link{pop3d}}
   to remove the object from the scene.
}
\keyword{internal}
