\name{rgl.primitive}
\alias{rgl.primitive}
\alias{rgl.points}
\alias{rgl.lines}
\alias{rgl.linestrips}
\alias{rgl.triangles}
\alias{rgl.quads}
\title{add primitive set shape}
\description{
  Adds a shape node to the current scene
}
\usage{
rgl.points(x, y = NULL, z = NULL, ... )
rgl.lines(x, y = NULL, z = NULL, ... )
rgl.linestrips(x, y = NULL, z = NULL, ...)
rgl.triangles(x, y = NULL, z = NULL, normals=NULL, texcoords=NULL, ... )
rgl.quads(x, y = NULL, z = NULL, normals=NULL, texcoords=NULL, ... )
}
\arguments{
  \item{x, y, z}{coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{normals}{Normals at each point.}
  \item{texcoords}{Texture coordinates at each point.}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
}
\details{
  Adds a shape node to the scene. The appearance is defined by the material properties.
  See \code{\link{rgl.material}} for details.
  
  The names of these functions correspond to OpenGL primitives.  They
  all take a sequence of vertices in \code{x,y,z}.  The only non-
  obvious ones are \code{rgl.lines} which draws line segments based on
  pairs of vertices, and \code{rgl.linestrips} which joins the
  vertices.
  
  For triangles and quads, the normals at each vertex may be specified
  using \code{normals}.  These may be given in any way that would be
  acceptable as a single argument to \code{\link[grDevices]{xyz.coords}}.  
  These need not match the actual normals to the polygon:
  curved surfaces can be simulated by using other choices of normals.
  
  Texture coordinates may also be specified.  These may be given in
  any way that would be acceptable as a single argument to 
  \code{\link[grDevices]{xy.coords}}, and are interpreted in terms
  of the bitmap specified as the material texture, with \code{(0,0)} 
  at the lower left, \code{(1,1)} at the upper right.  The texture
  is used to modulate the colour of the polygon.
  
  These are the lower level functions called by
  \code{\link{points3d}}, \code{\link{segments3d}},
  \code{\link{lines3d}}, etc.  The two principal differences between
  the \code{rgl.*} functions and the \code{*3d} functions are that the
  former set all unspecified material properties to defaults, whereas
  the latter use current values as defaults; the former make
  persistent changes to material properties with each call, whereas
  the latter make temporary changes only for the duration of the call.

}
\value{
   Each primitive function returns the integer object ID of the shape that
   was added to the scene.  These can be passed to \code{\link{rgl.pop}}
   to remove the object from the scene.
}
\examples{
rgl.open()
rgl.points(rnorm(1000), rnorm(1000), rnorm(1000), color=heat.colors(1000))
}
\seealso{
\code{\link{rgl.material}},
\code{\link{rgl.spheres}},
\code{\link{rgl.texts}},
\code{\link{rgl.surface}},
\code{\link{rgl.sprites}}
}
\keyword{dynamic}
