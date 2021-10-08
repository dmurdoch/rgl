plot3d <- function(x, ...) UseMethod("plot3d")


plot3d.default <- function(x, y = NULL, z = NULL, 
        xlab = NULL, ylab = NULL, zlab = NULL, type = 'p', 
        col = material3d("color")[1], size = material3d("size"), 
        lwd = material3d("lwd"),
        radius = avgscale*size/60, add = FALSE, aspect = !add, 
        xlim = NULL, ylim = NULL, zlim = NULL,
        forceClipregion = FALSE, ...) {
    if (!add) next3d()
    skip <- par3d(skipRedraw=TRUE)
    on.exit(par3d(skip))
     	
    xlabel <- if (!missing(x)) deparse(substitute(x))
    ylabel <- if (!missing(y)) deparse(substitute(y))
    zlabel <- if (!missing(z)) deparse(substitute(z))
 
    xyz <- xyz.coords(x,y,z, xlab=xlabel, ylab=ylabel, zlab=zlabel, recycle=TRUE)
    x <- xyz$x
    y <- xyz$y
    z <- xyz$z

    if (is.null(xlab)) xlab <- xyz$xlab
    if (is.null(ylab)) ylab <- xyz$ylab
    if (is.null(zlab)) zlab <- xyz$zlab

    if (type == "s" && missing(radius)) {
      xvals <- x
      yvals <- y
      zvals <- z
      if (add && diff(bbox <- par3d("bbox"))[1] > 0) {
        xvals <- c(x, bbox[1:2])
        yvals <- c(y, bbox[3:4])
        zvals <- c(z, bbox[5:6])
      } 
      if (!add) {
        if (!is.null(xlim)) 
          xvals <- xlim
        if (!is.null(ylim))
          yvals <- ylim
        if (!is.null(zlim))
          zvals <- zlim
      }
	    avgscale <- sqrt(sum(c(diff(range(xvals,na.rm=TRUE)), 
                             diff(range(yvals,na.rm=TRUE)), 
                             diff(range(zvals,na.rm=TRUE)))^2/3))
    }
    savesubscene <- currentSubscene3d()
    result <- setClipregion(xlim, ylim, zlim, forceClipregion)
    result <- c(result, data=switch(type,
		p = points3d(x, y, z, color=col, size=size, ...),
	        s = spheres3d(x, y, z, radius=radius, color=col, ...),
		l = lines3d(x, y, z, color=col, lwd=lwd, ...),
		h = segments3d(rep(x,rep(2,length(x))),
					   rep(y,rep(2,length(y))),
					   rbind(rep(0,length(z)),z),
					   color = rep(col, rep(2,length(col))), lwd=lwd, ...),
	# this is a hack to plot invisible segments
        n = if (!add) segments3d(rep(range(x, na.rm=TRUE), c(2,2)),
                                 rep(range(y, na.rm=TRUE), c(2,2)),
                                 rep(range(z, na.rm=TRUE), c(2,2))))
	)
    useSubscene3d(savesubscene)
    if (!add) {
    	result <- c(result, decorate3d(xlab=xlab, ylab=ylab, zlab=zlab, aspect = aspect, 
                                       xlim=xlim, ylim=ylim, zlim=zlim, ...))
    	highlevel(result)
    } else 
    	lowlevel(result)
}

plot3d.mesh3d <- function(x, xlab = "x", ylab = "y", zlab = "z", type = c("shade", "wire", "dots"),
	add = FALSE, aspect = !add, ...) {
    if (!add) next3d()
    skip <- par3d(skipRedraw=TRUE)
    on.exit(par3d(skip))
    
    if (missing(xlab) && !is.null(x$xlab)) xlab <- x$xlab
    if (missing(ylab) && !is.null(x$ylab)) ylab <- x$ylab
    if (missing(zlab) && !is.null(x$zlab)) zlab <- x$zlab
    
    result <- switch(match.arg(type),
    	shade = shade3d(x, ...),
    	wire = wire3d(x, ...),
    	dots = dot3d(x, ...))
    
    if (!add) {
    	result <- c(result, decorate3d(xlab = xlab, ylab = ylab, zlab = zlab, aspect = aspect,
    	                               ...))
    	highlevel(result)
    } else 
    	lowlevel(result)
}

