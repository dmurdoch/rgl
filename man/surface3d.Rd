\name{surface3d}
\title{Add surface}
\alias{surface3d}
\description{
  Adds a surface to the current scene. The surface is defined by 
  a matrix defining the height of each grid point and two vectors or matrices
  defining the grid.
}
\usage{
surface3d(x, y, z, ..., 
         normal_x = NULL, normal_y = NULL, normal_z = NULL,
         texture_s=NULL, texture_t=NULL, flip = FALSE)
}
\arguments{
  \item{ x, y, z }{
    vectors or matrices of values.  See Details.
  }
  \item{ ... }{Material properties. See \code{\link{material3d}} for details.}    
  \item{normal_x, normal_y, normal_z}{
    matrices giving the coordinates of normals at 
    each grid point
  }
  \item{texture_s, texture_t}{
    matrices giving the texture coordinates at each
    grid point
  }
  \item{flip}{
    flip definition of \dQuote{up}
  }
}
\details{
Adds a surface mesh to the current scene. The surface is 
typically defined by a matrix of height values in \code{z}
(as in \code{\link{persp}}), 
but any of \code{x}, \code{y}, or \code{z} may be matrices or
vectors, as long as at least one is a matrix.  (One 
historical exception is allowed:  if all are vectors but
the length of \code{z} is the product of the lengths of
\code{x} and \code{y}, \code{z} is converted to a matrix.)

Dimensions of all matrices must match.

If any of the coordinates are vectors, they are interpreted as follows:
\itemize{
\item If \code{x} is a vector, it corresponds to rows of the matrix.
\item If \code{y} is a vector, it corresponds to columns
of the matrix.
\item If \code{z} is a vector, it corresponds to columns
unless \code{y} is also a vector, in which case it corresponds
to rows.
}

  If the normals are not supplied, they will be calculated automatically based
  on neighbouring points.

  Texture coordinates run from 0 to 1 over each dimension of the texture bitmap.
  If texture coordinates are not supplied, they will be calculated to 
  render the texture exactly once over the grid.  Values greater than 1 can be
  used to repeat the texture over the surface.
  
  \code{surface3d} always tries to draw the surface with the `front' upwards
  (typically towards higher \code{z} values).  This can be used to render
  the top and bottom differently; see \code{\link{material3d}} and
  the example below.  If you don't like its choice, set
  \code{flip = TRUE} to use the opposition definition.
  
  \code{NA} values in the height matrix are not drawn.
  
}
\examples{
#
# volcano example taken from "persp"
#

z <- 2 * volcano        # Exaggerate the relief

x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

zlim <- range(z)
zlen <- zlim[2] - zlim[1] + 1

colorlut <- terrain.colors(zlen) # height color lookup table

col <- colorlut[ z - zlim[1] + 1 ] # assign colors to heights for each point

open3d()
surface3d(x, y, z, color = col, back = "lines")

}
\seealso{
  See \code{\link{persp3d}} for a higher level interface.
}
\keyword{dynamic}
