addNormals <- function(x, ...) UseMethod("addNormals")
  
addNormals.mesh3d <- function(x, ...) {
  v <- x$vb
  
  # Make sure v is homogeneous with unit w
  if (nrow(v) == 3) v <- rbind(v, 1)
  else v <- t( t(v)/v[4,] )
  
  normals <- v*0
  v <- v[1:3,]
  
  if (length(x$it)) {
    it <- x$it
    for (i in seq_len(ncol(it))) {
      normal <- normalize(xprod( v[, it[1, i]] - v[, it[3, i]], 
                                 v[, it[2, i]] - v[, it[1, i]]))
      if (!any(is.na(normal)))
        for (j in 1:3) {
          if (sum(normals[1:3, it[j,i]]*normal) < 0)
      	    normals[, it[j,i]] <- normals[, it[j,i]] + c(-normal, 1)
      	  else
            normals[, it[j,i]] <- normals[, it[j,i]] + c(normal, 1)
        }
    }
  }
  
  if (length(x$ib)) {
    it <- x$ib
    for (i in seq_len(ncol(it))) {
      normal <- normalize(xprod( v[, it[1, i]] - v[, it[4, i]],
                                 v[, it[2, i]] - v[, it[1, i]]))
      if (!any(is.na(normal)))
        for (j in 1:4) {
      	  if (sum(normals[1:3, it[j,i]]*normal) < 0)
      	    normals[, it[j,i]] <- normals[, it[j,i]] + c(-normal, 1)
      	  else
            normals[, it[j,i]] <- normals[, it[j,i]] + c(normal, 1)
        }
    }
  }
  normals <- t( t(normals)/normals[4,] )
  x$normals <- normals
  x
}

veclen <- function(v) sqrt(sum(v^2))

normalize <- function(v) v/veclen(v)

xprod <- function(v, w) c( v[2]*w[3] - v[3]*w[2],
                           v[3]*w[1] - v[1]*w[3],
                           v[1]*w[2] - v[2]*w[1] )
