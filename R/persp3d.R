persp3d <- function(x, ...) UseMethod("persp3d")


persp3d.default <-
function(x = seq(0, 1, len = nrow(z)), y = seq(0, 1, len = ncol(z)),
    z, xlim = NULL, ylim = NULL, zlim = NULL,
    xlab = NULL, ylab = NULL, zlab = NULL, add = FALSE, aspect = !add, 
    forceClipregion = FALSE, ...) {
    if (!add) next3d()
    skip <- par3d(skipRedraw=TRUE)
    on.exit(par3d(skip))
    
    if (is.null(xlab))
        xlab <- if (!missing(x)) deparse(substitute(x)) else "X"
    if (is.null(ylab))
        ylab <- if (!missing(y)) deparse(substitute(y)) else "Y"
    if (is.null(zlab))
        zlab <- if (!missing(z)) deparse(substitute(z)) else "Z"
    ## labcex is disregarded since we do NOT yet put  ANY labels...
    if (missing(z)) {
        if (!missing(x)) {
            if (is.list(x)) {
                z <- x$z
                y <- x$y
                x <- x$x
            }
            else {
                z <- x
                x <- seq(0, 1, len = nrow(z))
            }
        }
        else stop("No 'z' matrix specified")
    }
    else if (is.list(x)) {
        y <- x$y
        x <- x$x
    }
    if ( (!is.matrix(x) && any(diff(x) <= 0)) 
      || (!is.matrix(y) && any(diff(y) <= 0)))
        stop("Increasing 'x' and 'y' values expected")
        
    savesubscene <- currentSubscene3d()
    result <- setClipregion(xlim, ylim, zlim, forceClipregion)
    result <- c(result, surface=surface3d(x,y,z,...))
    useSubscene3d(savesubscene)
    if (!add) {
      result <- c(result, decorate3d(xlim = xlim, ylim = ylim, zlim = zlim, 
                          xlab = xlab, ylab = ylab, zlab = zlab, aspect = aspect, ...))
      highlevel(result)
    } else
      lowlevel(result)
}

setClipregion <- function(xlim = NULL, ylim = NULL, zlim = NULL, force = FALSE) {
  if (force || length(c(xlim, ylim, zlim))) {
    listeners <- par3d("listeners")
    result <- c(clipregion = newSubscene3d("inherit", "inherit", "inherit"))
    par3d(listeners = listeners)
    normals <- matrix(nrow = 0, ncol = 3)
    offsets <- numeric()
    if (length(xlim)) {
      normals <- rbind(normals, matrix(c(1, 0, 0,
                                         -1, 0, 0), nrow = 2, byrow = TRUE))
      offsets <- c(offsets, -xlim[1], xlim[2])
    }
    if (length(ylim)) {
      normals <- rbind(normals, matrix(c(0, 1, 0,
                                         0, -1, 0), nrow = 2, byrow = TRUE))
      offsets <- c(offsets, -ylim[1], ylim[2])
    }
    if (length(zlim)) {
      normals <- rbind(normals, matrix(c(0, 0, 1, 
                                         0, 0, -1), nrow = 2, byrow = TRUE))
      offsets <- c(offsets, -zlim[1], zlim[2])
    }
    keep <- is.finite(offsets)
    if (length(offsets[keep]))
      result <- c(result, clipplanes = clipplanes3d(normals[keep,], d = offsets[keep]))
  } else 
    result <- integer()
  lowlevel(result)
}

