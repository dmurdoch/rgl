\name{rgl.light}
\alias{rgl.light}
\title{add light source}
\description{
  rgl.light adds a light source to the scene.
}
\usage{
rgl.light( theta = 0, phi = 0, viewpoint.rel = TRUE, ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF")
}
\arguments{
  \item{theta, phi}{polar coordinates}
  \item{viewpoint.rel}{logical, if true light is a viewpoint light that is positioned relative to the actual viewpoint position}
  \item{ambient, diffuse, specular } { light color values used for lighting calculation }
}
\details{
  Up to 8 light sources are supported. They are positioned either in world space
  or relative to the camera using polar coordinates. Light sources are directional.
}
\seealso{
  \code{\link{rgl.clear}}
  \code{\link{rgl.pop}}
}
\keyword{dynamic}
