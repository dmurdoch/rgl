##
## R source file
## This file is part of rgl
##
##

##
## ===[ SECTION: scene management ]===========================================
##


##
## clear scene
##
##

rgl.clear <- function( type = "shapes", subscene = 0 )  {
  if (is.na(subscene)) 
    subscene <- currentSubscene3d()

  typeid <- rgl.enum.nodetype(type)
  
  userviewpoint <- 4 %in% typeid
  material  <- 5 %in% typeid
  modelviewpoint <- 8 %in% typeid

  drop <- typeid %in% c(4:5, 8)
  typeid <- typeid[!drop]
  type <- names(typeid)
  
  if (subscene == 0) {
    idata <- as.integer(c(length(typeid), typeid))    	
    ret <- .C( rgl_clear, 
      success = FALSE,
      idata
    )$success
  } else {
    sceneids <- ids3d(type=type, subscene = 0)$id
    thisids <- ids3d(type=type, subscene = subscene)$id
    if (length(thisids)) {
      delFromSubscene3d(ids = thisids, subscene = subscene)
      gc3d(protect = setdiff(sceneids, thisids))
    }
    ret <- 1
  }
  
  if ( userviewpoint || modelviewpoint) 
    rgl.viewpoint(type = c("userviewpoint", "modelviewpoint")[c(userviewpoint, modelviewpoint)])
    
  if ( material ) 
    rgl.material()
  
  if (! ret)
    stop("'rgl_clear' failed")
  
  lowlevel()
}


##
## pop node
##
##

pop3d <- rgl.pop <- function( type = "shapes", id = 0) {
  type <- rgl.enum.nodetype(type)
  save <- par3d(skipRedraw = TRUE)
  on.exit(par3d(save))
  for (i in id) {
    idata <- as.integer(c(type, i))

    ret <- .C( rgl_pop,
      success = FALSE,
      idata
    )

    if (! ret$success)
      stop(gettextf("'rgl.pop' failed for id %d", i), domain = NA)
  }
  lowlevel()
}

ids3d <- rgl.ids <- function( type = "shapes", subscene = NA ) {
  type <- c(rgl.enum.nodetype(type), 0)
  if (is.na(subscene)) 
      subscene <- currentSubscene3d()
  
  count <- .C( rgl_id_count, as.integer(type), count = integer(1), subscene = as.integer(subscene))$count
  
  as.data.frame( .C( rgl_ids, as.integer(type), id=integer(count), 
                                type=rep("",count), subscene = as.integer(subscene) )[2:3] )
}

rgl.attrib.count <- function( id, attrib ) {
  stopifnot(length(attrib) == 1)
  if (is.character(attrib))
    attrib <- rgl.enum.attribtype(attrib)
  
  result <- integer(length(id))
  for (i in seq_along(id))
    result[i] <- .C( rgl_attrib_count, as.integer(id[i]), as.integer(attrib), 
                     count = integer(1))$count
  names(result) <- names(id)
  result
}

rgl.attrib.ncol.values <- c(vertices=3, normals=3, colors=4, texcoords=2, dim=2,
            texts=1, cex=1, adj=3, radii=1, centers=3, ids=1,
	    usermatrix=4, types=1, flags=1, offsets=1,
	    family=1, font=1, pos=1, fogscale=1, axes=3)

rgl.attrib.info <- function( id = ids3d("all", 0)$id, attribs = NULL, showAll = FALSE) {
  ncol <- rgl.attrib.ncol.values
  if (is.null(attribs))
    attribs <- names(ncol)
  else if (is.numeric(attribs))
    attribs <- names(ncol)[attribs]
  na <- length(attribs)
  ni <- length(id)
  if (!ni) 
    result <- data.frame(id = numeric(0), attrib = character(0),
    		         nrow = numeric(0), ncol = numeric(0),
    		         stringsAsFactors = FALSE)
  else
    result <- data.frame(id = rep(id, each = na),
    		         attrib = rep(attribs, ni),
  		         nrow = 0, 
  		         ncol = rep(ncol[attribs], ni),
		         stringsAsFactors = FALSE)
  for (j in seq_len(ni)) 
    for (i in seq_len(na))
      result$nrow[i + na*(j - 1)] <- rgl.attrib.count(id[j], result$attrib[i])
  if (!showAll)
    result <- result[result$nrow != 0,]
  rownames(result) <- NULL
  result
}	

