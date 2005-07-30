\name{rgl.surface}
\title{add height-field surface shape}
\alias{rgl.surface}
\alias{surface3d}
\alias{terrain3d}
\description{
  Adds a surface to the current scene. The surface is defined by two
  grid mark vectors and a matrix defining the height of each grid point.
}
\usage{
terrain3d(x, y, z, ...)
rgl.surface(x, z, y, coords=1:3, ...)
}
\arguments{
  \item{ x, z }{
    x,z axis tick marks
  }
  \item{ y }{
    y height values
  }
  \item{ coords }{
    See details
  \item{ ... }{Material and texture properties. See \code{\link{rgl.material}} for details.}    
}
\details{
  Adds a surface mesh to the current scene. The surface is evaluated by 
  defining the x- and z-axis tick marks for the control grid. The
  matrix y defines the height values for each point.
  
  The \code{coords} parameter can be used to change the geometric
  interpretation of the x, y, and z coordinates.  The first entry of
  the \code{coords} vector indicates which coordinate (\code{1=x}, 
  \code{2=y}, \code{3=z}) corresponds to the \code{x} parameter.
  Similarly the second entry corresponds to the \code{y} parameter,
  and the third entry to the \code{z} parameter.
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

col <- colorlut[ y-ylim[1]+1 ] # assign colors to heights for each point

rgl.clear()
rgl.surface(x, z, y, color=col)

}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
