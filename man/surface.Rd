\name{rgl.surface}
\title{add height-field surface shape}
\alias{rgl.surface}
\description{
  Adds a surface to the current scene. The surface is defined by two
  grid mark vectors and a matrix defining the height of each grid point.
}
\usage{
rgl.surface(x, z, y, ...)
}
\arguments{
  \item{ x, z }{
    x,z axis tick marks
  }
  \item{ y }{
    y height values
  }
  \item{ ... }{Material and texture properties. See \code{\link{rgl.material}} for details.}    
}
\details{
  Adds a surface mesh to the current scene. The surface is evaluated by 
  defining the x- and z-axis tick marks for the control grid. The
  matrix y defines the height values for each point.
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
