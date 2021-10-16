\name{as.mesh3d.rglId}
\alias{as.mesh3d.rglId}
\title{
Convert object in plot to RGL mesh object
}
\description{
This method attempts to read the attributes of objects in the
rgl display and construct a mesh3d object to approximate them.
}
\usage{
\method{as.mesh3d}{rglId}(x, type = NA, subscene = NA, ...)
}
\arguments{
  \item{x}{
A vector of RGL identifiers of objects in the specified subscene.
}
  \item{type}{
A vector of names of types of shapes to convert.  Other shapes 
will be ignored.
  }
  \item{subscene}{
Which subscene to look in; the default \code{NA} specifies the 
current subscene.
  }
  \item{\dots}{
Ignored.
}
}
\details{
This function attempts to construct a triangle mesh to approximate 
one or more objects from the current display.  It can handle objects of types from \code{c("points", "lines", "linestrip", "triangles", "quads", "planes", "surface")}.

Since this method only produces meshes containing points,
segments and triangles, they won't necessarily
be an exact match to the original object.

If the generic \code{\link{as.mesh3d}} is called with no \code{x}
argument, this method will be called with \code{x} set to the 
ids in the current scene.  
}
\value{
A mesh object.
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link{as.triangles3d.rglId}} for extracting the triangles,
\code{\link{clipMesh3d}} to apply complex clipping to a mesh object.
}
\examples{
# volcano example taken from "persp"
#
data(volcano)

z <- 2 * volcano        # Exaggerate the relief

x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

zlim <- range(y)
zlen <- zlim[2] - zlim[1] + 1

colorlut <- terrain.colors(zlen) # height color lookup table

col <- colorlut[ z - zlim[1] + 1 ] # assign colors to heights for each point

open3d(useNULL = TRUE)
surface3d(x, y, z, color = col)
m <- as.mesh3d()
close3d()

open3d()
shade3d(m)
}
