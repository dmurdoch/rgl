\name{rgl.primitive}
\alias{rgl.primitive}
\alias{rgl.points}
\alias{rgl.lines}
\alias{rgl.triangles}
\alias{rgl.quads}
\title{add primitive set shape}
\description{
  Adds a shape node to the current scene
}
\usage{
rgl.points(x, y, z, ... )
rgl.lines(x, y, z, ... )
rgl.triangles(x, y, z, ... )
rgl.quads(x, y, z, ... )
}
\arguments{
  \item{x, y, z}{coordinates}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
}
\details{
  Adds a shape node to the scene. The appearance is defined by the material properties.
  See \code{\link{rgl.material}} for details.
}
\examples{
rgl.clear()
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
