##
## R source file
## This file is part of rgl
##
## $Id: scene.R,v 1.2 2003/05/27 14:03:27 dadler Exp $
##

##
## ===[ SECTION: scene management ]===========================================
##


##
## clear scene
##
##

rgl.clear <- function( type = "shapes" )
{
  type <- rgl.enum.nodetype(type)

  idata <- as.integer(c(type))

  ret <- .C( symbol.C("rgl_clear"), 
    success=FALSE,
    idata
  )

  if (! ret$success)
    stop("rgl_clear")
}


##
## pop node
##
##

rgl.pop <- function( type = "shapes" )
{
  type <- rgl.enum.nodetype(type)

  idata <- as.integer(c(type))

  ret <- .C( symbol.C("rgl_pop"),
    success = FALSE,
    idata
  )

  if (! ret$success)
    warning("stack is empty")
}

##
## ===[ SECTION: environment ]================================================
##



##
## set viewpoint
##
##

rgl.viewpoint <- function( theta = 0.0, phi = 15.0, fov = 60.0, zoom = 0.0, interactive = TRUE )
{
  zoom <- rgl.clamp(zoom,0,1)
  phi  <- rgl.clamp(phi,-90,90)
  fov  <- rgl.clamp(fov,0,180)

  idata <- as.integer(c(interactive))
  ddata <- as.numeric(c(theta,phi,fov,zoom))

  ret <- .C( symbol.C("rgl_viewpoint"),
    success=FALSE,
    idata,
    ddata
  )

  if (! ret$success)
    stop("rgl_viewpoint")
}


##
## set background
##
##

rgl.bg <- function(sphere=FALSE, fogtype="none", color=c("black","white"), back="lines", ... )
{
  rgl.material( color=color, back=back, ... )

  fogtype <- rgl.enum.fogtype(fogtype)

  idata   <- as.integer(c(sphere,fogtype))

  ret <- .C( symbol.C("rgl_bg"), 
    success=FALSE,
    idata
  )

  if (! ret$success)
    stop("rgl_bg")
}


##
## bbox
##
##

rgl.bbox <- function( 
  xat=NULL, xlab=NULL, xunit=0, xlen=5,
  yat=NULL, ylab=NULL, yunit=0, ylen=5,
  zat=NULL, zlab=NULL, zunit=0, zlen=5,
  marklen=15.0, marklen.rel=TRUE, ...) {

  rgl.material( ... )

  if (is.null(xat)) {
    xticks = 0; xlab = NULL;
  } else if (is.null(xlab)) {
    xlab = as.character(xat)
  }
  if (is.null(yat)) {
    yticks = 0; ylab = NULL;
  } else if (is.null(ylab)) {
    ylab = as.character(yat)
  }
  if (is.null(zat)) {
    zticks = 0; zlab = NULL;
  } else if (is.null(zlab)) {
    zlab = as.character(zat)
  }

  xticks <- length(xat)
  yticks <- length(yat)
  zticks <- length(zat)

  length(xticks)      <- 1
  length(yticks)      <- 1
  length(zticks)      <- 1
  length(xlen)        <- 1
  length(ylen)        <- 1
  length(zlen)        <- 1
  length(marklen.rel) <- 1
  length(xunit)       <- 1
  length(yunit)       <- 1
  length(zunit)       <- 1

  idata <- as.integer(c(xticks,yticks,zticks, xlen, ylen, zlen, marklen.rel))
  ddata <- as.numeric(c(xunit, yunit, zunit, marklen))

  ret <- .C( symbol.C("rgl_bbox"),
    success=FALSE,
    idata,
    ddata,
    as.numeric(xat),
    as.character(xlab),
    as.numeric(yat),
    as.character(ylab),
    as.numeric(zat),
    as.character(zlab)
  )

  if (! ret$success)
    stop("rgl_bbox")

}

##
## set lights
##
##

rgl.light <- function( theta = 0, phi = 0, viewpoint.rel = FALSE, ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF")
{
  ambient  <- rgl.color(ambient)
  diffuse  <- rgl.color(diffuse)
  specular <- rgl.color(specular)

  idata <- as.integer(c(viewpoint.rel, ambient, diffuse, specular))
  ddata <- as.numeric(c(theta, phi))

  ret <- .C( symbol.C("rgl_light"),
    success=FALSE,
    idata,
    ddata
  )

  if (! ret$success)
    stop("too many lights. maximum is 8 sources per scene.");
}

##
## ===[ SECTION: shapes ]=====================================================
##

##
## add primitive
##
##

rgl.primitive <- function( type, x, y, z, ... )
{
  rgl.material( ... )

  type <- rgl.enum.primtype(type)

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  idata   <- as.integer( c(type, nvertex ) )

  ret <- .C( symbol.C("rgl_primitive"),
    success=FALSE,
    idata,
    as.numeric(vertex),
  );

  if (! ret$success)
    stop("rgl_points")
}

rgl.points <- function ( x, y, z, ... )
{
  rgl.primitive( "points", x, y, z, ... )
}

rgl.lines <- function (x, y, z, ... )
{
  rgl.primitive( "lines", x, y, z, ... )
}

rgl.triangles <- function (x, y, z, ... )
{
  rgl.primitive( "triangles", x, y, z, ... )
}

rgl.quads <- function ( x, y, z, ... )
{
  rgl.primitive( "quadrangles", x, y, z, ... )
}

##
## add surface
##
##

rgl.surface <- function( x, z, y, ... )
{
  rgl.material(...)

  nx <- length(x)
  nz <- length(z)
  ny <- length(y)

  if ( nx*nz != ny)
    stop("y length != x length * z length")

  if ( nx < 2 )
    stop("x length < 2")
  
  if ( nz < 2 )   
    stop("y length < 2")

  idata <- as.integer( c( nx, nz ) )

  ret <- .C( symbol.C("rgl_surface"),
    success=FALSE,
    idata,
    as.numeric(x),
    as.numeric(z),
    as.numeric(y)
  );

  if (! ret$success)
    print("rgl_surface failed")
}

##
## add spheres
##

rgl.spheres <- function( x, y, z,radius=1.0,...)
{
  rgl.material(...)

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  radius  <- rgl.attr(radius, nvertex)
  nradius <- length(radius)
 
  idata <- as.integer( c( nvertex, nradius ) )
   
  ret <- .C( symbol.C("rgl_spheres"),
    success=FALSE,
    idata,
    as.numeric(vertex),    
    as.numeric(radius)
  )

  if (! ret$success)
    print("rgl_spheres failed")

}

##
## add texts
##

rgl.texts <- function(x, y, z, text, justify="center", ... )
{
  rgl.material( ... )

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  text    <- rep(text, length.out=nvertex)

  justify <- rgl.enum.halign( justify );

  idata <- as.integer( c(nvertex, justify) )

  ret <- .C( symbol.C("rgl_texts"),
    success=FALSE,
    idata,
    as.character(text),
    as.numeric(vertex)
  )
  
  if (! ret$success)
    print("rgl_texts failed")

}

##
## add sprites
##

rgl.sprites <- function( x, y, z, radius=1.0, ... )
{
  rgl.material(...)

  center  <- rgl.vertex(x,y,z)
  ncenter <- rgl.nvertex(center)
  radius  <- rgl.attr(center, radius)
  nradius <- length(radius)
 
  idata   <- as.integer( c(ncenter,nradius) )
   
  ret <- .C( symbol.C("rgl_sprites"),
    success=FALSE,
    idata,
    as.numeric(center),
    as.numeric(radius)
  );

  if (! ret$success)
    print("rgl_sprites failed")

}
