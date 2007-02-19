ellipse3d <- function (x, ...) 
  UseMethod("ellipse3d")

ellipse3d.default <-
  function (x, scale = c(1, 1, 1), centre = c(0, 0, 0), level = 0.95, 
            t = sqrt(qchisq(level, 3)), which = 1:3, subdivide = 3, smooth = TRUE, ...) 
{
  stopifnot(is.matrix(x))
  
  cov <- x[which, which]
  chol <- chol(cov)

  sphere <- subdivision3d(cube3d(...), subdivide) 
  norm <- sqrt( sphere$vb[1,]^2 + sphere$vb[2,]^2 + sphere$vb[3,]^2 )
  for (i in 1:3) sphere$vb[i,] <- sphere$vb[i,]/norm
  sphere$vb[4,] <- 1
  sphere$normals <- sphere$vb
  
  result <-scale3d(transform3d( sphere, chol), t,t,t)
  
  if (!missing(scale)) 
    result <- scale3d(result, scale[1], scale[2], scale[3])
  if (!missing(centre))
    result <- translate3d(result, centre[1], centre[2], centre[3])
  return(result)
}

ellipse3d.lm <-
  function (x, which = 1:3, level = 0.95, t = sqrt(3 * qf(level, 
                                                3, x$df.residual)), ...) 
{
  s <- summary(x)  
  names <- names(x$coefficients[which])
  structure(c(ellipse3d.default(s$sigma^2 * s$cov.unscaled[which, which], 
                              centre = x$coefficients[which], t = t, ...),
              xlab=names[1], ylab=names[2], zlab=names[3]), class="qmesh3d")
}

ellipse3d.glm <- function (x, which = 1:3, level = 0.95, t, dispersion, ...) 
{
  s <- summary(x)
  est.disp <- missing(dispersion) & !(x$family$family %in% c('poisson','binomial'))
  if (missing(dispersion)) dispersion <- s$dispersion
  if (missing(t)) t <- ifelse(est.disp,sqrt(3 * qf(level, 3, s$df[2])),
			                           sqrt(qchisq(level, 3)))
			                           
  names <- names(x$coefficients[which])			                           
  structure(c(ellipse3d.default(dispersion * s$cov.unscaled[which, which], 
                  centre = x$coefficients[which], t = t, ...),
              xlab=names[1], ylab=names[2], zlab=names[3]), class="qmesh3d")
}

ellipse3d.nls <- function (x, which = 1:3, level = 0.95, t = sqrt(3 * qf(level, 
                                                3, s$df[2])), ...) 
{
  s <- summary(x)  
  names <- names(x$m$getPars()[which])
  structure(c(ellipse3d.default(s$sigma^2 * s$cov.unscaled[which, which], 
                  centre = x$m$getPars()[which], t = t, ...),
	      xlab=names[1], ylab=names[2], zlab=names[3]), class="qmesh3d")                  
}

