##
## R source file
## This file is part of rgl
##
## $Id$
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

  idata <- as.integer(c(length(type), type))

  ret <- .C( "rgl_clear", 
    success=FALSE,
    idata,
    PACKAGE="rgl"
  )
  
  if ( 4 %in% type ) # viewpoint
    rgl.viewpoint()

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

  ret <- .C( "rgl_pop",
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

rgl.viewpoint <- function( theta = 0.0, phi = 15.0, fov = 60.0, zoom = 1.0, scale = par3d("scale"),
                           interactive = TRUE, userMatrix )
{
  zoom <- rgl.clamp(zoom,0,Inf)
  phi  <- rgl.clamp(phi,-90,90)
  fov  <- rgl.clamp(fov,1,179)

  polar <- missing(userMatrix)
  if (polar) userMatrix <- diag(4)
  
  idata <- as.integer(c(interactive,polar))
  ddata <- as.numeric(c(theta,phi,fov,zoom,scale,userMatrix[1:16]))

  ret <- .C( "rgl_viewpoint",
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

  ret <- .C( "rgl_bg", 
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
  marklen=15.0, marklen.rel=TRUE, expand=1, ...) {

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
  length(marklen)     <- 1
  length(expand)      <- 1

  idata <- as.integer(c(xticks,yticks,zticks, xlen, ylen, zlen, marklen.rel))
  ddata <- as.numeric(c(xunit, yunit, zunit, marklen, expand))

  ret <- .C( "rgl_bbox",
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

  ret <- .C( "rgl_light",
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

rgl.primitive <- function( type, x, y=NULL, z=NULL, ... )
{
  rgl.material( ... )

  type <- rgl.enum.primtype(type)
  
  xyz <- xyz.coords(x,y,z,recycle=TRUE)
  x <- xyz$x
  y <- xyz$y
  z <- xyz$z

  if (any(is.na(c(x,y,z)))) {
    d <- complete.cases(cbind(x,y,z))
    x <- x[d]
    y <- y[d]
    z <- z[d]
    warning("NA/NaN values ignored")
  }
  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  idata   <- as.integer( c(type, nvertex ) )

  ret <- .C( "rgl_primitive",
    success=FALSE,
    idata,
    as.numeric(vertex),
    PACKAGE="rgl"
  );

  if (! ret$success)
    stop("rgl_points")
}

rgl.points <- function ( x, y=NULL, z=NULL, ... )
{
  rgl.primitive( "points", x, y, z, ... )
}

rgl.lines <- function (x, y=NULL, z=NULL, ... )
{
  rgl.primitive( "lines", x, y, z, ... )
}

rgl.triangles <- function (x, y=NULL, z=NULL, ... )
{
  rgl.primitive( "triangles", x, y, z, ... )
}

rgl.quads <- function ( x, y=NULL, z=NULL, ... )
{
  rgl.primitive( "quadrangles", x, y, z, ... )
}

rgl.linestrips<- function ( x, y=NULL, z=NULL, ... )
{
  rgl.primitive( "linestrips", x, y, z, ... )
}

##
## add surface
##
##

# Utility function:
# calculates the parity of a permutation of integers

perm_parity <- function(p) {  
  x <- seq(along=p)
  result <- 0
  for (i in seq(along=p)) {
    if (x[i] != p[i]) {
      x[x==p[i]] <- x[i]
      # x[i] <- p[i]     # not needed
      result <- result+1
    }
  }
  return(result %% 2)
}

rgl.surface <- function( x, z, y, coords=1:3, ... )
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
    
  if ( length(coords) != 3 || !identical(all.equal(sort(coords), 1:3), TRUE) )
    stop("coords must be a permutation of 1:3")

  idata <- as.integer( c( nx, nz ) )

  parity <- (perm_parity(coords) + (x[2] < x[1]) + (z[2] < z[1]) ) %% 2
  
  ret <- .C( "rgl_surface",
    success=FALSE,
    idata,
    as.numeric(x),
    as.numeric(z),
    as.numeric(y),
    as.integer(coords),
    as.integer(parity),
    PACKAGE="rgl"
  );

  if (! ret$success)
    print("rgl_surface failed")
}

##
## add spheres
##

rgl.spheres <- function( x, y=NULL, z=NULL, radius=1.0,...)
{
  rgl.material(...)

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  radius  <- rgl.attr(radius, nvertex)
  nradius <- length(radius)
 
  idata <- as.integer( c( nvertex, nradius ) )
   
  ret <- .C( "rgl_spheres",
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

rgl.texts <- function(x, y=NULL, z=NULL, text, adj = 0.5, justify, ... )
{
  rgl.material( ... )

  if (!missing(justify)) {
     warning("justify is deprecated: please use adj instead")
     if (!missing(adj)) {
        warning("adj and justify both specified: justify ignored")
     } else adj <- switch(justify,left=0,center=0.5,right=1)
  }
  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  text    <- rep(text, length.out=nvertex)

  idata <- as.integer(nvertex)

  ret <- .C( "rgl_texts",
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

rgl.sprites <- function( x, y=NULL, z=NULL, radius=1.0, ... )
{
  rgl.material(...)

  center  <- rgl.vertex(x,y,z)
  ncenter <- rgl.nvertex(center)
  radius  <- rgl.attr(radius, ncenter)
  nradius <- length(radius)
 
  idata   <- as.integer( c(ncenter,nradius) )
   
  ret <- .C( "rgl_sprites",
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

rgl.user2window <- function( x, y=NULL, z=NULL, projection = rgl.projection())
{
  xyz <- xyz.coords(x,y,z,recycle=TRUE)
  points <- rbind(xyz$x,xyz$y,xyz$z)
  
  idata  <- as.integer(ncol(points))
  
  ret <- .C( "rgl_user2window",
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
## convert window coordinate to user coordiante
## 

rgl.window2user <- function( x, y = NULL, z = 0, projection = rgl.projection())
{
  xyz <- xyz.coords(x,y,z,recycle=TRUE)
  window <- rbind(xyz$x,xyz$y,xyz$z)
  idata  <- as.integer(ncol(window))
  
  ret <- .C( "rgl_window2user",
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


rgl.selectstate <- function()
{
	ret <- .C( "rgl_selectstate",
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
	
	newhandler <- par3d("mouseMode")
	newhandler[button] <- "selecting"
	oldhandler <- par3d(mouseMode = newhandler)
	on.exit(par3d(mouseMode = oldhandler))
	
	# number 3 means the mouse selection is done. ?? how to change 3 to done
	while ((result <- rgl.selectstate())$state != 3)
		Sys.sleep(0.1)
	
	rgl.setselectstate("none")
	
	return(result$mouseposition)
}

rgl.setselectstate <- function(state = "current")
{
	state = rgl.enum(state, current=0, none = 1, middle = 2, done = 3)
	idata <- as.integer(c(state))
	
	  ret <- .C( "rgl_setselectstate", 
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
    list(model = par3d("modelMatrix"),
    	 proj = par3d("projMatrix"),
    	 view = par3d("viewport"))
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
  function(x,y=NULL,z=NULL) {
    pixel <- rgl.user2window(x,y,z,proj=proj)
    apply(pixel,1,function(p) (llx <= p[1]) && (p[1] <= urx)
                           && (lly <= p[2]) && (p[2] <= ury)
                           && (0 <= p[3])   && (p[3] <= 1))
  }
}

