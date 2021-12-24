\name{light}
\alias{rgl.light}
\alias{light3d}
\title{Add light source}
\description{
  add a light source to the scene.
}
\usage{
light3d(theta = 0, phi = 15, x = NULL, ...)
rgl.light( theta = 0, phi = 0, viewpoint.rel = TRUE, ambient = "#FFFFFF", 
           diffuse = "#FFFFFF", specular = "#FFFFFF", x = NULL, y = NULL, z = NULL)
}
\arguments{
  \item{theta, phi}{polar coordinates, used by default}
  \item{viewpoint.rel}{logical, if TRUE light is a viewpoint light that is positioned relative to the current viewpoint}
  \item{ambient, diffuse, specular }{ light color values used for lighting calculation }
  \item{x, y, z}{cartesian coordinates, optional}
  \item{...}{generic arguments passed through to RGL-specific (or other) functions}
}
\details{
  Up to 8 light sources are supported. They are positioned either in
  world space or relative to the camera. By providing polar
  coordinates to theta and phi a directional light source is used. If
  numerical values are given to x, y and z, a point-like light source with
  finite distance to the objects in the scene is set up.
  
  If \code{x} is non-null, \code{\link{xyz.coords}} will
  be used to form the location values, so all three coordinates
  can be specified in \code{x}.
  
  If no lights have been added to a subscene, lights from the parent
  subscene will be used.
  
See \code{\link{material3d}} for a discussion of how
the components of the light affect the display of objects.
}
\value{
  This function is called for the side effect of adding a light.  A light ID is
  returned to allow \code{\link{pop3d}} to remove it.
}
\seealso{
  \code{\link{rgl.clear}}
  \code{\link{pop3d}}
}
\examples{

#
# a lightsource moving through the scene
#
data(volcano)
z <- 2 * volcano # Exaggerate the relief
x <- 10 * (1:nrow(z)) # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z)) # 10 meter spacing (E to W)
zlim <- range(z)
zlen <- zlim[2] - zlim[1] + 1
colorlut <- terrain.colors(zlen) # height color lookup table
col <- colorlut[ z - zlim[1] + 1 ] # assign colors to heights for each point

open3d()
bg3d("gray50")
surface3d(x, y, z, color = col, back = "lines")
r <- max(y) - mean(y)
lightid <- spheres3d(1, 1, 1, alpha = 0)
frame <- function(time) {
    a <- pi*(time - 1)
    save <- par3d(skipRedraw = TRUE)
    clear3d(type = "lights")
    pop3d(id = lightid)
    xyz <- matrix(c(r*sin(a) + mean(x), r*cos(a) + mean(y), max(z)), ncol = 3)
    light3d(x = xyz, diffuse = "gray75", 
            specular = "gray75", viewpoint.rel = FALSE) 
    light3d(diffuse = "gray10", specular = "gray25")
    lightid <<- spheres3d(xyz, emission = "white", radius = 4)
    par3d(save)
    Sys.sleep(0.02)
    NULL
}
play3d(frame, duration = 2)
}
\keyword{dynamic}
