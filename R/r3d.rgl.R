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
    rgl.clear( type, subscene = subscene )

    type <- rgl.enum.nodetype(type)
    if ( 4 %in% type ) { # userviewpoint
	do.call("par3d", defaults["FOV"])
    }
    if ( 8 %in% type ) { # modelviewpoint
        do.call("par3d", defaults["userMatrix"])
    }
    if ( 5 %in% type ) { # material
        if (length(defaults$material))
    	    do.call("material3d", defaults$material)
    }
    if ( 6 %in% type ) { # background
    	do.call("bg3d", as.list(defaults$bg))
    }
}

# Environment

.material3d <- c("color", "alpha", "lit", "ambient", "specular",
    "emission", "shininess", "smooth", "front", "back", "size", 
    "lwd", "fog", "point_antialias", "line_antialias",
    "texture", "textype", "texmipmap",
    "texminfilter", "texmagfilter", "texenvmap",
    "depth_mask", "depth_test", "isTransparent",
    "polygon_offset", "margin", "floating", "tag")

.material3d.readOnly <- "isTransparent"

# This function expands a list of arguments by putting
# all entries from Params (i.e. the current settings by default)
# in place for any entries that are not listed.  
# Unrecognized args are left in place.

.fixMaterialArgs <- function(..., Params = material3d(), col) {
   f <- function(...) list(...)
   dots <- list(...)
   if (!missing(col)) 
     Params$color <- col
   formals(f) <- c(Params, formals(f))
   names <- as.list(names(Params))
   names(names) <- names
   names <- lapply(names, as.name)
   b <- as.list(body(f))
   body(f) <- as.call(c(b[1], names, b[-1]))
   f(...)
} 
     
# This one just gets the material args
# If warn is TRUE, give a warning instead of ignoring extras.

.getMaterialArgs <- function(..., material = list(), warn = FALSE, col = material[["col"]]) {
  fullyNamed <- as.list(match.call(rgl.material, 
                           as.call(c(list(as.name("rgl.material"),
                                        ...), material))))[-1]
  if (!is.null(col) && !("color" %in% names(fullyNamed)))
    fullyNamed$color <- col
  good <- names(fullyNamed) %in% .material3d
  if (warn && !all(good))
    warning("Argument(s) ", paste(names(fullyNamed)[!good], collapse = ", "), " not matched.")
  fullyNamed[good]
}

material3d  <- function(...) {
    args <- list(...)
    argnames <- setdiff(names(args), .material3d.readOnly)
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
    	args <- do.call(".fixMaterialArgs", args)
        do.call("rgl.material", args)
        return(invisible(value))
    } else if (length(argnames) == 1) return(value[[1]])
    else return(value)
}

bg3d        <- function(...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  bgid <- ids3d("background")$id
  if (length(bgid) && nrow(flags <- rgl.attrib(bgid[1], "flags"))) {
    sphere <- flags["sphere", 1]
    fogtype <- if (flags["linear_fog", 1]) "linear"
    else if (flags["exp_fog", 1]) "exp"
    else if (flags["exp2_fog", 1]) "exp2"
    else "none"
  } else {
    sphere <- FALSE
    fogtype <- "none"
  }
  dots <- list(...)
  if ("fogtype" %in% names(dots))
    fogtype <- dots$fogtype
  if ("fogScale" %in% names(dots))
    fogScale <- dots$fogScale
  else
    fogScale <- 1
  new <- .fixMaterialArgs(sphere = sphere, 
                          fogtype = fogtype, 
                          fogScale = fogScale,
                          color = c("black", "white"), 
  			  back = "lines", lit = FALSE, Params = save)
  do.call("rgl.bg", .fixMaterialArgs(..., Params = new))
}

light3d     <- function(theta=0,phi=15,x=NULL, ...) {
  .check3d()
  if (is.null(x))
    rgl.light(theta=theta,phi=phi,x=x, ...)
  else
    rgl.light(x=x, ...)
}

view3d      <- function(theta=0,phi=15,...) {
  .check3d()
  rgl.viewpoint(theta=theta,phi=phi,...)
}

bbox3d	    <- function(xat = NULL, 
                        yat = NULL, 
                        zat = NULL, 
                        xunit = "pretty",
                        yunit = "pretty",
                        zunit = "pretty",
		        expand = 1.03, draw_front = FALSE, ...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.bbox", c(list(xat=xat, yat=yat, zat=zat, 
                             xunit=xunit, yunit=yunit, zunit=zunit, expand=expand,
                             draw_front=draw_front), 
                        .fixMaterialArgs(..., Params = save)))
}

dummyBbox <- function()
  bbox3d(xat = numeric(), yat = numeric(), zat = numeric(),
         front = "cull", back = "cull")

