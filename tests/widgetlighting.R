library(rgl)

## a function to plot good-looking spheres

sphere1.f <- function(x0 = 0, y0 = 0, z0 = 0, r = 1, n = 101, ...){
  f <- function(s,t){ 
    cbind(   r * cos(t)*cos(s) + x0,
             r *        sin(s) + y0,
             r * sin(t)*cos(s) + z0)
  }
  
  persp3d(f, slim = c(-pi/2,pi/2), tlim = c(0, 2*pi), n = n, add = T,  ...)
}

## a set of 3D coordinates for my spheres

agg <- as.data.frame(list(x = c(-0.308421860438279, -1.42503395393061), y = c(0.183223776337368, 1.69719822686475), z = c(-0.712687792799106, -0.0336746884947792)))

open3d()

##material and light effects for the spheres

clear3d(type = "lights")
light3d(theta = -30, phi = 60, viewpoint.rel = TRUE, ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF", x = NULL, y = NULL, z = NULL)

## plot the spheres.
sphere <- sphere1.f(r=0.5)
sprites <- sprites3d(agg, radius = 0.5, shapes = sphere,
          rotating = TRUE)

rglwidget()