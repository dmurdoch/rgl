\name{surface3d}
\title{add height-field surface shape}
\alias{surface3d}
\alias{terrain3d}
\description{
  Adds a surface to the current scene. The surface is defined by 
  a matrix defining the height of each grid point and two vectors
  defining the grid.
}
\usage{
surface3d(x, y, z, ..., normal_x=NULL, normal_y=NULL, normal_z=NULL)
terrain3d(x, y, z, ..., normal_x=NULL, normal_y=NULL, normal_z=NULL)
}
\arguments{
  \item{ x }{
    values corresponding to rows of \code{z}, or matrix of x coordinates
  }
  \item{ y }{
    values corresponding to the columns of \code{z}, or matrix of y coordinates
  }
  \item{ z }{
    matrix of heights
  }
  \item{ ... }{Material and texture properties. See \code{\link{rgl.material}} for details.}    
  \item{normal_x, normal_y, normal_z}{
    matrices of the same dimension as \code{z} giving the coordinates of normals at 
    each grid point}
}
\details{
  Adds a surface mesh to the current scene. The surface is defined by 
  the matrix of height values in \code{z}, with rows corresponding 
  to the values in \code{x} and columns corresponding to the values in 
  \code{y}.  This is the same parametrization as used in \code{\link{persp}}.
  
  If the \code{x} or \code{y} argument is a matrix, then it must be of the same
  dimension as \code{z}, and the values in the matrix will be used for the corresponding
  coordinates. This is used to plot shapes such as cylinders
  where z is not a function of x and y.
  
  If the normals are not supplied, they will be calculated automatically based
  on neighbouring points.
  
  \code{surface3d} always draws the surface with the `front' upwards
  (i.e. towards higher \code{z} values).  This can be used to render
  the top and bottom differently; see \code{\link{rgl.material}} and
  the example below.
  
  For more flexibility in defining the surface, use \code{\link{rgl.surface}}.
  
  \code{surface3d} and \code{terrain3d} are synonyms.
}
\examples{

#
# volcano example taken from "persp"
#

data(volcano)

z <- 2 * volcano        # Exaggerate the relief

x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

zlim <- range(y)
zlen <- zlim[2] - zlim[1] + 1

colorlut <- terrain.colors(zlen) # height color lookup table

col <- colorlut[ z-zlim[1]+1 ] # assign colors to heights for each point

open3d()
surface3d(x, y, z, color=col, back="lines")

}
\seealso{
  \code{\link{rgl.material}}, \code{\link{rgl.surface}}, \code{\link{persp}}
}
\keyword{dynamic}
