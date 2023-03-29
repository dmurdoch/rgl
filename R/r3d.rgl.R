#
# R3D rendering functions - rgl implementation
# 

# Node Management

getr3dDefaults <- function(class = NULL, value = NULL) {
  result <- r3dDefaults
  if (exists("r3dDefaults", envir = globalenv())) {
    user <- get("r3dDefaults", envir=.GlobalEnv)
    for (n in names(user)) {
      if (is.list(result[[n]]))
        result[[n]][names(user[[n]])] <- user[[n]]
      else
        result[[n]] <- user[[n]]
    }
  }
  if (!is.null(class))
    result <- result[[class]]
  if (!is.null(result) && !is.null(value))
    result <- result[[value]]
  result
}

clear3d     <- function(type = c("shapes", "bboxdeco", "material"), 
                        defaults=getr3dDefaults(),
                        subscene = 0) {
  .check3d()
  
  if (is.na(subscene)) 
    subscene <- currentSubscene3d()
  
  typeid0 <- rgl.enum.nodetype(type)
  
  userviewpoint <- 4 %in% typeid0
  material  <- 5 %in% typeid0
  modelviewpoint <- 8 %in% typeid0
  
  drop <- typeid0 %in% c(4:5, 8)
  typeid <- typeid0[!drop]
  type <- names(typeid)
  
  if (subscene == 0) {
    idata <- as.integer(c(length(typeid), typeid))    	
    ret <- .C( rgl_clear, 
               success = FALSE,
               idata
    )$success
    
    if (! ret)
      stop("'rgl_clear' failed")
    
  } else {
    sceneids <- ids3d(type=type, subscene = 0)$id
    thisids <- ids3d(type=type, subscene = subscene)$id
    if (length(thisids)) {
      delFromSubscene3d(ids = thisids, subscene = subscene)
      gc3d(protect = setdiff(sceneids, thisids))
    }
  }
  
  if ( userviewpoint || modelviewpoint) 
    view3d(type = c("userviewpoint", "modelviewpoint")[c(userviewpoint, modelviewpoint)])
  
  if ( material ) 
    rgl.material0()
  
  if ( 4 %in% typeid0 ) { # userviewpoint
    do.call("par3d", defaults["FOV"])
  }
  if ( 8 %in% typeid0 ) { # modelviewpoint
    do.call("par3d", defaults["userMatrix"])
  }
  if ( 5 %in% typeid0 ) { # material
    if (length(defaults$material))
      do.call("material3d", defaults$material)
  }
  if ( 6 %in% typeid0 ) { # background
    do.call("bg3d", as.list(defaults$bg))
  }
  lowlevel()
}

# Environment

rgl.material.names <- c("color", "alpha", "lit", "ambient", "specular",
    "emission", "shininess", "smooth", "front", "back", "size", 
    "lwd", "fog", "point_antialias", "line_antialias",
    "texture", "textype", "texmode", "texmipmap",
    "texminfilter", "texmagfilter", "texenvmap",
    "depth_mask", "depth_test", "isTransparent",
    "polygon_offset", "margin", "floating", "tag",
    "blend")

rgl.material.readonly <- "isTransparent"

# Warn about putting a texture on a black surface, but only
# if the surface is black because that's the default.

warnBlackTexture <- function(...,
                             defaults = material3d(),
                             color = col, col = "missing",
                             texture = defaults$texture,
                             texmode = defaults$texmode) {
  if (!is.null(texture)) {
    if (length(color) == 1 &&
      !is.na(color) &&
      color == "missing" &&
      !is.na(texmode) && 
      texmode == "modulate" &&
      isTRUE(getOption("rgl.warnBlackTexture", TRUE)) &&
      length(defaults$color) &&
      !is.na(defaults$color[1]) &&
      defaults$color[1] %in% c("#000000", "black"))
      warning("Texture will be invisible on black surface", call. = FALSE) 
  }
}

# Attach the expression for the source of a texture if
# it is not already there