decorate3d <- function(xlim = NULL, ylim = NULL, zlim = NULL, 
                       xlab = "x", ylab = "y", zlab = "z", 
                       box = TRUE, axes = TRUE, main = NULL, sub = NULL,
                       top = TRUE, aspect = FALSE, expand = 1.03, tag = material3d("tag"), ...) {
  
  if (is.logical(aspect)) {
    autoscale <- aspect
    aspect <- c(1,1,1)
  } else autoscale <- TRUE	
  
  result <- numeric(0)    
  if (length(c(xlim, ylim, zlim))) {
    ranges <- .getRanges()        
    if (is.null(xlim))
      xlim <- ranges$xlim
    if (is.null(ylim))
      ylim <- ranges$ylim
    if (is.null(zlim))
      zlim <- ranges$zlim
    ind <- c(1,1,2,2)
    result <- c(result, strut=segments3d(xlim[ind], ylim[ind], zlim[ind], tag = tag))
  }
  
  if (autoscale) aspect3d(aspect)
  
  if (axes) result <- c(result, axes=axes3d(box=box, expand=expand, tag = tag))
  result <- c(result, title3d(xlab = xlab, ylab = ylab, zlab = zlab, 
                              main = main, sub = sub, tag = tag))
  
  if (top) rgl.bringtotop()
  
  lowlevel(result)
}

plot3d.function <- function(x, ...) persp3d(x, ...)

plot3d.deldir <- function(x, ...) persp3d(x, ...)

plot3d.triSht <-
plot3d.tri <- function(x, z, ...) persp3d(x, z, ...)

plot3d.formula <- function(x, data = NULL, xlab = xyz$xlab, ylab = xyz$ylab, zlab = xyz$zlab, ...) {
  if (!is.null(data))
    environment(x) <- list2env(data, envir = environment(x))
  xyz <- xyz.coords(x)
  plot3d(xyz, xlab = xlab, ylab = ylab, zlab = zlab, ...)
}

