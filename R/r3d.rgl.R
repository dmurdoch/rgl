#
# R3D rendering functions - rgl implementation
# $Id$
# 

# Node Management

clear3d     <- function(type = c("shapes", "bboxdeco")) {
    .check3d()
    rgl.clear( type )
    if ( 4 %in% rgl.enum.nodetype(type) ) { # viewpoint
	do.call("par3d", get("r3dDefaults", envir=.GlobalEnv)[c("FOV", "userMatrix")])
    }
}

pop3d       <- function(...) {.check3d(); rgl.pop(...)}

# Environment

.material3d <- c("color", "alpha", "lit", "ambient", "specular",
    "emission", "shininess", "smooth", "front", "back", "size", "fog")
    
.material3d.writeOnly <- c("texture", "textype", "texmipmap",
    "texminfilter", "texmagfilter", "texenvmap")

.fixMaterialArgs <- function(..., Params = material3d()) {
   f <- function(...) list(...)
   formals(f) <- c(Params, formals(f))
   names <- as.list(names(Params))
   names(names) <- names
   names <- lapply(names, as.name)
   b <- as.list(body(f))
   body(f) <- as.call(c(b[1], names, b[-1]))
   f(...)
} 
     
     
material3d  <- function (...)
{
    args <- list(...)
    argnames <- names(args)
    
    if (!length(args))
	argnames <- .material3d
    else {
	if (is.null(names(args)) && all(unlist(lapply(args, is.character)))) {
	    argnames <- unlist(args)
	    args <- NULL
	}
	
	if (length(args) == 1) {
	    if (is.list(args[[1]]) | is.null(args[[1]])) {
		args <- args[[1]]
		argnames <- names(args)
	    }
	}
    }
    value <- rgl.getmaterial()[argnames]
    if (length(args)) {
        do.call("rgl.material", args)
        return(invisible(value))
    } else if (length(argnames) == 1) return(value[[1]])
    else return(value)
}

bg3d        <- function(...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  new <- .fixMaterialArgs(sphere = FALSE, fogtype = "none", 
                          color = c("black", "white"), back = "lines", Params = save)
  do.call("rgl.bg", .fixMaterialArgs(..., Params = new))
}

light3d     <- function(theta=0,phi=15,...) {
  .check3d()
  rgl.light(theta=theta,phi=phi,...)
}

view3d      <- function(theta=0,phi=15,...) {
  .check3d()
  rgl.viewpoint(theta=theta,phi=phi,...)
}

bbox3d	    <- function(xat = pretty(xrange), yat = pretty(yrange), zat = pretty(zrange), 
		        expand = 1.03, ...) {  
  .check3d(); save <- material3d(); on.exit(material3d(save))
  ranges <- par3d("bbox")
  xrange <- ranges[1:2]
  yrange <- ranges[3:4]
  zrange <- ranges[5:6]
  do.call("rgl.bbox", c(list(xat=xat, yat=yat, zat=zat, expand=expand), 
                        .fixMaterialArgs(..., Params = save)))
}

# Shapes

points3d    <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.points", c(list(x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

lines3d     <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.linestrips", c(list(x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

segments3d  <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.lines", c(list(x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

triangles3d <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.triangles", c(list(x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

quads3d     <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.quads", c(list(x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

text3d      <- function(x,y=NULL,z=NULL,texts,adj=0.5,justify,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  new <- .fixMaterialArgs(..., Params = save)
  if (!missing(justify)) new <- c(list(justify=justify), new)
  do.call("rgl.texts", c(list(x=x,y=y,z=z,text=texts,adj),new))
}
texts3d	    <- text3d

spheres3d   <- function(x,y=NULL,z=NULL,radius=1,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.spheres", c(list(x=x,y=y,z=z,radius=radius), .fixMaterialArgs(..., Params = save)))
}

sprites3d   <- function(x,y=NULL,z=NULL,radius=1,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.sprites", c(list(x=x,y=y,z=z,radius=radius), .fixMaterialArgs(..., Params = save)))
}

terrain3d   <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.surface", c(list(x=x,y=z,z=y,coords=c(1,3,2)), .fixMaterialArgs(..., Params = save)))
}
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

particles3d <- function(x,y=NULL,z=NULL,radius=1,...) sprites3d(
  x=x,y=y,z=z,radius=radius,
  lit=FALSE,alpha=0.2,
  textype="alpha",
  texture=system.file("textures/particle.png",package="rgl"),
  ...
)   

# r3d default settings for new windows

r3dDefaults <- list(userMatrix = rotationMatrix(5, 1, 0, 0),
		  mouseMode = c("trackball", "zoom", "fov"),
		  FOV = 30,
		  bg = list(color="black"),
		  material = list(color="white", fog=FALSE))

open3d <- function(..., params = get("r3dDefaults", envir=.GlobalEnv))
{
    rgl.open()
    params <- .fixMaterialArgs(..., Params = params)
    if (!is.null(params$bg)) {
      do.call("bg3d", params$bg)
      params$bg <- NULL
    }
    if (!is.null(params$material)) {
      do.call("material3d", params$material)
      params$material <- NULL
    }
    do.call("par3d", params)   
    return(rgl.cur())
}

.check3d <- function() {
    if (result<-rgl.cur()) return(result)
    else return(open3d())
}