rgl.attrib <- function( id, attrib, first=1, 
                        last=rgl.attrib.count(id, attrib) ) {
  stopifnot(length(attrib) == 1 && length(id) == 1 && length(first) == 1)
  if (is.character(attrib))
    attrib <- rgl.enum.attribtype(attrib)
  ncol <- rgl.attrib.ncol.values[attrib]
  count <- max(last - first + 1, 0)
  if (attrib %in% c(6, 13, 16)) { # texts, types and family
    if (count)
      result <- .C(rgl_text_attrib, as.integer(id), as.integer(attrib), 
                    as.integer(first-1), as.integer(count), 
                result = character(count*ncol))$result
    else
      result <- character(0)
  } else {
    if (count)
      result <- .C(rgl_attrib, as.integer(id), as.integer(attrib), 
                  as.integer(first-1), as.integer(count), 
                  result = numeric(count*ncol))$result
    else
      result <- numeric(0)
  }
  if (attrib == 14) # flags
    result <- as.logical(result)
  result <- matrix(result, ncol=ncol, byrow=TRUE)
  colnames(result) <- list(c("x", "y", "z"), # vertices
                           c("x", "y", "z"), # normals
                           c("r", "g", "b", "a"), # colors
                           c("s", "t"),	     # texcoords
                           c("r", "c"),      # dim
                           "text",	         # texts
                           "cex", 	         # cex
                           c("x", "y", "z"), # adj
                           "r",		     # radii
                           c("x", "y", "z"), # centers
                           "id",	     # ids
                           c("x", "y", "z", "w"), # usermatrix
                           "type",	     # types
                           "flag",	     # flags
			   "offset",         # offsets
  			   "family",         # family
  			   "font",           # font
			   "pos",            # pos
			   "fogscale",        # fogscale
			   c("x", "y", "z")   # axes
                           )[[attrib]]
  if (attrib == 14 && count) # flags
    if (id %in% ids3d("lights", subscene = 0)$id)
      rownames(result) <- c("viewpoint", "finite")[first:last]
    else if (id %in% ids3d("background", subscene = 0)$id)
      rownames(result) <- c("sphere", "linear_fog", "exp_fog", "exp2_fog")[first:last]
    else if (id %in% ids3d("bboxdeco", subscene = 0)$id)
      rownames(result) <- c("draw_front", "marklen_rel")[first:last]
    else if (id %in% (ids <- ids3d("shapes", subscene = 0))$id) {
      type <- ids$type[ids$id == id]
      rownames(result) <- c("ignoreExtent", 
                            if (type == "surface") "flipped"
                            else if (type == "spheres") "fastTransparency"
                            else "fixedSize")[first:last]
    }
  if (attrib == 20 && count) { # axes
    rownames(result) <- c("mode", "step", "nticks",
                          "marklen", "expand")
    result <- result[first:last,]
    result <- as.data.frame(t(result))
    result$mode <- c("custom", "fixedstep", "fixednum", "pretty", "user", "none")[result$mode + 1]
  }
  result
}

##
## ===[ SECTION: environment ]================================================
##



##
## set viewpoint
##
##

rgl.viewpoint <- function( theta = 0.0, phi = 15.0, fov = 60.0, zoom = 1.0, scale = par3d("scale"),
                           interactive = TRUE, userMatrix, type = c("userviewpoint", "modelviewpoint") ) {
  zoom <- rgl.clamp(zoom,0,Inf)
  phi  <- rgl.clamp(phi,-90,90)
  fov  <- rgl.clamp(fov,0,179)
  
  type <- match.arg(type, several.ok = TRUE)

  polar <- missing(userMatrix)
  if (polar) userMatrix <- diag(4)
  
  idata <- as.integer(c(interactive,polar, "userviewpoint" %in% type, "modelviewpoint" %in% type))
  ddata <- as.numeric(c(theta,phi,fov,zoom,scale,userMatrix[1:16]))

  ret <- .C( rgl_viewpoint,
    success = FALSE,
    idata,
    ddata
  )

  if (! ret$success)
    stop("'rgl_viewpoint' failed")
}

