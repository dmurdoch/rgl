addNormals <- function(x, ...) UseMethod("addNormals")
  
addNormals.mesh3d <- function(x, angleWeighted = TRUE, ...) {
  v <- x$vb
  
  # Make sure v is homogeneous with unit w
  if (nrow(v) == 3) v <- rbind(v, 1)
  else v <- t( t(v)/v[4,] )
  
  v <- v[1:3,]
  normals <- v*0
  
  if (is.na(angleWeighted)) {
    reproduceBug <- TRUE
    angleWeighted <- FALSE
  } else
    reproduceBug <- FALSE
  
  dopolys <- function(it, normals) {
    n <- nrow(it)
    for (i in seq_len(ncol(it))) {
      normal <- xprod( v[, it[1, i]] - v[, it[3, i]], 
                       v[, it[2, i]] - v[, it[1, i]])
      if (reproduceBug)
        normal <- normalize(normal)
      if (!any(is.na(normal))) {
        if (angleWeighted) 
          normal <- normalize(normal)
        
        for (j in seq_len(n)) {
          if (angleWeighted) {
            jm1 <- (j + n - 2) %% n + 1
            jp1 <- j %% n + 1
            weight <- angle(v[, it[jm1, i]] - v[, it[j, i]],
                           v[, it[jp1, i]] - v[, it[j, i]])
          } else
            weight <- 1
          normals[, it[j,i]] <- normals[, it[j,i]] + normal*weight
        }
      }
    }
    normals
  }
  
  if (length(x$it)) 
    normals <- dopolys(x$it, normals)
  
  if (length(x$ib)) 
    normals <- dopolys(x$ib, normals)
  normals <- rbind(apply(normals, 2, function(n) n/veclen(n)), 1)
  x$normals <- normals
  x
}

veclen <- function(v) sqrt(sum(v^2))

normalize <- function(v) v/veclen(v)

xprod <- function(v, w) c( v[2]*w[3] - v[3]*w[2],
                           v[3]*w[1] - v[1]*w[3],
                           v[1]*w[2] - v[2]*w[1] )

angle <- function(a,b) {
  dot <- sum(a*b)
  acos(pmin(1, pmax(-1, dot/veclen(a)/veclen(b))))
}
