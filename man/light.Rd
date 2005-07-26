\name{light}
\alias{rgl.light}
\alias{light3d}
\title{add light source}
\description{
  add a light source to the scene.
}
\usage{
light3d(theta = 0, phi = 0, ...)
rgl.light( theta = 0, phi = 0, viewpoint.rel = TRUE, ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF")
}
\arguments{
  \item{theta, phi}{polar coordinates}
  \item{viewpoint.rel}{logical, if TRUE light is a viewpoint light that is positioned relative to the current viewpoint}
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
