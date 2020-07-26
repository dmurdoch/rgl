\name{sprites}
\alias{sprites3d}
\alias{particles3d}
\alias{rgl.sprites}
\title{add sprite set shape}
\description{
  Adds a sprite set shape node to the scene.
}
\usage{
sprites3d(x, y = NULL, z = NULL, radius = 1, shapes = NULL, userMatrix, 
            ...)
particles3d(x, y = NULL, z = NULL, radius = 1, ...)
rgl.sprites(x, y = NULL, z = NULL, radius = 1, shapes = NULL, userMatrix, 
            fixedSize = FALSE, ...)
}
\arguments{
  \item{ x, y, z }{point coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{ radius }{vector or single value defining the sphere radius}
  \item{ shapes }{\code{NULL} for a simple square, or a vector of
    identifiers of shapes in the scene}
  \item{ userMatrix }{if \code{shape} is not \code{NULL}, the transformation matrix 
    for the shapes}
  \item{ fixedSize }{should sprites remain at a fixed size,
or resize with the scene?}
  \item{ ... }{material properties when \code{shape == 0}, texture mapping is supported}
}
\details{
  Simple sprites (used when \code{shapes} is \code{NULL}) are 1 by 1 squares
  that are directed towards the viewpoint. Their primary use is for
  fast (and faked) atmospherical effects, e.g. particles and clouds
  using alpha blended textures. Particles are Sprites using an alpha-blended 
  particle texture giving the illusion of clouds and gasses.  
  The centre of each square will be at the coordinates given by \code{x, y, z}.
  
  When \code{shapes} is not \code{NULL}, it should be a vector of
  identifers of objects to plot in the scene (e.g. as returned by
  plotting functions or by \code{\link{ids3d}}).  These objects will
  be removed from the scene and duplicated as a sprite image in a
  constant orientation, as specified by \code{userMatrix}.  The 
  origin \code{0, 0, 0} will be plotted at the coordinates given by \code{x, y, z}.
  
  The \code{userMatrix} argument is ignored for \code{shapes = NULL}.  For
  shapes, \code{sprites3d} defaults the matrix to \code{r3dDefaults$userMatrix}
  while \code{rgl.sprites} defaults it to an identity transformation.
  
  If any coordinate is \code{NA}, the sprite is not plotted.
  
  The id values of the shapes are retrieved using \code{rgl.attrib(id, "ids")};
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
  \code{\link{rgl.material}}
}
\keyword{dynamic}