plot3d.lm <- function(x, which = 1, 
                      plane.col = "gray", plane.alpha = 0.5,
                      sharedMouse = TRUE,
                      use_surface3d, do_grid = TRUE,
                      grid.col = "black", grid.alpha = 1,
                      grid.steps = 5,
                      sub.steps = 4,
                      vars = get_all_vars(terms(x), x$model),
                      clip_to_density = 0,
                      ...) {
  stopifnot(which %in% 1:3)
  dots <- list(...)
  n <- length(which)
  if (clip_to_density > 0) {
    if (!requireNamespace("MASS", quietly = TRUE)) {
      warning("'clip_to_density' requires the MASS package.")
      clip_to_density <- 0
    }
    if (!requireNamespace("akima", quietly = TRUE)) {
      warning("'clip_to_density' requires the akima package.")
      clip_to_density <- 0
    }
  }
  result <- NULL
  if (n > 1) {
    cols <- ceiling(sqrt(n))
    rows <- ceiling(n/cols)
    mfrow3d(rows, cols, sharedMouse = sharedMouse)
  }
  fit <- x
  missing_vars <- missing(vars)
  cols <- ncol(vars)
  if (cols < 3)
    stop("Model has only ", cols, " variables.")
  if (cols > 3)
    warning("Model has ", cols, " variables; first 3 used.")
  observed <- vars[, c(2, 3, 1)]
  names <- colnames(observed)
  if (is.null(dots$xlab)) dots$xlab <- names[1]
  if (is.null(dots$ylab)) dots$ylab <- names[2]
  if (is.null(dots$zlab)) dots$zlab <- names[3]

  if (missing(use_surface3d)) 
    use_surface3d <- !identical(class(fit), "lm") || ncol(as.matrix(model.frame(fit))) > 3
  
  if (clip_to_density > 0) {
    densityVals <- MASS::kde2d(observed[,1], observed[,2])
    densityVals$z <- with(densityVals, z/max(z)) # nolint
    density <- function(xyz) {
      with(densityVals, akima::bilinear(x, y, z, xyz[,1], xyz[,2])$z) # nolint
    }
  }
  
  plotGrid <- function(i, x, y, x0, y0, z) {
    dots$color <- grid.col
    dots$alpha <- grid.alpha
    dots$color <- grid.col
    dots$alpha <- grid.alpha
    dots$front <- dots$back <- dots$polygon_offset <- 
      dots$type <- NULL

    lenx <- length(x)
    lenx0 <- length(x0)
    leny <- length(y)
    leny0 <- length(y0)
    
    x <- c(rep(x0, each = leny + 1),
           rep(c(x, NA), leny0))
    y <- c(rep(c(y, NA), lenx0),
           rep(y0, each = lenx + 1))
    if (missing(z)) {
      newdat <- data.frame(x, y)
      names(newdat) <- names[1:2]
      z <- predict(fit, newdata = newdat)
    }
    grid <- do.call(lines3d, c(list(x, y, z), dots))
    if (clip_to_density > 0)
      grid <- clipObj3d(grid, density, clip_to_density,
                        minVertices = 1000)
    names(grid) <- paste0("grid.", i)
    grid
  }
  
  plotPoints <- function(i, points, zlab) {
    dots$zlab <- zlab
    plot <- do.call(plot3d, c(list(x = points), dots))
    names(plot) <- paste0(names(plot), ".", i)
    plot
  }
  
  plotSurface <- function(i) {
    bbox <- par3d("bbox")
    xlim <- c(bbox[1], bbox[2])
    x0 <- pretty(xlim, grid.steps)
    ylim <- c(bbox[3], bbox[4])
    y0 <- pretty(ylim, grid.steps)
    if (sub.steps > 1) {
      x <- rep(x0, each = sub.steps) + 
           seq(0, diff(x0[1:2]), length.out = sub.steps + 1)[-(sub.steps + 1)]
      y <- rep(y0, each = sub.steps) + 
        seq(0, diff(y0[1:2]), length.out = sub.steps + 1)[-(sub.steps + 1)]
    } else {
      x <- x0
      y <- y0
    }
    x <- c(xlim[1], x[xlim[1] < x & x < xlim[2]], xlim[2])
    y <- c(ylim[1], y[ylim[1] < y & y < ylim[2]], ylim[2])
    newdat <- expand.grid(x = x, y = y)
    names(newdat) <- names[1:2]
    z <- try(matrix(predict(fit, newdat), length(x), length(y)))
    if (inherits(z, "try-error") && !missing_vars) {
      stop("vars should be in order: response, pred1, pred2", call. = FALSE)
    }
    dots$color <- plane.col
    dots$alpha <- plane.alpha
    if (is.null(dots$polygon_offset)) 
      dots$polygon_offset <- 1
    dots$type <- NULL
    surface <- do.call("surface3d", c(list(x, y, z), dots))
    if (clip_to_density > 0)
      surface <- clipObj3d(surface, density, clip_to_density,
                        minVertices = 1000)
    names(surface) <- paste0("surface.", i)
    grid <- if (do_grid) {
      x0 <- x0[xlim[1] <= x0 & x0 <= xlim[2]]
      y0 <- y0[ylim[1] <= y0 & y0 <= ylim[2]]
      plotGrid(i, x, y, x0, y0)
    }
    c(surface, grid)
  }
  plotPlane <- function(i, a, b, d) {
    c <- -1
    if (is.na(d))
      d <- 0
    dots$color <- plane.col
    dots$alpha <- plane.alpha
    if (is.null(dots$polygon_offset)) 
      dots$polygon_offset <- 1
    dots$type <- NULL
    plane <- do.call("planes3d", c(list(a = a, b = b, c = c, d = d), dots))
    if (clip_to_density > 0)
      plane <- clipObj3d(plane, density, clip_to_density,
                        minVertices = 1000)
    names(plane) <- paste0("plane.", i)
    grid <- if (do_grid) {
      bbox <- par3d("bbox")
      xlim <- c(bbox[1], bbox[2])
      x0 <- pretty(xlim, grid.steps)
      ylim <- c(bbox[3], bbox[4])
      y0 <- pretty(ylim, grid.steps)
      x0 <- x0[xlim[1] <= x0 & x0 <= xlim[2]]
      y0 <- y0[ylim[1] <= y0 & y0 <= ylim[2]]
      if (isTRUE(all.equal(c(a,b,d), c(0, 0, 0))))
        plotGrid(i, xlim, ylim, x0, y0, z = 0)
      else
        plotGrid(i, xlim, ylim, x0, y0)      
    }
    c(plane, grid)
  }
  for (i in seq_along(which)) {
    type <- which[i]
    if (type == 1L) {
      plot <- plotPoints(i, observed, dots$zlab)
      if (use_surface3d) {
        plane <- plotSurface(i)
      } else {
        coefs <- coef(fit)
        plane <- plotPlane(i, coefs[names[1]], coefs[names[2]], coefs["(Intercept)"])
      }
    } else if (type == 2L) {
      plot <- plotPoints(i, cbind(observed[,1:2], residuals(fit)), "Residuals")
      plane <- plotPlane(i, 0, 0, 0)
    } else if (type == 3L) {
      plot <- plotPoints(i, cbind(observed[,1:2], predict(fit)), dots$zlab)
      if (use_surface3d) {
        plane <- plotSurface(i)
      } else {
        coefs <- coef(fit)
        plane <- plotPlane(i, coefs[names[1]], coefs[names[2]], coefs["(Intercept)"])
      } 
    }
    result <- c(result, plot, plane)
  }
  highlevel(result)
}
