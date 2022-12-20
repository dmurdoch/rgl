\name{rgl.primitive}
\alias{rgl.primitive}
\alias{rgl.points}
\alias{rgl.lines}
\alias{rgl.linestrips}
\alias{rgl.triangles}
\alias{rgl.quads}
\title{Add primitive set shape}
\description{
Adds a shape node to the current scene.  These low-level
functions should not be called by users.
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
  
  The names of these functions correspond to OpenGL primitives.  They
  all take a sequence of vertices in \code{x, y, z}.  The only non-obvious 
  ones are \code{rgl.lines} which draws line segments based on
  pairs of vertices, and \code{rgl.linestrips} which joins the
  vertices.
  
  
  These are the lower level functions called by
  \code{\link{points3d}}, \code{\link{segments3d}},
  \code{\link{lines3d}}, etc.  The two principal differences between
  the \code{rgl.*} functions and the \code{*3d} functions are that the
  former set all unspecified material properties to defaults, whereas
  the latter use current values as defaults; the former make
  persistent changes to material properties with each call, whereas
  the latter make temporary changes only for the duration of the call.  There are also differences in default settings when 
the function calls trigger the opening of a new window.  

Users should never call these functions, which are supplied only
for back-compatibility.
}

\value{
   Each primitive function returns the integer object ID of the shape that
   was added to the scene.  These can be passed to \code{\link{pop3d}}
   to remove the object from the scene.
}
\keyword{internal}
