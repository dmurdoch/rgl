GramSchmidt <- function(v1, v2, v3, order=1:3) {
  A <- rbind(v1, v2, v3)
  A <- A[order,]
  v1 <- A[1,]
  v2 <- A[2,]
  v3 <- A[3,]
  if (isTRUE(all.equal(as.numeric(v1), c(0,0,0)))) v1 <- xprod(v2, v3)
  v1 <- normalize(v1)
  v2 <- v2 - sum(v2*v1)*v1
  if (isTRUE(all.equal(as.numeric(v2), c(0,0,0)))) v2 <- xprod(v3, v1)
  v2 <- normalize(v2)
  v3 <- v3 - sum(v3*v1)*v1 - sum(v3*v2)*v2
  if (isTRUE(all.equal(as.numeric(v3), c(0,0,0)))) v3 <- xprod(v1, v2)
  v3 <- normalize(v3)
  rbind(v1, v2, v3)[order(order),]
}

cylinder3d <- function(center, radius=1, twist=0, e1=NULL, e2=NULL, e3=NULL, 
                       sides=8, section=NULL, closed=0, debug=FALSE, keepVars=FALSE) {
  center <- as.matrix(as.data.frame(xyz.coords(center)[c("x", "y", "z")]))
  n <- nrow(center)  
  if (closed > 0) {
    ind0 <- c(n-1-closed, n-closed, 1:n)
    ind1 <- c(n-closed, 1:n, 1+closed)
    ind2 <- c(1:n, 1+closed, 2+closed)
  } else {
    ind0 <- c(1, 1, 1:n)
    ind1 <- c(1, 1:n, n)
    ind2 <- c(1:n, n, n)
  }  
  
  missings <- c(e1=is.null(e1), e2=is.null(e2), e3=is.null(e3))
  
  fixup <- function(coord) {
    usable <- apply(coord, 1, function(v) all(is.finite(v)) & (veclen(v) > 0))
    if (!any(usable) ) stop("No usable coordinate values in", deparse(substitute(coord)))
    firstgood <- min(which(usable))
    inds <- 1:n    
    if (firstgood > 1) {
      coord[inds[inds < firstgood],] <- coord[rep(firstgood,firstgood-1),]
      usable[1:firstgood] <- TRUE
    }
    for (i in 2:n) inds[i] <- ifelse(usable[i], inds[i], inds[i-1])
    coord[inds,]
  }
  
  if (!is.null(e1)) {
    e1 <- as.matrix(as.data.frame(xyz.coords(e1)[c("x", "y", "z")]))
    e1 <- e1[rep(1:nrow(e1), len=n),] 
  } else 
    e1 <- (center[ind2,] - center[ind0,])[1:n,]
  
  # Fix up degenerate cases by repeating existing ones, or using arbitrary ones
  zeros <- rowSums(e1^2) == 0
  if (all(zeros)) {
    e1[,1] <- 1
    zeros <- FALSE
  } else if (any(zeros)) {
    e1[1,] <- e1[which(!zeros)[1],]
    zeros[1] <- FALSE
    if (any(zeros)) {
      zeros <- which(zeros)
      for (i in zeros)
        e1[i,] <- e1[i-1,]
    }
  }
  if (!is.null(e2)) {
    e2 <- as.matrix(as.data.frame(xyz.coords(e2)[c("x", "y", "z")]))
    e2 <- e2[rep(1:nrow(e2), len=n),] 
  } else
    e2 <- (e1[ind2,] - e1[ind0,])[1:n,]
    
  # Fix up degenerate e2's similarly, then force different than e1
  zeros <- rowSums(e2^2) == 0
  if (all(zeros)) {
    e2[,2] <- 1
    zeros <- FALSE
  } else if (any(zeros)) {
    e2[1,] <- e2[which(!zeros)[1],]
    zeros[1] <- FALSE
    if (any(zeros)) {
      zeros <- which(zeros)
      for (i in zeros)
        e2[i,] <- e2[i-1,]
    }
  }
  parallel <- sapply(1:n, function(i) all(xprod(e1[i,], e2[i,])  == 0))
  if (any(parallel)) {
    # rotate in the xy plane
    e2[parallel,] <- cbind(-e2[parallel,2], e2[parallel,1], e2[parallel,3])
    parallel <- sapply(1:n, function(i) all(xprod(e1[i,], e2[i,])  == 0))
    if (any(parallel)) {
      # if any are still parallel, they must be the z axis
      e2[parallel,1] <- 1
      e2[parallel,3] <- 0
    }
  }
  
  if (!is.null(e3)) {
    e3 <- as.matrix(as.data.frame(xyz.coords(e3)[c("x", "y", "z")]))
    e3 <- e3[rep(1:nrow(e3), len=n),] 
  } else {
    e3 <- matrix(NA_real_, n, 3)
    for (i in 1:n) e3[i,] <- xprod(e1[i,], e2[i,])
  }

  for (i in 1:n) {
    A <- GramSchmidt(e1[i,], e2[i,], e3[i,], order=order(missings))
    e1[i,] <- A[1,]
    e2[i,] <- A[2,]
    e3[i,] <- A[3,]
  }
  e1 <- fixup(e1)
  e2 <- fixup(e2)
  e3 <- fixup(e3)

  radius <- rep(radius, len=n)
  twist <- rep(twist, len=n)
  
  if (debug) {
    for (i in 1:n) {
      segments3d(rbind(center[i,],center[i,]+e3[i,]*radius[i]*1.5,
                     center[i,],center[i,]+e2[i,]*radius[i]*1.5,
                     center[i,],center[i,]+e1[i,]*radius[i]*1.5), 
                 col=rep(c("red", "green", "blue"), each=2))
      text3d(center, texts=1:n)
    }
  }
  
  if (closed > 0) n <- n-closed+1
  
  if (is.null(section)) {
    theta <- seq(0, 2*pi, len=sides+1)[-1]
    section <- cbind(cos(theta), sin(theta), 0)
  } else 
    sides <- nrow(section)
    
  vertices <- matrix(0, 3, sides*n)
  indices <- matrix(0, 4, sides*(n-1))
  
  if (ncol(section) == 2)
    section <- cbind(section, 0)
    
  for (i in 1:(n-1)) {
    transform <- rbind(e3[i,], e2[i,], e1[i,])
    p <- rotate3d(section, twist[i], 0,0,1)
    p <- radius[i] * p %*% transform
    p[,1] <- p[,1] + center[i,"x"]
    p[,2] <- p[,2] + center[i,"y"]
    p[,3] <- p[,3] + center[i,"z"]
    vertices[,(i-1)*sides+1:sides] <- t(p)
    for (j in 1:sides) 
      indices[, (i-1)*sides + j] <- (c(0,0,1,1) + j) %% sides + 1 + 
                                    c((i-1)*sides, i*sides, i*sides, (i-1)*sides)
  }
  transform <- rbind(e3[n,], e2[n,], e1[n,])
  p <- rotate3d(section, twist[n], 0,0,1)
  p <- radius[n] * p %*% transform
  p[,1] <- p[,1] + center[n,"x"]
  p[,2] <- p[,2] + center[n,"y"]
  p[,3] <- p[,3] + center[n,"z"]
  vertices[,(n-1)*sides+1:sides] <- t(p)
  # Add end cap at start
  if (closed < 0) {
    vertices <- cbind(vertices, center[1,])
    triangles <- rbind(ncol(vertices), 1:sides, c(2:sides, 1))
  }
  # Add end cap at end
  if (closed < -1) {
    vertices <- cbind(vertices, center[n,])
    triangles <- cbind(triangles, rbind(ncol(vertices), c(2:sides, 1) + (n-1)*sides, 
                                    1:sides + (n-1)*sides))
  }
  
  result <- qmesh3d(vertices, indices, homogeneous=FALSE)
  if (closed > 0) { # Look for repeated vertices, and edit the links
    nv <- ncol(result$vb)
    for (i in 1:sides) {
      dupe <- which(apply(result$vb[,(nv-sides+1):nv,drop=FALSE], 2, 
                          function(x) isTRUE(all.equal(x, result$vb[,i]))))+nv-sides
      for (j in dupe) {
        f <- result$ib == j
        result$ib[f] <- i
      }
    }
  } else if (closed < 0)
    result$it <- triangles
    
  if (keepVars)
    attr(result, "vars") <- environment()
  result
}