##
## set background
##
##

rgl.bg <- function(sphere=FALSE, fogtype="none", color=c("black","white"), back="lines", 
                   fogScale = 1, ... ) {
  rgl.material( color=color, back=back, ... )

  fogtype <- rgl.enum.fogtype(fogtype)

  idata   <- as.integer(c(sphere,fogtype))
  
  fogScale <- as.numeric(fogScale)
  stopifnot(length(fogScale) == 1, fogScale > 0)

  ret <- .C( rgl_bg, 
    success = as.integer(FALSE),
    idata,
    fogScale
  )

  if (! ret$success)
    stop("'rgl_bg' failed")
    
  lowlevel(ret$success)
}


##
## bbox
##
##

rgl.bbox <- function( 
  xat=NULL, xlab=NULL, xunit=0, xlen=5,
  yat=NULL, ylab=NULL, yunit=0, ylen=5,
  zat=NULL, zlab=NULL, zunit=0, zlen=5,
  marklen=15.0, marklen.rel=TRUE, expand=1, draw_front=FALSE,
  ...) {

  rgl.material( ... )

  if (is.null(xat)) 
    xlab <- NULL
  else {
    xlen <- length(xat)
    if (is.null(xlab)) 
      xlab <- format(xat)
    else 
      xlab <- rep(xlab, length.out=xlen)
  }
  if (is.null(yat)) 
    ylab <- NULL
  else {
    ylen <- length(yat)
    if (is.null(ylab)) 
      ylab <- format(yat)
    else 
      ylab <- rep(ylab, length.out=ylen)
  }
  if (is.null(zat)) 
    zlab <- NULL
  else {
    zlen <- length(zat)
    if (is.null(zlab)) 
      zlab <- format(zat)
    else 
      zlab <- rep(zlab,length.out=length(zat))
  }
  xticks <- length(xat)
  yticks <- length(yat)
  zticks <- length(zat)

  if (identical(xunit, "pretty")) xunit <- -1
  if (identical(yunit, "pretty")) yunit <- -1
  if (identical(zunit, "pretty")) zunit <- -1

  length(xlen)        <- 1
  length(ylen)        <- 1
  length(zlen)        <- 1
  length(marklen.rel) <- 1
  length(draw_front)  <- 1
  length(xunit)       <- 1
  length(yunit)       <- 1
  length(zunit)       <- 1
  length(marklen)     <- 1
  length(expand)      <- 1

  idata <- as.integer(c(xticks,yticks,zticks, xlen, ylen, zlen, marklen.rel, draw_front))
  ddata <- as.numeric(c(xunit, yunit, zunit, marklen, expand))

  ret <- .C( rgl_bbox,
    success = as.integer(FALSE),
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
    stop("'rgl_bbox' failed")
    
  lowlevel(ret$success)

}

##
## set lights
##
##

rgl.light <- function( theta = 0, phi = 0, viewpoint.rel = TRUE, ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF", x = NULL, y = NULL, z = NULL) {
  ambient  <- rgl.color(ambient)
  diffuse  <- rgl.color(diffuse)
  specular <- rgl.color(specular)
  
  # if a complete set of x, y, z is given, the light source is assumed to be part of the scene, theta and phi are ignored
  # else the light source is infinitely far away and its direction is determined by theta, phi (default) 
  if ( !is.null(x) ) {
    if ( !missing(theta) || !missing(phi) )
      warning("'theta' and 'phi' ignored when 'x' is present")
    xyz <- xyz.coords(x,y,z)
    x <- xyz$x
    y <- xyz$y
    z <- xyz$z
    if (length(x) > 1) stop("A light can only be in one place at a time")
    finite.pos <- TRUE
  }
  else {
    
    if ( !is.null(y) || !is.null(z) ) 
      warning("'y' and 'z' ignored, spherical coordinates used")
    finite.pos <- FALSE
    x <- 0
    y <- 0
    z <- 0
    
  }
    

  idata <- as.integer(c(viewpoint.rel, ambient, diffuse, specular, finite.pos))
  ddata <- as.numeric(c(theta, phi, x, y, z))

  ret <- .C( rgl_light,
    success = as.integer(FALSE),
    idata,
    ddata
  )

  if (! ret$success)
    stop("Too many lights; maximum is 8 sources per scene")
    
  lowlevel(ret$success)
}

##
## ===[ SECTION: shapes ]=====================================================
##

##
## add primitive
##
##

rgl.primitive <- function( type, x, y=NULL, z=NULL, normals=NULL, texcoords=NULL, ... ) {
  rgl.material( ... )

  type <- rgl.enum.primtype(type)
  
  xyz <- xyz.coords(x,y,z,recycle=TRUE)
  x <- xyz$x
  y <- xyz$y
  z <- xyz$z

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  if (nvertex > 0) {
    
    perelement <- c(points=1, lines=2, triangles=3, quadrangles=4, linestrips=1)[type]
    if (nvertex %% perelement) 
      stop("Illegal number of vertices")
    
    idata   <- as.integer( c(type, nvertex, !is.null(normals), !is.null(texcoords) ) )
    
    if (is.null(normals)) normals <- 0
    else {
    
      normals <- xyz.coords(normals, recycle=TRUE)
      x <- rep(normals$x, len=nvertex)
      y <- rep(normals$y, len=nvertex)
      z <- rep(normals$z, len=nvertex)
      normals <- rgl.vertex(x,y,z)
    }
    
    if (is.null(texcoords)) texcoords <- 0
    else {
    
      texcoords <- xy.coords(texcoords, recycle=TRUE)
      s <- rep(texcoords$x, len=nvertex)
      t <- rep(texcoords$y, len=nvertex)
      texcoords <- rgl.texcoords(s,t)
    } 
    
    ret <- .C( rgl_primitive,
      success = as.integer(FALSE),
      idata,
      as.numeric(vertex),
      as.numeric(normals),
      as.numeric(texcoords),
      NAOK = TRUE
    )
        
    if (! ret$success)
      stop("'rgl_primitive' failed")
      
    lowlevel(ret$success)
  }
}

rgl.points <- function( x, y=NULL, z=NULL, ... ) {
  rgl.primitive( "points", x, y, z, ... )
}

rgl.lines <- function(x, y=NULL, z=NULL, ... ) {
  rgl.primitive( "lines", x, y, z, ... )
}

rgl.triangles <- function(x, y=NULL, z=NULL, normals=NULL, texcoords=NULL, ... ) {
  rgl.primitive( "triangles", x, y, z, normals, texcoords, ... )
}

rgl.quads <- function( x, y=NULL, z=NULL, normals=NULL, texcoords=NULL, ... ) {
  rgl.primitive( "quadrangles", x, y, z, normals, texcoords, ... )
}

rgl.linestrips<- function( x, y=NULL, z=NULL, ... ) {
  rgl.primitive( "linestrips", x, y, z, ... )
}

##
## add surface
##
##

# Utility function:
# calculates the parity of a permutation of integers

perm_parity <- function(p) {
  x <- seq_along(p)
  result <- 0
  for (i in x) {
    if (x[i] != p[i]) {
      x[x==p[i]] <- x[i]
      result <- result+1
    }
  }
  return(result %% 2)
}

rgl.surface <- function( x, z, y, coords=1:3,  ..., normal_x=NULL, normal_y=NULL, normal_z=NULL,
                         texture_s=NULL, texture_t=NULL) {
  rgl.material(...)
  
  flags <- rep(FALSE, 4)
  
  if (is.matrix(x)) {
    nx <- nrow(x)
    flags[1] <- TRUE
    if ( !identical( dim(x), dim(y) ) ) stop(gettextf("Bad dimension for %s", "rows"),
    					     domain = NA)
  } else nx <- length(x)
  
  if (is.matrix(z)) {
    nz <- ncol(z)
    flags[2] <- TRUE
    if ( !identical( dim(z), dim(y) ) ) stop(gettextf("Bad dimension for %s", "cols"),
                                             domain = NA)     
  } else nz <- length(z)
  
  ny <- length(y)

  if ( nx*nz != ny)
    stop("'y' length != 'x' rows * 'z' cols")

  if ( nx < 2 )
    stop("rows < 2")
  
  if ( nz < 2 )   
    stop("cols < 2")
    
  if ( length(coords) != 3 || !identical(all.equal(sort(coords), 1:3), TRUE) )
    stop("'coords' must be a permutation of 1:3")
  
  nulls <- c(is.null(normal_x), is.null(normal_y), is.null(normal_z))
  if (!all( nulls ) ) {
    if (any( nulls )) stop("All normals must be supplied")
    if ( !identical(dim(y), dim(normal_x)) 
      || !identical(dim(y), dim(normal_y))
      || !identical(dim(y), dim(normal_z)) ) stop(gettextf("Bad dimension for %s", "normals"),
      					    domain = NA)
    flags[3] <- TRUE
  }
  
  nulls <- c(is.null(texture_s), is.null(texture_t))
  if (!all( nulls ) ) {
    if (any( nulls )) stop("Both texture coordinates must be supplied")
    if ( !identical(dim(y), dim(texture_s))
      || !identical(dim(y), dim(texture_t)) ) stop(gettextf("Bad dimension for %s", "textures"),
      					     domain = NA)
    flags[4] <- TRUE
  }

  idata <- as.integer( c( nx, nz ) )

  parity <- (perm_parity(coords) + (x[2] < x[1]) + (z[2] < z[1]) ) %% 2
  
  ret <- .C( rgl_surface,
    success = as.integer(FALSE),
    idata,
    as.numeric(x),
    as.numeric(z),
    as.numeric(y),
    as.numeric(normal_x),
    as.numeric(normal_z),
    as.numeric(normal_y),
    as.numeric(texture_s),
    as.numeric(texture_t),
    as.integer(coords),
    as.integer(parity),
    as.integer(flags),
    NAOK=TRUE
  )

  if (! ret$success)
    stop("'rgl_surface' failed")
    
  lowlevel(ret$success)
}

##
## add spheres
##

rgl.spheres <- function( x, y=NULL, z=NULL, radius=1.0, fastTransparency = TRUE, ...) {
  rgl.material(...)

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  radius  <- rgl.attr(radius, nvertex)
  nradius <- length(radius)
  if (!nradius) stop("No radius specified")
  
  idata <- as.integer( c( nvertex, nradius ) )
   
  ret <- .C( rgl_spheres,
    success = as.integer(FALSE),
    idata,
    as.numeric(vertex),    
    as.numeric(radius),
    as.integer(fastTransparency),
    NAOK=TRUE
  )

  if (! ret$success)
    stop("'rgl_spheres' failed")
    
  lowlevel(ret$success)

}

##
## add planes
##

rgl.planes <- function( a, b=NULL, c=NULL, d=0,...) {
  rgl.material(...)

  normals  <- rgl.vertex(a, b, c)
  nnormals <- rgl.nvertex(normals)
  noffsets <- length(d)
  
  idata <- as.integer( c( nnormals, noffsets ) )
   
  ret <- .C( rgl_planes,
    success = as.integer(FALSE),
    idata,
    as.numeric(normals),    
    as.numeric(d),
    NAOK=TRUE
  )

  if (! ret$success)
    stop("'rgl_planes' failed")
    
  lowlevel(ret$success)

}

##
## add clip planes
##

rgl.clipplanes <- function( a, b=NULL, c=NULL, d=0) {
  normals  <- rgl.vertex(a, b, c)
  nnormals <- rgl.nvertex(normals)
  noffsets <- length(d)
  
  idata <- as.integer( c( nnormals, noffsets ) )
   
  ret <- .C( rgl_clipplanes,
    success = as.integer(FALSE),
    idata,
    as.numeric(normals),    
    as.numeric(d),
    NAOK=TRUE
  )

  if (! ret$success)
    stop("'rgl_clipplanes' failed")
    
  lowlevel(ret$success)

}


##
## add abclines
##

rgl.abclines <- function(x, y=NULL, z=NULL, a, b=NULL, c=NULL, ...) {
  rgl.material(...)

  bases  <- rgl.vertex(x, y, z)
  nbases <- rgl.nvertex(bases)
  directions <- rgl.vertex(a, b, c)
  ndirs <-  rgl.nvertex(directions)
  
  idata <- as.integer( c( nbases, ndirs ) )
   
  ret <- .C( rgl_abclines,
    success = as.integer(FALSE),
    idata,
    as.numeric(bases),    
    as.numeric(directions),
    NAOK=TRUE
  )

  if (! ret$success)
    stop("'rgl_abclines' failed")
    
  lowlevel(ret$success)

}


##
## add texts
##

rgl.texts <- function(x, y=NULL, z=NULL, text, adj = 0.5, pos = NULL, offset = 0.5, 
                      family=par3d("family"), font=par3d("font"), 
                      cex=par3d("cex"), useFreeType=par3d("useFreeType"), 
                      ... ) {
  rgl.material( ... )

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  
  if (!is.null(pos)) {
    npos <- length(pos)
    stopifnot(all(pos %in% 0:6))
    stopifnot(length(offset) == 1)
    adj <- offset
  } else {
    pos <- 0
    npos <- 1
  }
  if (length(adj) > 3) warning("Only the first three entries of 'adj' are used")
  adj <- c(adj, 0.5, 0.5, 0.5)[1:3]
  
  if (!length(text)) {
    if (nvertex)
      warning("No text to plot")
    return(invisible(integer(0)))
  }
    
  text    <- rep(text, length.out=nvertex)
  
  idata <- as.integer(nvertex)
  
  nfonts <- max(length(family), length(font), length(cex)) 
  family <- rep(family, len=nfonts)
  font <- rep(font, len=nfonts)
  cex <- rep(cex, len=nfonts)  
  
  family[font == 5] <- "symbol"
  font <- ifelse( font < 0 | font > 4, 1, font)  
  
  ret <- .C( rgl_texts,
    success = as.integer(FALSE),
    idata,
    as.double(adj),
    as.character(text),
    as.numeric(vertex),
    as.integer(nfonts),
    as.character(family), 
    as.integer(font),
    as.numeric(cex),
    as.integer(useFreeType),
    as.integer(npos),
    as.integer(pos),
    NAOK=TRUE
  )
  
  if (! ret$success)
    stop("'rgl_texts' failed")

  lowlevel(ret$success)
}

##
## add sprites
##

rgl.sprites <- function( x, y=NULL, z=NULL, radius=1.0, shapes=NULL, 
                         userMatrix=diag(4), fixedSize = FALSE,
                         adj = 0.5, pos = NULL, offset = 0.25,
			 ... ) {
  rgl.material(...)

  center  <- rgl.vertex(x,y,z)
  ncenter <- rgl.nvertex(center)
  radius  <- rgl.attr(radius, ncenter)
  nradius <- length(radius)

  pos <- as.integer(pos)
  npos <- length(pos)
  if (npos) {
    pos <- rep(pos, length.out = ncenter)
    adj <- offset
  }
  adj <- c(adj, 0.5, 0.5, 0.5)[1:3]
  if (!nradius) stop("No radius specified")
  if (length(shapes) && length(userMatrix) != 16) stop("Invalid 'userMatrix'")
  if (length(fixedSize) != 1) stop("Invalid 'fixedSize'")
  idata   <- as.integer( c(ncenter,nradius,length(shapes), fixedSize, npos) )
  
  ret <- .C( rgl_sprites,
    success = as.integer(FALSE),
    idata,
    as.numeric(center),
    as.numeric(radius),
    as.integer(shapes),
    as.numeric(t(userMatrix)),
    as.numeric(adj),
    pos,
    as.numeric(offset),
    NAOK=TRUE
  )

  if (! ret$success)
    stop("'rgl_sprites' failed")

  lowlevel(ret$success)
}

##
## convert user coordinate to window coordinate
## 

rgl.user2window <- function( x, y=NULL, z=NULL, projection = rgl.projection()) {
  xyz <- xyz.coords(x,y,z,recycle=TRUE)
  points <- rbind(xyz$x,xyz$y,xyz$z,1)
  v <- asEuclidean(with(projection, t(proj %*% model %*% points))) # nolint
  viewport <- projection$view
  cbind( (v[,1]*0.5 + 0.5) + viewport[1]/viewport[3],
         (v[,2]*0.5 + 0.5) + viewport[2]/viewport[4],
         (1 + v[,3])*0.5 )
}

##
## convert window coordinate to user coordinate
## 

rgl.window2user <- function( x, y = NULL, z = 0, projection = rgl.projection()) {
  xyz <- xyz.coords(x,y,z,recycle=TRUE)

  viewport <- projection$view

  normalized <- rbind( 2*xyz$x - 1,
                       2*(xyz$y - viewport[2]/viewport[4]) - 1,
                       2*xyz$z - 1,
                       1 )
  asEuclidean(with(projection, t(solve(proj %*% model, normalized)))) # nolint
}

# Selectstate values
msNONE     <- 1
msCHANGING <- 2
msDONE     <- 3
msABORT    <- 4

rgl.selectstate <- function(dev = cur3d(), subscene = currentSubscene3d(dev)) {
	ret <- .C( rgl_selectstate,
    	as.integer(dev),
    	as.integer(subscene),
    	success = FALSE,
    	state = as.integer(0),
    	mouseposition = double(4)
  	)

  	if (! ret$success)
    	  stop("'rgl_selectstate' failed")
    return(ret)
}


rgl.select <- function(button = c("left", "middle", "right"), 
                       dev = cur3d(), subscene = currentSubscene3d(dev)) {
	if (rgl.useNULL())
	  return(NULL)
	button <- match.arg(button)
	
	newhandler <- par3d("mouseMode", dev = dev, subscene = subscene)
	newhandler[button] <- "selecting"
	oldhandler <- par3d(mouseMode = newhandler, dev = dev, subscene = subscene)
	on.exit(par3d(mouseMode = oldhandler, dev = dev, subscene = subscene))
	
	while ((result <- rgl.selectstate(dev = dev, subscene = subscene))$state < msDONE)
		Sys.sleep(0.1)
	
	rgl.setselectstate("none", dev = dev, subscene = subscene)
	
	if (result$state == msDONE)
	    return(result$mouseposition)
	else
	    return(NULL)
}

rgl.setselectstate <- function(state = "current", 
                               dev = cur3d(), subscene = currentSubscene3d(dev)) {
	state <- rgl.enum(state, current=0, none = 1, middle = 2, done = 3, abort = 4)
	idata <- as.integer(c(state))
	
	  ret <- .C( rgl_setselectstate, 
	    as.integer(dev),
	    as.integer(subscene),
	    success = FALSE,
	    state = idata
	  )
	
	  if (! ret$success)
	    stop("'rgl_setselectstate' failed")

	c("none", "middle", "done", "abort")[ret$state]
}

rgl.projection <- function(dev = cur3d(), subscene = currentSubscene3d(dev)) {
    list(model = par3d("modelMatrix", dev = dev, subscene = subscene),
    	 proj = par3d("projMatrix", dev = dev, subscene = subscene),
    	 view = par3d("viewport", dev = dev, subscene = subscene))
}   
     
rgl.select3d <- function(button = c("left", "middle", "right"), 
                         dev = cur3d(), subscene = currentSubscene3d(dev)) {
  rect <- rgl.select(button = button, dev = dev, subscene = subscene)
  if (is.null(rect)) return(NULL)
  proj <- rgl.projection(dev = dev, subscene = subscene)
  
  llx <- rect[1]
  lly <- rect[2]
  urx <- rect[3]
  ury <- rect[4]

  selectionFunction3d(proj, region = c(llx, lly, urx, ury))
}

selectionFunction3d <- function(proj, region = proj$region) {
  llx <- region[1]
  lly <- region[2]
  urx <- region[3]
  ury <- region[4]
  
  if ( llx > urx ) {
    temp <- llx
    llx <- urx
    urx <- temp
  }
  if ( lly > ury ) {
    temp <- lly
    lly <- ury
    ury <- temp
  }
  proj$view["x"] <- proj$view["y"] <- 0
  function(x,y=NULL,z=NULL) {
    pixel <- rgl.user2window(x,y,z,projection=proj)
    x <- pixel[,1]
    y <- pixel[,2]
    z <- pixel[,3]
    (llx <= x) & (x <= urx) & (lly <= y) & (y <= ury) & 
    (0 <= z) & (z <= 1)
  }
}
