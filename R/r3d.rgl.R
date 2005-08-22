#
# R3D rendering functions - rgl implementation
# $Id$
# 

# Node Management

clear3d     <- function(type = "shapes") {
    .check3d()
    rgl.clear( type )
    if ( 4 %in% rgl.enum.nodetype(type) ) { # viewpoint
	do.call("par3d", get("r3dDefaults", envir=.GlobalEnv)[c("FOV", "userMatrix")])
    }
}

pop3d       <- function(...) {.check3d(); rgl.pop(...)}

# Environment

bg3d        <- function(color, ...) {.check3d(); rgl.bg(color=color, ...)}
light3d     <- function(theta=0,phi=15,...) {.check3d(); rgl.light(theta=theta,phi=phi,...)}
view3d      <- function(theta=0,phi=15,...) {.check3d(); rgl.viewpoint(theta=theta,phi=phi,...)}
bbox3d	    <- function(...) {.check3d(); rgl.bbox(...)}

# Shapes

points3d    <- function(x,y,z,...) {.check3d(); rgl.points(x=x,y=y,z=z,...)}
lines3d     <- function(x,y,z,...) {.check3d(); rgl.linestrips(x=x,y=y,z=z,...)}
segments3d  <- function(x,y,z,...) {.check3d(); rgl.lines(x=x,y=y,z=z,...)}
triangles3d <- function(x,y,z,...) {.check3d(); rgl.triangles(x=x,y=y,z=z,...)}
quads3d     <- function(x,y,z,...) {.check3d(); rgl.quads(x=x,y=y,z=z,...)}
text3d      <- function(x,y,z,texts,adj=0.5,justify,...) {.check3d(); rgl.texts(x=x,y=y,z=z,text=texts,adj,justify,...)}
texts3d	    <- text3d
spheres3d   <- function(x,y,z,radius=1,...) {.check3d(); rgl.spheres(x=x,y=y,z=z,radius=radius,...)}
sprites3d   <- function(x,y,z,radius=1,...) {.check3d(); rgl.sprites(x=x,y=y,z=z,radius=radius,...)}
terrain3d   <- function(x,y,z,...) {.check3d(); rgl.surface(x=x,y=z,z=y,coords=c(1,3,2),...)}
surface3d   <- terrain3d

# Interaction

select3d    <- function() {.check3d(); rgl.select3d()}

# 3D Generic Object Rendering Attributes

dot3d <- function(x,...) UseMethod("dot3d")
wire3d  <- function(x,...) UseMethod("wire3d")
shade3d <- function(x,...) UseMethod("shade3d")

# 3D Generic transformation


translate3d <- function(obj,x,y,z,...) UseMethod("translate3d")
scale3d <- function(obj,x,y,z,...) UseMethod("scale3d")
rotate3d <- function(obj,angle,x,y,z,matrix,...) UseMethod("rotate3d")
transform3d <- function(obj,matrix,...) rotate3d(obj, matrix=matrix, ...)

subdivision3d <- function(x,...) UseMethod("subdivision3d")

# 3D Custom shapes

particles3d <- function(x,y,z,radius=1,...) sprites3d(
  x=x,y=y,z=z,radius=radius,
  lit=FALSE,alpha=0.2,
  textype="alpha",
  texture=system.file("textures/particle.png",package="rgl"),
  ...
)   

# r3d default settings for new windows

r3dDefaults <- list(userMatrix = rotationMatrix(5, 1, 0, 0),
		  mouseMode = c("trackball", "zoom", "fov"),
		  FOV = 30)

open3d <- function(..., params = get("r3dDefaults", envir=.GlobalEnv))
{
    rgl.open()
    params[names(list(...))] <- list(...)
    do.call("par3d", params)   
    return(rgl.cur())
}

.check3d <- function() {
    if (result<-rgl.cur()) return(result)
    else return(open3d())
}