addTextureSource <- function(texture, ...) {
  if (!is.null(texture) && is.null(attr(texture, "src")))
    attr(texture, "src") <- substitute(texture)
  texture
}

# This function expands a list of arguments by putting
# all entries from Params (i.e. the current settings by default)
# in place for any entries that are not listed.  
# Unrecognized args are left in place.

.fixMaterialArgs <- function(..., Params = material3d(), col) {
   f <- function(...) list(...)
   dots <- list(...)
   if (!is.null(dots$texture)) {
     warnBlackTexture(...,  
       col = if (missing(col)) "missing" else col,
       defaults = Params)
     dots$texture <- addTextureSource(...)
   }
   if (!missing(col)) 
     Params$color <- col
   formals(f) <- c(Params, formals(f))
   names <- as.list(names(Params))
   names(names) <- names
   names <- lapply(names, as.name)
   b <- as.list(body(f))
   body(f) <- as.call(c(b[1], names, b[-1]))
   do.call(f, dots)
} 

# This one just expands the argument names to match the
# standard names
.fixMaterialArgs2 <- function(..., col) {
  call <- do.call(call, list("rgl.material0", ...))
  result <- as.list(match.call(rgl.material0, call))[-1]
  if (!missing(col) && is.null(result$color))
    result$color <- col
  result
}
     
# This one just gets the material args
# If warn is TRUE, give a warning instead of ignoring extras.

.getMaterialArgs <- function(..., material = list(), warn = FALSE, col = material[["col"]]) {
  fullyNamed <- as.list(match.call(rgl.material0, 
                           as.call(c(list(as.name("rgl.material0"),
                                        ...), material))))[-1]
  if (!is.null(col) && !("color" %in% names(fullyNamed)))
    fullyNamed$color <- col
  good <- names(fullyNamed) %in% rgl.material.names
  if (warn && !all(good))
    warning("Argument(s) ", paste(names(fullyNamed)[!good], collapse = ", "), " not matched.")
  fullyNamed[good]
}

material3d  <- function(..., id = NULL) {
  args <- list(...)
  argnames <- names(args)
  if (length(argnames) && !is.null(id))
    stop("Material properties cannot be set on existing objects.")
  if (length(id) > 1)
   stop("Material properties may only be queried for single objects.")
  argnames <- setdiff(argnames, rgl.material.readonly)
  if (!length(args))
    argnames <- rgl.material.names
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
  value <- rgl.getmaterial(id = id)[argnames]
  if (length(args)) {
    save <- options(rgl.warnBlackTexture = FALSE)
    on.exit(options(save))
    args <- do.call(".fixMaterialArgs", args)
    do.call("rgl.material0", args)
    return(invisible(value))
  } else if (length(argnames) == 1) return(value[[1]])
  else return(value)
}

