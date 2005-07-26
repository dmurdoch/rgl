#
# R3D rendering functions - rgl implementation
# $Id$
# 

# Node Management

clear3d     <- function(...) rgl.clear(...)
pop3d       <- function(...) rgl.pop(...)

# Environment

bg3d        <- function(color, ...) rgl.bg(color=color, ...)
light3d     <- function(theta=0,phi=15,...) rgl.light(theta=theta,phi=phi,...)
view3d      <- function(theta,phi,...) rgl.viewpoint(theta=theta,phi=phi)

# Shapes

points3d    <- function(x,y,z,...) rgl.points(x=x,y=y,z=z,...)
lines3d     <- function(x,y,z,...) rgl.linestrips(x=x,y=y,z=z,...)
segments3d  <- function(x,y,z,...) rgl.lines(x=x,y=y,z=z,...)
triangles3d <- function(x,y,z,...) rgl.triangles(x=x,y=y,z=z,...)
quads3d     <- function(x,y,z,...) rgl.quads(x=x,y=y,z=z,...)
text3d      <- function(x,y,z,texts,adj=0.5,justify,...) rgl.texts(x=x,y=y,z=z,text=texts,adj,justify,...)
spheres3d   <- function(x,y,z,radius=1,...) rgl.spheres(x=x,y=y,z=z,radius=radius,...)
sprites3d   <- function(x,y,z,radius=1,...) rgl.sprites(x=x,y=y,z=z,radius=radius,...)
terrain3d   <- function(x,y,z,...) rgl.surface(x=x,y=y,z=z,...)

# Interaction

select3d    <- function() rgl.select3d()

# 3D Generic Object Rendering Attributes

dot3d <- function(x,...) UseMethod("dot3d")
wire3d  <- function(x,...) UseMethod("wire3d")
shade3d <- function(x,...) UseMethod("shade3d")

# 3D Generic transformation

transform3d <- function(x,transform,...) UseMethod("transform3d")
translate3d <- function(x,tx,ty,tz,...) UseMethod("translate3d")
subdivision3d <- function(x,...) UseMethod("subdivision3d")

# 3D Custom shapes

particles3d <- function(x,y,z,radius=1,...) sprites3d(
  x=x,y=y,z=z,radius=radius,
  lit=FALSE,alpha=0.2,
  textype="alpha",
  texture=system.file("textures/particle.png",package="rgl"),
  ...
)    

