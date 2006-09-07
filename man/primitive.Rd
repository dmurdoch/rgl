\name{rgl.primitive}
\alias{rgl.primitive}
\alias{rgl.points}
\alias{rgl.lines}
\alias{rgl.linestrips}
\alias{rgl.triangles}
\alias{rgl.quads}
\title{add primitive set shape}
\description{
  Adds a shape node to the current scene
}
\usage{
rgl.points(x, y = NULL, z = NULL, ... )
rgl.lines(x, y = NULL, z = NULL, ... )
rgl.linestrips(x, y = NULL, z = NULL, ...)
rgl.triangles(x, y = NULL, z = NULL, ... )
rgl.quads(x, y = NULL, z = NULL, ... )
}
\arguments{
  \item{x, y, z}{coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
}
\details{
  Adds a shape node to the scene. The appearance is defined by the material properties.
  See \code{\link{rgl.material}} for details.
}
\value{
   Each primitive function returns the integer object ID of the shape that
   was added to the scene.  These can be passed to \code{\link{rgl.pop}}
   to remove the object from the scene.
}
\examples{
rgl.open()
rgl.points(rnorm(1000), rnorm(1000), rnorm(1000), color=heat.colors(1000), size=2)
}
\seealso{
\code{\link{rgl.material}},
\code{\link{rgl.spheres}},
\code{\link{rgl.texts}},
\code{\link{rgl.surface}},
\code{\link{rgl.sprites}}
}
\keyword{dynamic}