bg3d        <- function(color,
                        sphere=FALSE, 
                        back="lines",
                        fogtype="none", 
                        fogScale = 1, 
                        col, ... ) {
  .check3d(); save <- material3d(); on.exit(material3d(save))

  bgid <- ids3d("background")$id
  if (length(bgid) && nrow(flags <- rgl.attrib(bgid[1], "flags"))) {
    if (missing(sphere))
      sphere <- flags["sphere", 1]
    if (missing(fogtype))
      fogtype <- if (flags["linear_fog", 1]) "linear"
      else if (flags["exp_fog", 1]) "exp"
      else if (flags["exp2_fog", 1]) "exp2"
      else "none"
  }
  dots <- list(...)
  
  if (!missing(color)) {
    dots$color <- color
    if (!missing(col))
      warning("'color' specified, so 'col' is ignored.")
  } else if (!missing(col))
    dots$color <- col
  
  if ("fogtype" %in% names(dots))
    fogtype <- dots$fogtype
  if ("fogScale" %in% names(dots))
    fogScale <- dots$fogScale
  else
    fogScale <- 1
  
  if ("color" %in% names(dots))
    color <- dots$color
  else if ("col" %in% names(dots))
    color <- dots$col
  else
    color <- getr3dDefaults("bg", "color")
  if (is.null(color))
    color <- "white"
    
  new <- .fixMaterialArgs(sphere = sphere, 
                          fogtype = fogtype, 
                          fogScale = fogScale,
                          color = color, 
  			  back = back, lit = FALSE, Params = save)
  
  do.call("rgl.material0", .fixMaterialArgs(..., Params = new))
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

light3d     <- function(theta=0, phi=15,
                        x=NULL, y = NULL, z = NULL,
                        viewpoint.rel = TRUE, 
                        ambient = "#FFFFFF", 
                        diffuse = "#FFFFFF", 
                        specular = "#FFFFFF") {
  .check3d()

  ambient  <- rgl.color(ambient)
  diffuse  <- rgl.color(diffuse)
  specular <- rgl.color(specular)
  
  # if a complete set of x, y, z is given, the light source is assumed to be part of the scene, theta and phi are ignored
  # else the light source is infinitely far away and its direction is determined by theta, phi (default) 
  
  if ( !is.null(x) ) {
    if ( !missing(theta) || !missing(phi) )
      warning("'theta' and 'phi' ignored when 'x' is present")
    xyz <- xyz.coords(x,y,z, recycle = TRUE)
    x <- xyz$x
    y <- xyz$y
    z <- xyz$z
    if (length(x) > 1) stop("A light can only be in one place at a time")
    finite.pos <- TRUE
  }
  else {
    
    if ( !is.null(y) || !is.null(z) ) 
      warning("'y' and 'z' ignored, 'theta' and 'phi' used")
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
    stop("Error in 'rgl_light'.  Too many lights? maximum is 8 sources per scene")
  
  lowlevel(ret$success)
}

view3d      <- function(theta = 0.0, phi = 15.0, 
                        fov = 60.0, zoom = 1.0, scale = par3d("scale"),
                        interactive = TRUE, userMatrix, 
                        type = c("userviewpoint", "modelviewpoint")) {
  .check3d()
  
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
  lowlevel()
}

bbox3d	    <- function(xat = NULL, 
                        yat = NULL, 
                        zat = NULL, 
                        xunit = "pretty",
                        yunit = "pretty",
                        zunit = "pretty",
                        expand = 1.03, draw_front = FALSE,
                        xlab=NULL, ylab=NULL, zlab=NULL,
                        xlen=5, ylen=5, zlen=5,
                        marklen=15.0, marklen.rel=TRUE, 
                       ...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  # Force evaluation of args as in old bbox3d
  list(xat=xat, yat=yat, zat=zat, 
       xunit=xunit, yunit=yunit, zunit=zunit, expand=expand,
       draw_front=draw_front)
  
  do.call(rgl.material0, .fixMaterialArgs(..., Params = save))
  
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

dummyBbox <- function()
  bbox3d(xat = numeric(), yat = numeric(), zat = numeric(),
         front = "cull", back = "cull")

observer3d <- function(x, y=NULL, z=NULL, auto=FALSE) {
  if (missing(x))
    location <- c(NA, NA, NA)
  else {
    xyz <- xyz.coords(x,y,z, recycle = TRUE)
    location <- c(xyz$x, xyz$y, xyz$z)
    if (length(location) != 3) stop("A single point must be specified for the observer location") 
  }    
  prev <- .C(rgl_getObserver, success=integer(1), ddata=numeric(3), NAOK = TRUE)$ddata
  .C(rgl_setObserver, success=as.integer(auto), ddata=as.numeric(location), NAOK = TRUE)
  lowlevel(prev)
}

# Shapes

points3d    <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.primitive0", c(list(type = "points", x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

lines3d     <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.primitive0", c(list(type = "linestrips", x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

segments3d  <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.primitive0", c(list(type = "lines", x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

triangles3d <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.primitive0", c(list(type = "triangles", x=x, y=y, z=z), 
                             .fixMaterialArgs(..., Params = save)))
}

