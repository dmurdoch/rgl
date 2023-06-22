arc3d <- function(from, to, center, radius, n, circle = 50, base = 0, plot = TRUE, ...) {
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
  
  m <- max(nrow(from), nrow(to), nrow(center), length(base))
  base <- rep_len(base, m)
  
  result <- matrix(NA_real_, nrow = 1, ncol = 3)
  
  for (j in seq_len(m)) {
  	from1 <- getrow(from, j)
  	to1 <- getrow(to, j)
  	center1 <- getrow(center, j)
  	# The "arc" might be a straight line
  	if (isTRUE(all.equal(from1, center1)) || 
  			isTRUE(all.equal(to1, center1)) ||
  			isTRUE(all.equal(normalize(from1 - center1), 
  											 normalize(to1 - center1)))) {
  		result <- rbind(result, from1, to1) 	
  	} else {
  		base1 <- base[j]
  		logr1 <- log(veclen(from1 - center1))
  		logr2 <- log(veclen(to1 - center1))
  		A <- normalize(from1 - center1)
  		B <- normalize(to1 - center1)
  		steps <- if (base1 <= 0) 4*abs(base1) + 1 else 4*base1 - 1
  		for (k in seq_len(steps)) {
  			if (k %% 2) {
  				A1 <- A * (-1)^(k %/% 2)
  				B1 <- B * (-1)^(k %/% 2 + (base1 > 0))
  			} else {
  				A1 <- B * (-1)^(k %/% 2 + (base1 <= 0))
  				B1 <- A * (-1)^(k %/% 2)
  			}
  			theta <- acos(sum(A1*B1))
  			if (isTRUE(all.equal(theta, pi)))
  				warning("Arc ", j, " points are opposite each other!  Arc is not well defined.")
  			if (missing(n))
  				n1 <- ceiling(circle*theta/(2*pi))
  			else
  				n1 <- n
  			
  			if (missing(radius)) {
  				pretheta <- (k %/% 2)*pi - (k %% 2 == 0)*theta
  				if (k == 1)
  					totaltheta <- (steps %/% 2)*pi - (steps %% 2 == 0)*theta + theta
  				p1 <- pretheta/totaltheta
  				p2 <- (pretheta + theta)/totaltheta
  				radius1 <- exp(seq(from = (1 - p1)*logr1 + p1*logr2,
  													 to   = (1 - p2)*logr1 + p2*logr2,
  													 length.out = n1 + 1))
  			} else
  				radius1 <- rep_len(radius, n1 + 1)
  			arc <- matrix(NA_real_, nrow = n1 + 1, ncol = 3)
  			p <- seq(0, 1, length.out = n1 + 1)
  			arc[1,] <- center1 + radius1[1]*A1
  			arc[n1 + 1,] <- center1 + radius1[n1 + 1]*B1
  			AB <- veclen(A1 - B1)
  			for (i in seq_len(n1)[-1]) {
  				ptheta <- p[i]*theta
  				phi <- pi/2 + (0.5 - p[i])*theta
  				q <- (sin(ptheta) / sin(phi))/AB
  				D <- (1-q)*A1 + q*B1
  				arc[i,] <- center1 + radius1[i] * normalize(D)
  			}
  			if (k == 1)
  				result <- rbind(result, arc)
  			else
  				result <- rbind(result[-nrow(result), ,drop = FALSE], arc)
  		}
  	}
  	result <- rbind(result, result[1,])  
  }
  if (plot)
  	lines3d(result[c(-1, -nrow(result)), , drop = FALSE], ...)
  else
  	result[c(-1, -nrow(result)), , drop = FALSE]
}
