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
  .Defunct("clear3d")
}


##
## pop node
##
##

pop3d <- function( type = "shapes", id = 0, tag = NULL) {
  if (!is.null(tag)) {
    if (!missing(id))
      stop("Only one of 'id' and 'tag' should be specified.")
    allids <- ids3d(intersect(c("shapes", "bboxdeco"), type), subscene = 0, tags = TRUE)
    id <- allids$id[allids$tag %in% tag]
  }
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
      stop(gettextf("'rgl_pop' failed for id %d", i), domain = NA)
  }
  lowlevel()
}

rgl.pop <- pop3d

ids3d <- function( type = "shapes", subscene = NA, tags = FALSE) {
  type <- c(rgl.enum.nodetype(type), 0)
  if (is.na(subscene)) 
    subscene <- currentSubscene3d()
  
  count <- .C( rgl_id_count, as.integer(type), count = integer(1), subscene = as.integer(subscene))$count
  
  result <- as.data.frame( .C( rgl_ids, as.integer(type), id=integer(count), 
                               type=rep("",count), subscene = as.integer(subscene) )[2:3] )
  
  if (tags) {
    result$tag <- rep("", nrow(result))
    if (NROW(result)) {
      hasmaterial <- !(result$type %in% c("light", "userviewpoint", "background", "modelviewpoint", "subscene"))
      result$tag[hasmaterial] <- vapply(result$id[hasmaterial],
                                        function(id) {
                                          rgl.getmaterial(0, id = id)$tag
                                        }, "")
    }
  }
  result
}

rgl.ids <- ids3d

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
	    family=1, font=1, pos=1, fogscale=1, axes=3,
	    indices=1, shapenum=1)

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
			                     c("x", "y", "z"),   # axes
			                     "vertex",          # indices
			                     "shape"
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
                            else "fixedSize",
                            "rotating")[first:last]
    }
  if (attrib == 20 && count) { # axes
    rownames(result) <- c("mode", "step", "nticks",
                          "marklen", "expand")
    result <- result[first:last,]
    result <- as.data.frame(t(result))
    result$mode <- c("custom", "fixednum", "fixedstep", "pretty", "user", "none")[result$mode + 1]
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
  .Defunct("view3d")
}

##
## set background
##
##

rgl.bg <- function(sphere=FALSE, fogtype="none", color=c("black","white"), back="lines", 
                   fogScale = 1, ... ) {
  .Defunct("bg3d")
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

  .Defunct("bbox3d")
}

##
## set lights
##
##

rgl.light <- function( theta = 0, phi = 0, viewpoint.rel = TRUE, ambient = "#FFFFFF", diffuse = "#FFFFFF", specular = "#FFFFFF", x = NULL, y = NULL, z = NULL) {
  
  .Defunct("light3d")
}

##
## ===[ SECTION: shapes ]=====================================================
##

##
## add primitive
##
##

rgl.primitive0 <- function( type, x, y=NULL, z=NULL, normals=NULL, texcoords=NULL, indices=NULL, ... ) {
  rgl.material0( ... )

  type <- rgl.enum.primtype(type)

  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  
  if (is.null(indices)) {
    nindices <- 0
    indices <- 0 # to avoid pointing out of range
  } else {
    nindices <- length(indices)
    if (!all(indices > 0 & indices <= nvertex))
      stop("indices out of range")
  }
  
  if (nvertex > 0) {
    
    perelement <- c(points=1, lines=2, triangles=3, quadrangles=4, linestrips=1)[type]
    if (nindices > 0) {
      if (nindices %% perelement)
        stop("Illegal number of indices") 
    } else if (nvertex %% perelement) 
      stop("Illegal number of vertices")
    
    idata   <- as.integer( c(type, nvertex, !is.null(normals), !is.null(texcoords), nindices, indices - 1 ) )
    
    if (is.null(normals)) normals <- 0
    else {
      normals <- xyz.coords(normals, recycle=TRUE)
      x <- rep(normals$x, length.out = nvertex)
      y <- rep(normals$y, length.out = nvertex)
      z <- rep(normals$z, length.out = nvertex)
      normals <- rgl.vertex(x,y,z)
    }
    
    if (is.null(texcoords)) texcoords <- 0
    else {
      texcoords <- xy.coords(texcoords, recycle=TRUE)
      s <- rep(texcoords$x, length.out = nvertex)
      t <- rep(texcoords$y, length.out = nvertex)
      texcoords <- rgl.texcoords(s,t)
    } 
    
    success <- .Call( rgl_primitive,
      as.integer(idata),
      as.numeric(vertex),
      as.numeric(normals),
      as.numeric(texcoords)
    )
        
    if (!success)
      stop("'rgl_primitive' failed")
      
    lowlevel(success)
  }
}