quads3d     <- function(x,y=NULL,z=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.primitive0", c(list(type = "quadrangles", x=x,y=y,z=z), .fixMaterialArgs(..., Params = save)))
}

text3d      <- function(x, y = NULL, z = NULL,
			texts, adj = 0.5, pos = NULL, offset = 0.5,
			usePlotmath = is.language(texts),
			family = par3d("family"), font = par3d("font"), 
			cex = par3d("cex"), useFreeType = par3d("useFreeType"),
			...) {
  if (usePlotmath) 
    return(plotmath3d(x = x, y = y, z = z, text = texts, adj = adj, 
                      pos = pos, offset = offset, ...))
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.material0", .fixMaterialArgs(..., Params = save))
  # Force evaluation
  list(x = x, y = y, z = z, text = texts, 
                              adj = adj, pos = pos,
                              offset = offset)
  
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
  
  if (!length(texts)) {
    if (nvertex)
      warning("No text to plot")
    return(invisible(integer(0)))
  }
  if (nvertex) {
    texts    <- rep(texts, length.out=nvertex)
    
    idata <- as.integer(nvertex)
    
    nfonts <- max(length(family), length(font), length(cex)) 
    family <- rep(family, length.out = nfonts)
    font <- rep(font, length.out = nfonts)
    cex <- rep(cex, length.out = nfonts)  
    
    family[font == 5] <- "symbol"
    font <- ifelse( font < 0 | font > 4, 1, font)  
    
    ret <- .C( rgl_texts,
               success = as.integer(FALSE),
               idata,
               as.double(adj),
               as.character(texts),
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
  
}
texts3d	    <- text3d

spheres3d   <- function(x, y = NULL, z = NULL, radius = 1, fastTransparency = TRUE, ...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  # Force evaluation of args
  list(x = x, y = y, z = z, radius = radius, fastTransparency = fastTransparency)
  do.call("rgl.material0", .fixMaterialArgs(..., Params = save))
  
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

planes3d   <- function(a,b=NULL,c=NULL,d=0,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  # Force evaluation of args
  list(a=a,b=b,c=c,d=d)
  do.call("rgl.material0", .fixMaterialArgs(..., Params = save))
  normals  <- rgl.vertex(a, b, c)
  nnormals <- rgl.nvertex(normals)
  noffsets <- length(d)
  
  if (nnormals && noffsets) {
    
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
}

clipplanes3d   <- function(a,b=NULL,c=NULL,d=0) {
  .check3d()
  normals  <- rgl.vertex(a, b, c)
  nnormals <- rgl.nvertex(normals)
  noffsets <- length(d)
  if (nnormals && noffsets) {
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
}

abclines3d   <- function(x,y=NULL,z=NULL,a,b=NULL,c=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  # Force evaluation of args
  list(x=x,y=y,z=z,a=a,b=b,c=c)
  do.call("rgl.material0", .fixMaterialArgs(..., Params = save))
  
  bases  <- rgl.vertex(x, y, z)
  nbases <- rgl.nvertex(bases)
  directions <- rgl.vertex(a, b, c)
  ndirs <-  rgl.nvertex(directions)
  if (nbases && ndirs) {
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
}

sprites3d   <- function(x, y = NULL, z = NULL, radius = 1, 
                        shapes = NULL, userMatrix, fixedSize = FALSE,  
                        adj = 0.5, pos = NULL, offset = 0.25,
                        rotating = FALSE,
												...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  
  do.call("rgl.material0", .fixMaterialArgs(..., Params = save))
  
  if (missing(userMatrix)) {
    userMatrix <- getr3dDefaults()$userMatrix
    if (is.null(userMatrix)) userMatrix <- diag(4)
  }
  savepar <- par3d(skipRedraw=TRUE, ignoreExtent=TRUE)
  on.exit(par3d(savepar), add=TRUE)
  force(shapes)
  
  par3d(ignoreExtent=savepar$ignoreExtent)
  # Force evaluation of args
  list(x=x,y=y,z=z,radius=radius,shapes=shapes,
       userMatrix=userMatrix, fixedSize = fixedSize, 
       rotating = rotating,
       adj = adj, pos = pos, offset = offset)
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
  if (ncenter && nradius) {
    if (length(shapes) && length(userMatrix) != 16) stop("Invalid 'userMatrix'")
    if (length(fixedSize) != 1) stop("Invalid 'fixedSize'")
    idata   <- as.integer( c(ncenter,nradius,length(shapes), fixedSize, npos, rotating) )
    
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
}

surface3d   <- function(x, y = NULL, z = NULL, ...,
                        normal_x = NULL, normal_y = NULL, normal_z = NULL,
                        texture_s = NULL, texture_t=NULL,
                        flip = FALSE) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  # Evaluate args
  list(x=x,y=z,z=y,coords=c(1,3,2),
       normal_x=normal_x,normal_y=normal_z,normal_z=normal_y)
  do.call("rgl.material0", .fixMaterialArgs(..., Params = save))
  flags <- rep(FALSE, 4)
  nrows <- NA
  ncols <- NA
  if (is.matrix(x)) {
    nrows <- nrow(x)
    ncols <- ncol(x)
    flags[1] <- TRUE
  } else nrows <- length(x)
  
  if (is.matrix(y)) {
    if (is.na(ncols))
      ncols <- ncol(y)
    if ( any(dim(y) != c(nrows, ncols))) 
      stop(gettextf("Bad dimension for %s", "y"),
                                             domain = NA)
    flags[2] <- TRUE
  } else {
    if (is.na(ncols))
      ncols <- length(y)
    else if (ncols != length(y))
      stop(gettextf("Bad length for %s", "y"),
           domain = NA)
  }
  
  if (is.matrix(z)) {
    if (any(dim(z) != c(nrows, ncols)))
      stop(gettextf("Bad dimension for %s", "z"))
  } else if (!flags[1] && !flags[2] && length(z) == nrows*ncols) {
      z <- matrix(z, nrows, ncols)
  } else if (!flags[2]) {
    if (!flags[1])
      stop("At least one coordinate must be a matrix")
    if (nrows != length(z))
      stop(gettextf("Bad length for %s", "z"))
    z <- matrix(z, nrows, ncols)
  } else {
    if (ncols != length(z))
      stop(gettextf("Bad length for %s", "z"))
    z <- matrix(z, nrows, ncols, byrow = TRUE)
  }
  
  nz <- length(z)
  
  if ( nrows < 2 )
    stop("rows < 2")
  
  if ( ncols < 2 )   
    stop("cols < 2")
  
  coords <- c(1,3,2)
  nulls <- c(is.null(normal_x), is.null(normal_y), is.null(normal_z))
  if (!all( nulls ) ) {
    if (any( nulls )) stop("All normals must be supplied")
    if ( !identical(dim(z), dim(normal_x)) 
         || !identical(dim(z), dim(normal_y))
         || !identical(dim(z), dim(normal_z)) ) stop(gettextf("Bad dimension for %s", "normals"),
                                                     domain = NA)
    flags[3] <- TRUE
  }
  
  nulls <- c(is.null(texture_s), is.null(texture_t))
  if (!all( nulls ) ) {
    if (any( nulls )) stop("Both texture coordinates must be supplied")
    if ( !identical(dim(z), dim(texture_s))
         || !identical(dim(z), dim(texture_t)) ) stop(gettextf("Bad dimension for %s", "textures"),
                                                      domain = NA)
    flags[4] <- TRUE
  }
  
  idata <- as.integer( c( nrows, ncols ) )
  
  xdecreasing <- diff(x[!is.na(x)][1:2]) < 0
  ydecreasing <- diff(y[!is.na(y)][1:2]) < 0
  parity <- (perm_parity(coords) + xdecreasing + ydecreasing + flip) %% 2
  
  if (is.na(parity))
    parity <- 0
  
  ret <- .C( rgl_surface,
             success = as.integer(FALSE),
             idata,
             as.numeric(x),
             as.numeric(y),
             as.numeric(z),
             as.numeric(normal_x),
             as.numeric(normal_y),
             as.numeric(normal_z),
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
terrain3d <- surface3d

# Interaction

select3d    <- function(button = c("left", "middle", "right"), 
                        dev = cur3d(), subscene = currentSubscene3d(dev)) {
  .check3d()
  rect <- rgl.select(button = button, dev = dev, subscene = subscene)
  if (is.null(rect)) return(NULL)
  proj <- rgl.projection(dev = dev, subscene = subscene)
  
  llx <- rect[1]
  lly <- rect[2]
  urx <- rect[3]
  ury <- rect[4]
  
  selectionFunction3d(proj, region = c(llx, lly, urx, ury))
}

# 3D Generic Object Rendering Attributes

dot3d <- function(x,...) UseMethod("dot3d")
wire3d  <- function(x,...) UseMethod("wire3d")
shade3d <- function(x,...) UseMethod("shade3d")

# 3D Generic transformation


translate3d <- function(obj,x,y,z,...) UseMethod("translate3d")
scale3d <- function(obj,x,y,z,...) UseMethod("scale3d")
rotate3d <- function(obj,angle,x,y,z,matrix,...) UseMethod("rotate3d")
transform3d <- function(obj,matrix,...) rotate3d(obj, matrix = matrix, angle = NA, x = NA, y = NA, z = NA)

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

r3dDefaults <- list(userMatrix = rotationMatrix(290*pi/180, 1, 0, 0),
		  mouseMode = c("none", "trackball", "zoom", "fov", "pull"),
		  FOV = 30,
		  bg = list(color="white",fogtype = "none"),
		  family = "sans",
		  material = list(color="black", fog = TRUE))

if (.Platform$OS.type == "windows")
	r3dDefaults$useFreeType <- FALSE

open3d <- function(..., params = getr3dDefaults(), 
                   useNULL = rgl.useNULL(), silent = FALSE	) {
	
	  register_pkgdown_methods()
	
    args <- list(...)
    if (missing(useNULL) && !is.null(params$useNULL)) {
      useNULL <- params$useNULL
      params$useNULL <- NULL
    }
    if (missing(silent) && !is.null(params$silent)) {
      silent <- params$silent
      params$silent <- NULL
    }
    if (!is.null(args$antialias) 
        || !is.null(args$antialias <- r3dDefaults$antialias)) {
    	saveopt <- options(rgl.antialias = args$antialias)
    	on.exit(options(saveopt))
    	args$antialias <- NULL
    }
    
    ret <- .C( rgl_dev_open, success=FALSE, useNULL=useNULL )
    
    if (! ret$success)
      stop("open failed") 
    
    if (!is.null(args$material)) {
    	params$material <- do.call(.fixMaterialArgs, c(args$material, Params=list(params$material)))
    	args$material <- NULL
    }
    
    if (length(args) && (is.null(names(args)) 
                      || any(nchar(names(args)) == 0)))
      stop("open3d parameters must be named")
    
    params[names(args)] <- args
        
    clear3d("material", defaults = params)
    params$material <- NULL
    
    if (!is.null(params$bg)) {
      do.call("bg3d", params$bg)
      params$bg <- NULL
    }
 
    do.call("par3d", params)  
    result <- structure(cur3d(), class = "rglOpen3d")
    if (silent)
      invisible(result)
    else
      result
}

print.rglOpen3d <- function(x, ...) {
  print(unclass(x))
}

close3d <- function(dev = cur3d(), silent = TRUE) {
  for (d in dev[dev != 0]) {
    devname <- paste0("dev", d)
    rgl.callback.env[[devname]] <- NULL
    set3d(d, silent = silent)
    if (length(hook <- getHook("on.rgl.close"))) {
      if (is.list(hook)) hook <- hook[[1]]  # test is for compatibility with R < 3.0.0
      hook()
    }
    
    ret <- .C( rgl_dev_close, success=FALSE )
    
    if (! ret$success)
      stop("close failed")
    
    if (!silent)
      message("Closed device ", d)
  }
  invisible(cur3d())
}

cur3d <- function() .Call( rgl_dev_getcurrent )
  
rgl.cur <- cur3d

set3d <- function(dev, silent = FALSE) {
  prev <- cur3d()
  
  idata <- c( as.integer(dev), as.integer(silent) )
  
  ret <- .C( rgl_dev_setcurrent, 
             success=FALSE, 
             idata
  )
  
  if (! ret$success)
    stop(gettextf("No device opened with id %s", dev), domain = NA)
  
  prev
}

.check3d <- function() {
    if (result<-cur3d()) return(result)
    else return(open3d())
}

requireWebshot2 <- function() {
  suppressMessages(res <- requireNamespace("webshot2", quietly = TRUE))
  if (res) 
    res <- requireNamespace("chromote") &&
           !is.null(path <- chromote::find_chrome()) &&
           nchar(path) > 0 &&
           file.exists(path)
  res
}

snapshot3d <- function(filename = tempfile(fileext = ".png"), 
                       fmt = "png", top = TRUE, ..., scene, width = NULL, height = NULL,
                       webshot = as.logical(Sys.getenv("RGL_USE_WEBSHOT", 
                                                                                                                     "TRUE"))) {
  force(filename)
  
  if (webshot && !requireWebshot2()) {
    warning("webshot = TRUE requires the webshot2 package and Chrome browser; using rgl.snapshot() instead")
    webshot <- FALSE
  }
  saveopts <- options(rgl.useNULL = webshot)
  on.exit(options(saveopts))
  
    # The logic here is a little convoluted:
  # scene  resize  webshot getscene1 plot resize getscene2
  # no     no      no      
  # no     no      yes         X
  # no     yes     no                       X
  # no     yes     yes         X      X     X      X                 
  # yes    no      no                 X
  # yes    no      yes     
  # yes    yes     no                 X     X
  # yes    yes     yes                X     X      X
  
    
  resize <- !is.null(width) || !is.null(height)
  havescene <- !missing(scene)
  
  if (havescene) {
    if (inherits(scene, "rglWebGL")) {
      snapshot <- scene$x$snapshot
      if (!is.null(snapshot) && is.null(width) && is.null(height))
        return(saveURI(snapshot, filename))
      else
        scene <- attr(scene, "origScene")
    }
  }
  if (!havescene && webshot)
    scene <- scene3d()
  
  if ((!havescene && resize && webshot)
      || (havescene && (resize || !webshot))) {
    open3d()
    plot3d(scene)
    on.exit(close3d(), add = TRUE)
  }
  if (resize) {
    saverect <- rect <- par3d("windowRect")
    on.exit(par3d(windowRect = saverect), add = TRUE)
    if (!is.null(width))
      rect[3] <- rect[1] + width
    if (!is.null(height))
      rect[4] <- rect[2] + height
    par3d(windowRect = rect)
  }
  if (webshot) {
    if (resize)
      scene <- scene3d()
    rect <- par3d("windowRect")
    f1 <- tempfile(fileext = ".html")
    on.exit(unlink(f1), add = TRUE)
    width <- rect[3] - rect[1]
    height <- rect[4] - rect[2]
    saveWidget(rglwidget(scene,
                         elementId = "webshot",
                         width = width,
                         height = height,
                         webgl = TRUE), 
               f1)
    unlink(filename)
    res <- try(capture.output(webshot2::webshot(f1, file = filename, selector = "#webshot",
                        vwidth = width + 100, vheight = height, ...),
                   type = "message"))
    if (!inherits(res, "try-error") && file.exists(filename) && file.size(filename) > 0)
      return(invisible(filename))
    
    warning("webshot2::webshot() failed; trying rgl.snapshot()")
  }
  rgl.snapshot(filename, fmt, top)
}
