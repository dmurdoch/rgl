\name{rgl.surface}
\title{add height-field surface shape}
\alias{rgl.surface}
\description{
  Adds a surface to the current scene. The surface is defined by 
  a matrix defining the height of each grid point and two vectors
  defining the grid.
}
\usage{
rgl.surface(x, z, y, coords=1:3, ...)
}
\arguments{
  \item{ x }{
    values corresponding to rows of \code{y}
  }
  \item{ y }{
    matrix of height values
  }
  \item{ z }{
    values corresponding to columns of \code{y}
  }
  \item{ coords }{
    See details
  }
  \item{ ... }{Material and texture properties. See \code{\link{rgl.material}} for details.}    
}
\details{
  Adds a surface mesh to the current scene. The surface is defined by 
  the matrix of height values in \code{y}, with rows corresponding 
  to the values in \code{x} and columns corresponding to the values in 
  \code{z}.
  
  The \code{coords} parameter can be used to change the geometric
  interpretation of \code{x}, \code{y}, and \code{z}.  The first entry 
  of \code{coords} indicates which coordinate (\code{1=X}, 
  \code{2=Y}, \code{3=Z}) corresponds to the \code{x} parameter.
  Similarly the second entry corresponds to the \code{y} parameter,
  and the third entry to the \code{z} parameter.  In this way 
  surfaces may be defined over any coordinate plane.
  
  \code{rgl.surface} always draws the surface with the `front' upwards
  (i.e. towards higher \code{y} values).  This can be used to render
  the top and bottom differently; see \code{\link{rgl.material}} and
  the example below.
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
rgl.surface(x, z, y, color=col, back="lines")

}
\seealso{
  \code{\link{rgl.material}}, \code{\link{surface3d}}, \code{\link{terrain3d}}
}
\keyword{dynamic}
