##
## R source file
## This file is part of rgl
##
## $Id: scene.R,v 1.10 2005/02/17 15:17:02 murdoch Exp $
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
    idata,
    PACKAGE="rgl"
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
    idata, 
    PACKAGE="rgl"
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

rgl.viewpoint <- function( theta = 0.0, phi = 15.0, fov = 60.0, zoom = 1.0, interactive = TRUE, userMatrix )
{
  zoom <- rgl.clamp(zoom,0,Inf)
  phi  <- rgl.clamp(phi,-90,90)
  fov  <- rgl.clamp(fov,1,179)

  if (missing(userMatrix)) 
    userMatrix <- rotate3d(phi*pi/180, 1, 0, 0) %*% rotate3d(-theta*pi/180, 0, 1, 0)
  idata <- as.integer(c(interactive))
  ddata <- as.numeric(c(fov,zoom,userMatrix[1:16]))

  ret <- .C( symbol.C("rgl_viewpoint"),
    success=FALSE,
    idata,
    ddata,
    PACKAGE="rgl"
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
    idata,
    PACKAGE="rgl"
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
    as.character(zlab),
    PACKAGE="rgl"
  )

  if (! ret$success)
    stop("rgl_bbox")

}

##
## set lights
##
##

rgl.light <- function( theta = 0, phi = 0, viewpoint.rel = TRUE, ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF")
{
  ambient  <- rgl.color(ambient)
  diffuse  <- rgl.color(diffuse)
  specular <- rgl.color(specular)

  idata <- as.integer(c(viewpoint.rel, ambient, diffuse, specular))
  ddata <- as.numeric(c(theta, phi))

  ret <- .C( symbol.C("rgl_light"),
    success=FALSE,
    idata,
    ddata,
    PACKAGE="rgl"
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
    PACKAGE="rgl"
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

rgl.linestrips<- function ( x, y, z, ... )
{
  rgl.primitive( "linestrips", x, y, z, ... )
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
    as.numeric(y),
    PACKAGE="rgl"
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
    as.numeric(radius),
    PACKAGE="rgl"
  )

  if (! ret$success)
    print("rgl_spheres failed")

}

##
## add texts
##

rgl.texts <- function(x, y, z, text, adj = 0.5, ... )
{
  rgl.material( ... )

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  text    <- rep(text, length.out=nvertex)

  idata <- as.integer(nvertex)

  ret <- .C( symbol.C("rgl_texts"),
    success=FALSE,
    idata,
    as.double(adj),
    as.character(text),
    as.numeric(vertex),
    PACKAGE="rgl"
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
  radius  <- rgl.attr(radius, ncenter)
  nradius <- length(radius)
 
  idata   <- as.integer( c(ncenter,nradius) )
   
  ret <- .C( symbol.C("rgl_sprites"),
    success=FALSE,
    idata,
    as.numeric(center),
    as.numeric(radius),
    PACKAGE="rgl"
  )

  if (! ret$success)
    print("rgl_sprites failed")

}

##
## convert user coordinate to window coordinate
## 

rgl.user2window <- function( x, y, z, projection = rgl.projection())
{
  
  points <- rbind(x,y,z)
  idata  <- as.integer(ncol(points))
  
  ret <- .C( symbol.C("rgl_user2window"),
  	success=FALSE,
	idata,
	as.double(points),
	window=double(length(points)),
	model=as.double(projection$model),
	proj=as.double(projection$proj),
	view=as.integer(projection$view),
	PACKAGE="rgl"
  )

  if (! ret$success)
    stop("rgl_user2window failed")
  return(matrix(ret$window, ncol(points), 3, byrow = TRUE))
}

##
## convert window coordiate to user coordiante
## 

rgl.window2user <- function( x, y, z = 0, projection = rgl.projection())
{
  
  window <- rbind(x,y,z)
  idata  <- as.integer(ncol(window))
  
  ret <- .C( symbol.C("rgl_window2user"),
  	success=FALSE,
	idata,
	point=double(length(window)),
	window,
	model=as.double(projection$model),
	proj=as.double(projection$proj),
	view=as.integer(projection$view),
	PACKAGE="rgl"
  )

  if (! ret$success)
    stop("rgl_window2user failed")
  return(matrix(ret$point, ncol(window), 3, byrow = TRUE))
}

rgl.mouseMode <- function(button = c("left", "middle", "right"),
                          handler = c("trackball", "polar", "selection", "zoom", "fov"))
{
	mode <- match.arg(handler)
	mode <- rgl.enum(mode, trackball = 1, polar = 2, selection = 3, zoom = 4, fov = 5)
	idata <- as.integer(mode)
	
	button <- match.arg(button)
	button <- rgl.enum(button, left = 1, middle = 2, right = 3);
	
	ddata <- as.integer(button)
	
	ret <- .C( symbol.C("rgl_mouseMode"), 
		    success=FALSE,
		    mode = idata,
		    ddata,
		    PACKAGE="rgl"
		)
		
		if (! ret$success)
		    stop("rgl_mouseHandlers")
	c("trackball", "polar", "selection", "zoom", "fov")[ret$mode]
}

rgl.selectstate <- function()
{
	ret <- .C( symbol.C("rgl_selectstate"),
    	success=FALSE,
    	state = as.integer(0),
    	mouseposition = double(4),
    	PACKAGE="rgl"
  	)

  	if (! ret$success)
    	stop("rgl_selectstate")
    return(ret)
}


rgl.select <- function(button = c("left", "middle", "right"))
{
	button <- match.arg(button)
	
	oldhandler <- rgl.mouseMode(button, "selection")
	
	# number 3 means the mouse selection is done. ?? how to change 3 to done
	while ((result <- rgl.selectstate())$state != 3)
		Sys.sleep(0.1)
	
	rgl.setselectstate("none")
	
	rgl.mouseMode(button, oldhandler)

	return(result$mouseposition)
}

rgl.setselectstate <- function(state = "current")
{
	state = rgl.enum(state, current=0, none = 1, middle = 2, done = 3)
	idata <- as.integer(c(state))
	
	  ret <- .C( symbol.C("rgl_setselectstate"), 
	    success=FALSE,
	    state = idata,
	    PACKAGE="rgl"
	  )
	
	  if (! ret$success)
	    stop("rgl_setselectstate")

	c("none", "middle", "done")[ret$state]
}

rgl.projection <- function()
{
    ret <- .C( symbol.C("rgl_projection"),
    	success = FALSE,
    	model = double(16),
    	proj = double(16),
    	view = integer(4),
    	PACKAGE = "rgl"
    )
    
    if (! ret$success)
	    stop("rgl_projection failed")
	    
    list(model = matrix(ret$model, 4, 4),
    	 proj = matrix(ret$proj, 4, 4),
    	 view = ret$view)
}   
     
rgl.select3d <- function() {
  rect <- rgl.select()
  llx <- rect[1]
  lly <- rect[2]
  urx <- rect[3]
  ury <- rect[4]
  
  if ( llx > urx ){
  	temp <- llx
  	llx <- urx
  	urx <- temp
  }
  if ( lly > ury ){
  	temp <- lly
  	lly <- ury
  	ury <- temp
  }
  proj <- rgl.projection();
  function(x,y,z) {
    pixel <- rgl.user2window(x,y,z,proj=proj)
    apply(pixel,1,function(p) (llx <= p[1]) && (p[1] <= urx)
                           && (lly <= p[2]) && (p[2] <= ury)
                           && (0 <= p[3])   && (p[3] <= 1))
  }
}

