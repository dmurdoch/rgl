arc3d <- function(from, to, center, radius, n, circle = 50, ...) {
  fixarg <- function(arg) {
    if (is.matrix(arg))
      arg[, 1:3, drop = FALSE]
    else
      matrix(arg, 1, 3)
  }
  normalize <- function(v)
    v / veclen(v)
  getrow <- function(arg, i) {
    arg[1 + (i - 1) %% nrow(arg),]
  }
  from <- fixarg(from)
  to <- fixarg(to)
  center <- fixarg(center)

  m <- max(nrow(from), nrow(to), nrow(center))
  result <- matrix(NA_real_, nrow = 1, ncol = 3)
  
  for (j in seq_len(m)) {
    from1 <- getrow(from, j)
    to1 <- getrow(to, j)
    center1 <- getrow(center, j)
    A <- normalize(from1 - center1)
    B <- normalize(to1 - center1)
    theta <- acos(sum(A*B))
    if (isTRUE(all.equal(theta, pi)))
      warning("Arc ", j, " points are opposite each other!  Arc is not well defined.")
    if (missing(n))
      n1 <- ceiling(circle*theta/(2*pi))
    else
      n1 <- n
    if (missing(radius)) radius1 <- exp(seq(from = log(veclen(from1 - center1)),
                                           to = log(veclen(to1 - center1)),
                                           length.out = n1 + 1))
    else
      radius1 <- rep_len(radius, n1)
    arc <- matrix(NA_real_, nrow = n1 + 1, ncol = 3)
    p <- seq(0, 1, length.out = n1 + 1)
    arc[1,] <- center1 + radius1[1]*A
    arc[n1 + 1,] <- center1 + radius1[n1 + 1]*B
    AB <- veclen(A - B)
    for (i in seq_len(n1)[-1]) {
      ptheta <- p[i]*theta
      phi <- pi/2 + (0.5 - p[i])*theta
      q <- (sin(ptheta) / sin(phi))/AB
      D <- (1-q)*A + q*B
      arc[i,] <- center1 + radius1[i] * normalize(D)
    }
    result <- rbind(result, arc, result[1,])
  }
  lines3d(result[c(-1, -nrow(result)), , drop=FALSE], ...)
}