persp3d.function <- function(x, xlim = c(0,1), ylim = c(0,1), 
                             slim = NULL, tlim = NULL, n = 101,
                             xvals = seq.int(min(xlim), max(xlim), length.out = n[1]), 
                             yvals = seq.int(min(ylim), max(ylim), length.out = n[2]), 
                             svals = seq.int(min(slim), max(slim), length.out = n[1]), 
                             tvals = seq.int(min(tlim), max(tlim), length.out = n[2]),
                             xlab = NULL, ylab = NULL, zlab = NULL, 
                             col = "gray",
                             otherargs = list(), 
                             normal = NULL, texcoords = NULL, ...) {
  f <- x
  n <- rep(n, length.out = 2)
  parametric <- !is.null(slim) || !is.null(tlim)
  if (!parametric) {
    n1 <- length(xvals)
    n2 <- length(yvals)
    xvals <- matrix(xvals, n1, n2)
    yvals <- matrix(yvals, n1, n2, byrow = TRUE)
    args <- c(list(c(xvals), c(yvals)), otherargs)
    zvals <- do.call(f, args)
    dim(zvals) <- dim(xvals)
    argnames <- names(as.list(f))
    if (is.null(xlab)) xlab <- argnames[1]
    if (is.null(ylab)) ylab <- argnames[2]
    if (is.null(zlab)) zlab <- deparse(substitute(x))
  } else {
    if (is.null(slim)) slim <- c(0,1)
    if (is.null(tlim)) tlim <- c(0,1)
    n1 <- length(svals)
    n2 <- length(tvals)
    svals <- matrix(svals, n1, n2)
    tvals <- matrix(tvals, n1, n2, byrow = TRUE)
    
    args <- c(list(as.numeric(svals), as.numeric(tvals)), otherargs)
    allvals <- do.call(f, args)
    xvals <- matrix(allvals[,1], n1, n2)
    yvals <- matrix(allvals[,2], n1, n2)
    zvals <- matrix(allvals[,3], n1, n2)
    if (!is.null(colnames <- colnames(allvals))) {
      if (is.null(xlab)) xlab <- colnames[1]
      if (is.null(ylab)) ylab <- colnames[2]
      if (is.null(zlab)) zlab <- colnames[3]
    }
  }
  
  if (is.function(col)) {
    zmin <- min(zvals, na.rm = TRUE)
    zscale <- 1/(max(zvals, na.rm = TRUE) - zmin)
    colfn <- colorRamp(col(100))
    colrgba <- colfn(c((zvals - zmin)*zscale))
    colrgba[is.na(colrgba)] <- 0
    col <- rgb(colrgba, maxColorValue = 255)
    dim(col) <- dim(zvals)
  }
  if (is.function(normal)) 
    normal <- do.call(normal, args)	
  if (is.function(texcoords))
    texcoords <- do.call(texcoords, args)
  
  args <- list(xvals, yvals, zvals, col = col, 
               xlab = xlab, ylab = ylab, zlab = zlab, ...)	
  if (is.matrix(normal)) 
    args <- c(args, list(normal_x = matrix(normal[,1], n1, n2),
                         normal_y = matrix(normal[,2], n1, n2),
                         normal_z = matrix(normal[,3], n1, n2)))	
  if (is.matrix(texcoords))
    args <- c(args, list(texture_s = matrix(texcoords[,1], n1, n2),
                         texture_t = matrix(texcoords[,2], n1, n2)))
  if (parametric)
    args <- c(args, list(xlim = if (!missing(xlim)) xlim, 
                         ylim = if (!missing(ylim)) ylim))
  
  do.call(persp3d, args)
}

persp3d.deldir <- function(x, ..., add = FALSE) {
  plot3d(as.mesh3d(x, ...), add = add, ...)
}

persp3d.triSht <-
persp3d.tri <- function(x, z, ..., add = FALSE) {
  plot3d(as.mesh3d(x, z, ...), add = add, ...)
}

checkDeldir <- function(error = FALSE) {
  result <- requireNamespace("deldir", quietly = TRUE) &&
            (packageVersion("deldir") < "1.0.2" ||
             packageVersion("deldir") >= "1.0.4")
  if (error && !result)
    stop("This function requires version 1.0.4 or higher of the 'deldir' package.", call. = FALSE)
  result
}

persp3d.formula <- function(x, data=NULL, xlab = xyz$xlab, ylab = xyz$ylab, zlab = xyz$zlab, ...) {
  checkDeldir(error = TRUE)
  if (!is.null(data))
    environment(x) <- list2env(data, envir = environment(x))
  xyz <- xyz.coords(x)
  dxyz <- with(xyz, deldir::deldir(x, y, z = z, suppressMsge = TRUE)) # nolint
  persp3d(dxyz, xlab = xlab, ylab = ylab, zlab = zlab, ...)
}