observer3d <- function(x, y=NULL, z=NULL, auto=FALSE) {
  if (missing(x))
    location <- c(NA, NA, NA)
  else {
    xyz <- xyz.coords(x,y,z)
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

text3d      <- function(x, y = NULL, z = NULL,
			texts, adj = 0.5, pos = NULL, offset = 0.5,
			usePlotmath = is.language(texts), ...) {
  if (usePlotmath) 
    return(plotmath3d(x = x, y = y, z = z, text = texts, adj = adj, 
                      pos = pos, offset = offset, ...))
  .check3d(); save <- material3d(); on.exit(material3d(save))
  new <- .fixMaterialArgs(..., Params = save)
  do.call("rgl.texts", c(list(x = x, y = y, z = z, text = texts, 
                              adj = adj, pos = pos,
                              offset = offset), new))
}
texts3d	    <- text3d

spheres3d   <- function(x, y = NULL, z = NULL, radius = 1, fastTransparency = TRUE, ...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.spheres", c(list(x = x, y = y, z = z, 
  															radius = radius, fastTransparency = fastTransparency), .fixMaterialArgs(..., Params = save)))
}

planes3d   <- function(a,b=NULL,c=NULL,d=0,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.planes", c(list(a=a,b=b,c=c,d=d), .fixMaterialArgs(..., Params = save)))
}

clipplanes3d   <- function(a,b=NULL,c=NULL,d=0) {
  .check3d()
  rgl.clipplanes(a=a,b=b,c=c,d=d)
}

abclines3d   <- function(x,y=NULL,z=NULL,a,b=NULL,c=NULL,...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.abclines", c(list(x=x,y=y,z=z,a=a,b=b,c=c), .fixMaterialArgs(..., Params = save)))
}

sprites3d   <- function(x, y = NULL, z = NULL, radius = 1, 
                        shapes = NULL, userMatrix, fixedSize = FALSE,  
                        adj = 0.5, pos = NULL, offset = 0.25,
												...) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  if (missing(userMatrix)) {
    userMatrix <- getr3dDefaults()$userMatrix
    if (is.null(userMatrix)) userMatrix <- diag(4)
  }
  savepar <- par3d(skipRedraw=TRUE, ignoreExtent=TRUE)
  on.exit(par3d(savepar), add=TRUE)
  force(shapes)
  par3d(ignoreExtent=savepar$ignoreExtent)

  do.call("rgl.sprites", c(list(x=x,y=y,z=z,radius=radius,shapes=shapes,
                                userMatrix=userMatrix, fixedSize = fixedSize, 
                                adj = adj, pos = pos, offset = offset), 
          .fixMaterialArgs(..., Params = save)))
}

terrain3d   <- function(x,y=NULL,z=NULL,...,normal_x=NULL,normal_y=NULL,normal_z=NULL) {
  .check3d(); save <- material3d(); on.exit(material3d(save))
  do.call("rgl.surface", c(list(x=x,y=z,z=y,coords=c(1,3,2),
                                normal_x=normal_x,normal_y=normal_z,normal_z=normal_y), 
                           .fixMaterialArgs(..., Params = save)))
}
surface3d   <- terrain3d

# Interaction

select3d    <- function(...) {
  .check3d()
  rgl.select3d(...)
}

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
    if (!is.null(args$antialias) 
        || !is.null(args$antialias <- r3dDefaults$antialias)) {
    	saveopt <- options(rgl.antialias = args$antialias)
    	on.exit(options(saveopt))
    	args$antialias <- NULL
    }
    
    rgl.open(useNULL)
    
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
    rgl.close()
    if (!silent)
      message("Closed device ", d)
  }
  invisible(cur3d())
}

cur3d <- rgl.cur

set3d <- function(dev, silent = FALSE) {
  prev <- cur3d()
  rgl.set(dev, silent = silent)
  prev
}

.check3d <- function() {
    if (result<-cur3d()) return(result)
    else return(open3d())
}

requireWebshot2 <- function() {
  suppressMessages(res <- requireNamespace("webshot2", quietly = TRUE))
  res
}

snapshot3d <- function(filename = tempfile(fileext = ".png"), 
                       fmt = "png", top = TRUE, ..., scene, width = NULL, height = NULL,
                       webshot = TRUE) {
  force(filename)
  
  if (webshot && !requireWebshot2()) {
    warning("webshot = TRUE requires the webshot2 package; using rgl.snapshot() instead")
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
    capture.output(webshot2::webshot(f1, file = filename, selector = "#webshot",
                        vwidth = width + 100, vheight = height, ...),
                   type = "message")
    invisible(filename)
  } else
    rgl.snapshot(filename, fmt, top)
}