rgl.primitive <- function(...) {
  .Defunct("", msg = "Please call the primitive directly, e.g. points3d(...).")
}

rgl.points <- function( x, y=NULL, z=NULL, ... ) {
  .Defunct("points3d")
}

rgl.lines <- function(x, y=NULL, z=NULL, ... ) {
  .Defunct("segments3d")
}

rgl.triangles <- function(x, y=NULL, z=NULL, normals=NULL, texcoords=NULL, ... ) {
  .Defunct("triangles3d")
}

rgl.quads <- function( x, y=NULL, z=NULL, normals=NULL, texcoords=NULL, ... ) {
  .Defunct("quads3d")
}

rgl.linestrips<- function( x, y=NULL, z=NULL, ... ) {
  .Defunct("lines3d")
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
  .Defunct("surface3d")
}

##
## add spheres
##

rgl.spheres <- function( x, y=NULL, z=NULL, radius=1.0, fastTransparency = TRUE, ...) {
  rgl.material0(...)
  
  vertex  <- rgl.vertex(x,y,z)
  nvertex <- rgl.nvertex(vertex)
  radius  <- rgl.attr(radius, nvertex)
  nradius <- length(radius)
  if (nvertex && nradius) {
    
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
}

##
## add planes
##

rgl.planes <- function( a, b=NULL, c=NULL, d=0,...) {
  .Defunct("planes3d")
}

##
## add clip planes
##

rgl.clipplanes <- function( a, b=NULL, c=NULL, d=0) {
  .Defunct("clipplanes3d")
}


##
## add abclines
##

rgl.abclines <- function(x, y=NULL, z=NULL, a, b=NULL, c=NULL, ...) {
  .Defunct("abclines3d")
}


##
## add texts
##

rgl.texts <- function(x, y=NULL, z=NULL, text, adj = 0.5, pos = NULL, offset = 0.5, 
                      family=par3d("family"), font=par3d("font"), 
                      cex=par3d("cex"), useFreeType=par3d("useFreeType"), 
                      ... ) {
  .Defunct("text3d")
}

##
## add sprites
##

rgl.sprites <- function( x, y=NULL, z=NULL, radius=1.0, shapes=NULL, 
                         userMatrix=diag(4), fixedSize = FALSE,
                         adj = 0.5, pos = NULL, offset = 0.25, rotating = FALSE, 
                         ... ) {
  .Defunct("sprites3d")
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

  normalized <- rbind( 2*(xyz$x - viewport[1]/viewport[3]) - 1,
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
  .Defunct("select3d")
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

tagged3d <- function(tags = NULL, ids = NULL, full = FALSE, subscene = 0) {
  if ((missing(tags) + missing(ids)) != 1) 
    stop("Exactly one of 'tags' and 'ids' should be specified.")
  all <- ids3d("all", subscene = subscene, tags = TRUE)
  if (!missing(tags))
    all <- all[all$tag %in% tags,]
  else
    all <- all[match(ids, all$id),]
  if (full)
    all
  else
    if (!missing(tags) && !is.null(tags)) 
      all$id
    else if (!missing(ids) && !is.null(ids))
      all$tag
    else
      NULL
}
