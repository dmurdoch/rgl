plot3d <- function(x, ...) UseMethod("plot3d")


plot3d.default <- function(x, y = NULL, z = NULL, 
        xlab = NULL, ylab = NULL, zlab = NULL, type = 'p', 
        col = material3d("color")[1], size = material3d("size"), 
        lwd = material3d("lwd"),
        radius = avgscale*size/60, add = FALSE, aspect = !add, 
        xlim = NULL, ylim = NULL, zlim = NULL,
        forceClipregion = FALSE, ...)
{
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
	avgscale <- sqrt(sum(c(diff(range(x,na.rm=TRUE)), 
                               diff(range(y,na.rm=TRUE)), 
                               diff(range(z,na.rm=TRUE)))^2/3))
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
	add = FALSE, aspect = !add, ...)
{
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
                       top = TRUE, aspect = FALSE, expand = 1.03, ...) {
  
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
    result <- c(result, strut=segments3d(xlim[ind], ylim[ind], zlim[ind]))
  }
  
  if (autoscale) aspect3d(aspect)
  
  if (axes) result <- c(result, axes=axes3d(box=box, expand=expand))
  result <- c(result, title3d(xlab = xlab, ylab = ylab, zlab = zlab, 
                              main = main, sub = sub))
  
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
                      ...) {
  stopifnot(which %in% 1:3)
  dots <- list(...)
  n <- length(which)
  result <- c()
  if (n > 1) {
    cols <- ceiling(sqrt(n))
    rows <- ceiling(n/cols)
    mfrow3d(rows, cols, sharedMouse = sharedMouse)
  }
  fit <- x
  formula <- formula(fit)
  if (!is.null(fit$call$data)) {
    data <- eval(fit$call$data, environment(formula))
    environment(formula) <- list2env(data, parent=environment(formula))
  }
  xyz <- xyz.coords(formula)
  if (is.null(dots$xlab)) dots$xlab <- xyz$xlab
  if (is.null(dots$ylab)) dots$ylab <- xyz$ylab
  if (is.null(dots$zlab)) dots$zlab <- xyz$zlab
  for (i in seq_along(which)) {
    type <- which[i]
    if (type == 1L) {
      coefs <- coef(fit)
      a <- coefs[xyz$xlab]
      b <- coefs[xyz$ylab]
      c <- -1
      d <- coefs["(Intercept)"]
      plot <- do.call("plot3d", c(list(x = xyz), dots))
      dots1 <- dots
      dots1$col <- plane.col
      dots1$alpha <- plane.alpha
      plane <- do.call("planes3d", c(list(a = a, b = b, c = c, d =d), dots1))
    } else if (type == 2L) {
      dots1 <- dots
      dots1$zlab <- "Residuals"
      xyz1 <- xyz
      xyz1$z <- residuals(fit)
      plot <- do.call("plot3d", c(list(x = xyz1), dots1))
      names(plot) <- paste0(names(plot), ".", i)
      dots1$col <- plane.col
      dots1$alpha <- plane.alpha
      plane <- do.call("planes3d", c(list(a = 0, b = 0, c = -1, d = 0), dots1))
    } else if (type == 3L) {
      coefs <- coef(fit)
      a <- coefs[xyz$xlab]
      b <- coefs[xyz$ylab]
      c <- -1
      d <- coefs["(Intercept)"]
      xyz1 <- xyz
      xyz1$z <- predict(fit)
      dots1 <- dots
      dots1$zlab <- "Predicted"
      plot <- do.call("plot3d", c(list(x = xyz1), dots1))
      dots1 <- dots
      dots1$col <- plane.col
      dots1$alpha <- plane.alpha
      plane <- do.call("planes3d", c(list(a = a, b = b, c = c, d =d), dots1))      
    }
    names(plot) <- paste0(names(plot), ".", i)
    names(plane) <- paste0("plane.", i)
    result <- c(result, plot, plane)
  }
  highlevel(result)
}

