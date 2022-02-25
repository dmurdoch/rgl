\name{sprites}
\alias{sprites3d}
\alias{particles3d}
\title{Add sprites}
\description{
  Adds a sprite set shape node to the scene.
}
\usage{
sprites3d(x, y = NULL, z = NULL, radius = 1, 
          shapes = NULL, userMatrix, 
          fixedSize = FALSE, 
          adj = 0.5, pos = NULL, offset = 0.25, 
          rotating = FALSE, ...)
particles3d(x, y = NULL, z = NULL, radius = 1, ...)
}
\arguments{
  \item{ x, y, z }{point coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{ radius }{vector or single value defining the sprite radius}
  \item{ shapes }{\code{NULL} for a simple square, or a vector of
    identifiers of shapes in the scene}
  \item{ userMatrix }{if \code{shape} is not \code{NULL}, the transformation matrix 
    for the shapes}
  \item{ fixedSize }{should sprites remain at a fixed size,
or resize with the scene?}
  \item{ adj, pos, offset }{positioning arguments; see Details}
  \item{ rotating }{should sprites remain at a fixed orientation, or rotate with the scene?}
  \item{ ... }{material properties when \code{shapes = NULL}, texture mapping is supported}
}
\details{
  Simple sprites (used when \code{shapes} is \code{NULL}) are 1 by 1 squares
  that are directed towards the viewpoint. Their primary use is for
  fast (and faked) atmospherical effects, e.g. particles and clouds
  using alpha blended textures. Particles are sprites using an alpha-blended 
  particle texture giving the illusion of clouds and gases.  
  The centre of each square will by default be at the
coordinates given by \code{x, y, z}.  This may be adjusted
using the \code{adj} or \code{pos} parameters.

\code{adj} and \code{pos} are treated similarly to the same
parameters for \code{\link{text3d}}.  \code{adj} has 3
entries, for adjustment to the \code{x}, \code{y} and
\code{z} coordinates respectively.  For \code{x}, a value
of 0 puts the sprite to the right of the specified point,
0.5 centers it there, and 1 puts it to the left.  The other
coordinates are similar.  By default, each value is 0.5 and
the sprites are centered at the points given by \code{(x, y, z)}.

The \code{pos} parameter overrides \code{adj}.  It should
be an integer or vector of integers (one per point),
interpreted as in \code{\link{text3d}} to position the
sprite relative to the \code{(x, y, z)} point:  0 is centered on it, 1 is below,
2 is to the left, 3 is above, 4 is to the right, 5 is in
front, and 6 is behind.  \code{offset} is the
fraction of the sprite size to separate it from the point.

  When \code{shapes} is not \code{NULL}, it should be a vector of
  identifiers of objects to plot in the scene (e.g. as returned by
  plotting functions or by \code{\link{ids3d}}).  These objects will
  be removed from the scene and duplicated as a sprite image in a
  constant orientation, as specified by \code{userMatrix}.  By default the 
  origin \code{(0, 0, 0)} will be plotted at the coordinates given by \code{(x, y, z)}, perhaps modified by \code{adj}
  or \code{pos}.
  
  The \code{userMatrix} argument is ignored for \code{shapes = NULL}.  For
  shapes, \code{sprites3d} defaults the matrix to \code{r3dDefaults$userMatrix}.
  
  If any coordinate is \code{NA}, the sprite is not plotted.
  
  The id values of the shapes may be retrieved after plotting
using \code{rgl.attrib(id, "ids")};
the user matrix is retrieved using \code{rgl.attrib(id, "usermatrix")}.
}
\value{
  These functions are called for the side effect of displaying the sprites.
  The shape ID of the displayed object is returned.
}
\examples{
open3d()
particles3d( rnorm(100), rnorm(100), rnorm(100), color = rainbow(100) )
# is the same as
sprites3d( rnorm(100), rnorm(100), rnorm(100), color = rainbow(100),
  lit = FALSE, alpha = .2,
  textype = "alpha", texture = system.file("textures/particle.png", package = "rgl") )
sprites3d( rnorm(10) + 6, rnorm(10), rnorm(10), shape = shade3d(tetrahedron3d(), col = "red") )
}
\seealso{
  \code{\link{material3d}}, \code{\link{text3d}}
}
\keyword{dynamic}

