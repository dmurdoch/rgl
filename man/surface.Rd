\name{rgl.surface}
\title{Add surface (obsolete)}
\alias{rgl.surface}
\description{
  Adds a surface to the current scene. The surface is defined by 
  a matrix defining the height of each grid point and two vectors
  defining the grid.
}
\usage{
rgl.surface(x, z, y, coords = 1:3, ..., 
            normal_x = NULL, normal_y = NULL, normal_z = NULL,
            texture_s = NULL, texture_t = NULL)
}
\arguments{
  \item{ x }{
    values corresponding to rows of \code{y}, or matrix of x coordinates
  }
  \item{ y }{
    matrix of height values
  }
  \item{ z }{
    values corresponding to columns of \code{y}, or matrix of z coordinates
  }
  \item{ coords }{
    See details
  }
  \item{ ... }{Material and texture properties. See \code{\link{rgl.material}} for details.} 
  \item{normal_x, normal_y, normal_z}{
      matrices of the same dimension as \code{y} giving the coordinates of normals at 
      each grid point}
  \item{texture_s, texture_t}{
      matrices of the same dimension as \code{z} giving the coordinates within the current texture
      of each grid point}


}
\details{
  Adds a surface mesh to the current scene. The surface is defined by 
  the matrix of height values in \code{y}, with rows corresponding 
  to the values in \code{x} and columns corresponding to the values in 
  \code{z}.
  
  The \code{coords} parameter can be used to change the geometric
  interpretation of \code{x}, \code{y}, and \code{z}.  The first entry 
  of \code{coords} indicates which coordinate (\code{1 = X}, 
  \code{2 = Y}, \code{3 = Z}) corresponds to the \code{x} parameter.
  Similarly the second entry corresponds to the \code{y} parameter,
  and the third entry to the \code{z} parameter.  In this way 
  surfaces may be defined over any coordinate plane.
  
  If the normals are not supplied, they will be calculated automatically based
  on neighbouring points.
  
  Texture coordinates run from 0 to 1 over each dimension of the texture bitmap.
  If texture coordinates are not supplied, they will be calculated to 
  render the texture exactly once over the grid.  Values greater than 1 can be
  used to repeat the texture over the surface.
  
  \code{rgl.surface} always draws the surface with the `front' upwards
  (i.e. towards higher \code{y} values).  This can be used to render
  the top and bottom differently; see \code{\link{rgl.material}} and
  the example below.
  
  If the \code{x} or \code{z} argument is a matrix, then it must be of the same
  dimension as \code{y}, and the values in the matrix will be used for the corresponding
  coordinates. This is used to plot shapes such as cylinders
  where y is not a function of x and z.
  
  \code{NA} values in the height matrix are not drawn.
}
\note{
It is recommended to use \code{\link{surface3d}} instead
of \code{rgl.surface}; use of the \code{rgl.*} functions 
is discouraged due to their side effects.
}
\value{
  The object ID of the displayed surface is returned invisibly.
}
\examples{

#
# volcano example taken from "persp"
#

data(volcano)

y <- 2 * volcano        # Exaggerate the relief

x <- 10 * (1:nrow(y))   # 10 meter spacing (S to N)
z <- 10 * (1:ncol(y))   # 10 meter spacing (E to W)

ylim <- range(y)
ylen <- ylim[2] - ylim[1] + 1

colorlut <- terrain.colors(ylen) # height color lookup table

col <- colorlut[ y - ylim[1] + 1 ] # assign colors to heights for each point

rgl.open()
rgl.surface(x, z, y, color = col, back = "lines")

}
\seealso{
  \code{\link{rgl.material}}, \code{\link{surface3d}}, \code{\link{terrain3d}}.
  See \code{\link{persp3d}} for a higher level interface.
}
\keyword{dynamic}
