merge.mesh3d <- function(x, y, ..., attributesMustMatch = FALSE) {
  fixmesh <- function(m) {
    stopifnot(inherits(m, "mesh3d"))
    if (nrow(m$vb) == 3)
      m$vb <- rbind(m$vb, 1)
    if (!length(m$ip))
      m$ip <- matrix(numeric(), nrow=1, ncol=0)
    if (!length(m$is))
      m$is <- matrix(numeric(), nrow=2, ncol=0)
    if (!length(m$it))
      m$it <- matrix(numeric(), nrow=3, ncol=0)
    if (!length(m$ib))
      m$ib <- matrix(numeric(), nrow=4, ncol=0)
    if (!is.null(m$normals) && nrow(m$normals) == 3)
      m$normals <- rbind(m$normals, 1)
    if (is.null(m$meshColor))
      m$meshColor <- "vertices"
    if (!is.null(m$material)) {
      n <- switch(m$meshColor,
                  vertices = ncol(m$vb),
                  edges = NCOL(m$is),
                  faces = NCOL(m$it) + NCOL(m$ib),
                  legacy = 3*NCOL(m$it) + 4*NCOL(m$ib))
      if (length(m$material$color) == 1)
        m$material$color <- rep(m$material$color, n)
      if (length(m$material$alpha) == 1)
        m$material$alpha <- rep(m$material$alpha, n)
    } else
      m$material <- list()
    m
  }
  z <- fixmesh(x)
  ylist <- list(...)
  if (!missing(y))
    ylist <- c(list(y), ylist)
  for (i in seq_along(ylist)) {
    x <- z
    y <- fixmesh(ylist[[i]])
    if (!attributesMustMatch) {
      common <- intersect(names(x), names(y))
      x <- x[common]
      y <- y[common]
    }
    stopifnot(is.null(x$normals) == is.null(y$normals),
              is.null(x$texcoords) == is.null(y$texcoords),
              is.null(x$values) == is.null(y$values))
    stopifnot(x$meshColor == y$meshColor)

    nx <- ncol(x$vb)
    z <- list(vb = cbind(x$vb, y$vb),
              ip = if (length(x$ip) || length(y$ip)) cbind(x$ip, y$ip + nx),
              is = if (length(x$is) || length(y$is)) cbind(x$is, y$is + nx),
              it = if (length(x$it) || length(y$it)) cbind(x$it, y$it + nx),
              ib = if (length(x$ib) || length(y$ib)) cbind(x$ib, y$ib + nx),
              normals = cbind(x$normals, y$normals),
              texcoords = cbind(x$texcoords, y$texcoords),
              values = c(x$values, y$values),
              meshColor = x$meshColor)
    if (!attributesMustMatch) {
      common <- intersect(names(x$material), names(y$material))
      x$material <- x$material[common]
      y$material <- y$material[common]
      for (n in common) {
        if (!(n %in% c("color", "alpha")) &&
            !identical(x$material[[n]], y$material[[n]])) 
          x$material[[n]] <- NULL
      }
    } else {
        stopifnot(setequal(names(x$material), names(y$material)))
        for (n in names(x$material))
          if (!identical(x$material[[n]], y$material[[n]]))
            stop("Material ", n, " values don't match")
    }
    z$material <- x$material
    z$material$color <- c(x$material$color, y$material$color)
    z$material$alpha <- c(x$material$alpha, y$material$alpha)
    class(z) <- "mesh3d"
  }
  if (!is.null(z$material)) {
    if (length(unique(z$material$color)) == 1)
      z$material$color <- z$material$color[1]
    if (length(unique(z$material$alpha)) == 1)
      z$material$alpha <- z$material$alpha[1]
  }
  if (!length(z$material$color))
    z$material$color <- NULL
  if (!length(z$material))
    z$material <- NULL
  if (!length(z$ip))
    z$ip <- NULL
  if (!length(z$is))
    z$is <- NULL
  if (!length(z$it))
    z$it <- NULL
  if (!length(z$ib))
    z$ib <- NULL
  z
}
