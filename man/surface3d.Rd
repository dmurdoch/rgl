\name{surface3d}
\title{Add surface}
\alias{surface3d}
\alias{terrain3d}
\description{
  Adds a surface to the current scene. The surface is defined by 
  a matrix defining the height of each grid point and two vectors
  defining the grid.
}
\usage{
surface3d(x, y, z, ..., normal_x = NULL, normal_y = NULL, normal_z = NULL)
terrain3d(x, y, z, ..., normal_x = NULL, normal_y = NULL, normal_z = NULL)
}
\arguments{
  \item{ x, y, z }{
    vectors or matrices of values.  See Details.
  }
  \item{ ... }{Material and texture properties. See \code{\link{rgl.material}} for details.}    
  \item{normal_x, normal_y, normal_z}{
    matrices giving the coordinates of normals at 
    each grid point}
}
\details{
Adds a surface mesh to the current scene. The surface is 
typically defined by a matrix of height values in \code{z}
(as in \code{\link{persp}}), 
but any of \code{x}, \code{y}, or \code{z} may be matrices or
vectors, as long as at least one is a matrix.  If 
\code{x} is a vector it is taken to correspond to rows
of the matrix; if \code{y} is a vector it corresponds to
columns; if \code{z} is a vector it corresponds to rows
or columns as appropriate.

Dimensions of all matrices must match.
  
  If the normals are not supplied, they will be calculated automatically based
  on neighbouring points.
  
  \code{surface3d} always draws the surface with the `front' upwards
  (i.e. towards higher \code{z} values).  This can be used to render
  the top and bottom differently; see \code{\link{material3d}} and
  the example below.
  
  \code{surface3d} and \code{terrain3d} are synonyms.
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
  \code{\link{rgl.material}}, \code{\link{rgl.surface}}.
  See \code{\link{persp3d}} for a higher level interface.
}
\keyword{dynamic}
