
pointInPoly <- function(poly, pt) {
  # polygon is 2 x n, columns are vertices
  # point is 2 vector
  n <- ncol(poly)
  i1 <- seq_len(n)
  i2 <- i1 %% n + 1
  x <- poly[1,i1] + (poly[1,i2] - poly[1,i1])*(pt[2] - poly[2,i1])/(poly[2,i2] - poly[2,i1])
  crossings <- ((poly[2,i1] < pt[2]) & (pt[2] <= poly[2,i2]) 
              | (poly[2,i2] < pt[2]) & (pt[2] <= poly[2,i1])) & pt[1] < x
  sum(crossings) %% 2 == 1
}
	
intersectSegSeg <- function(seg1,seg2) {
  # do segments intersect?
  # both segments have endpoints as columns
  coeffs <- try(solve(cbind(seg1[,2]-seg1[,1], seg2[,1]-seg2[,2]), seg2[,1]-seg1[,1]), silent=TRUE)
  if (inherits(coeffs, "try-error")) return (FALSE)
  all(zapsmall(coeffs) >= 0) && all(zapsmall(1-coeffs) >= 0)
}
  
  
intersectTriSeg <- function(tri, seg) {
  # intersect a triangle with a segment
  # tri is 2 x 3, columns are vertices
  # seg is 2 x 2, columns are endpoints
  coeffs <- try(solve(rbind(tri,1), rbind(seg,1)), silent=TRUE)
  if (inherits(coeffs, "try-error")) return(TRUE)
  coeffs <- zapsmall(coeffs)  
  if (any(apply(coeffs <= 0, 1, all))) return(FALSE)
  if (any(apply(coeffs > 0, 2, all))) return(TRUE)
  up <- coeffs[,1] < 0
  dn <- coeffs[,2] < 0  
#  if (!any(up) || !any(dn)) return(TRUE)
  lb <- max( -coeffs[up,1]/(coeffs[up,2]-coeffs[up,1]) )
  ub <- 1 - max( -coeffs[dn,2]/(coeffs[dn,1] - coeffs[dn,2]) )
  lb <= ub
}

triangulateSimple <- function(x,y, random=TRUE, plot=FALSE, partial=NA) {
  n <- length(x)
  stopifnot(n == length(y))
  stopifnot(n > 2)
  
  it <- matrix(NA_integer_, nrow=3, ncol=n-2)
  verts <- 1:n
  while((m <- length(verts)) > 3) {
    i1 <- 1:m
    i2 <- i1 %% m + 1
    i3 <- i2 %% m + 1
    theta3 <- atan2(y[verts[i3]]-y[verts[i1]], x[verts[i3]]-x[verts[i1]])
    theta2 <- atan2(y[verts[i2]]-y[verts[i1]], x[verts[i2]]-x[verts[i1]])
    # diff <- (theta3-theta2+4*pi) %% (2*pi)
    diff <- ( (theta3-theta2)/pi + 4 ) %% 2
    convex <- which(diff < 1) 
    if (random && length(convex) > 1)
      convex <- sample(convex)
    good <- FALSE  # just in case none are convex
    for (k in convex) {
      i <- c(i1[k],i2[k],i3[k])
      tri <- rbind(x[verts[i]], y[verts[i]])
      good <- TRUE
      for (j in 2:(m-1)) {
        i4 <- (i1[k] + j - 1) %% m + 1
        i5 <- (i1[k] + j) %% m + 1
        j <- c(i4,i5)
        if (intersectTriSeg(tri, rbind(x[verts[j]], y[verts[j]]))) {
	  good <- FALSE
	  break
        }
      }
      if (good) {
        if (plot)
          polygon(x[verts[i]], y[verts[i]], col=m)
        it[, m-2] <- verts[i]
        verts <- verts[-i2[k]]
        break
      }
    }
    if (!good) break
  }
  if (!good) {
    if (is.na(partial)) {
      warning("triangulation is incomplete")
      partial <- TRUE
    }
    if (partial)
      it <- it[,seq_len(n-m)+m-2, drop=FALSE]
    else
      it <- NULL
  } else {
    if (plot)
      polygon(x[verts], y[verts], col=3)
    it[, 1] <- verts
  }
  it
}

triangulate <- function(x, y = NULL, random=TRUE, plot=FALSE, partial=NA) {
  xy <- xy.coords(x, y)
  x <- xy$x
  y <- xy$y
  nesting <- nestPolys(xy)
  verts <- nesting$verts
  nextvert <- rep(NA, length(x))
  
  processInside <- function(v) {
    for (i in nesting$nesting[[v]])
      processOutside(i)
  }
  
  processOutside <- function(fwd) {
    fwd1 <- verts[[fwd]]
    nextvert[fwd1] <<- c(fwd1[-1], fwd1[1])
    reversed <- nesting$nesting[[fwd]]   
    for (rev in reversed) {
      rev1 <- rev(verts[[rev]])
      nextvert[rev1] <<- c(rev1[-1], rev1[1])
      
      processInside(rev)
      done <- FALSE
      # we know at least one point of rev is in fwd, so merge them.
      # If this fails, the polygons are messed up.
      # We look for a segment from fwd to rev that intersects no other segments 
      # in either loop.
      pairs <- expand.grid(seq_along(fwd1), seq_along(rev1))
      if (random)
        pairs <- pairs[sample(nrow(pairs)),]
      for (p in 1:nrow(pairs)) {
        i <- fwd1[pairs[p,1]]
	j <- rev1[pairs[p,2]]
	seg <- cbind( c(x[i], y[i]),
	              c(x[j], y[j]) )
	clear <- TRUE
	for (q in seq_along(verts)) {
	  i1 <- verts[[q]]
	  if (!length(i1)) next
	  i2 <- c(i1[-1], i1[1])
	  for (v in seq_along(i1)) 
	    if (length(intersect(c(i1[v], i2[v]), c(i,j))) == 0
		&& intersectSegSeg(seg, cbind( c(x[i1[v]], y[i1[v]]), c(x[i2[v]], y[i2[v]]) ))) {
	      clear <- FALSE
	      break
	    }
	  if (!clear) break
	}
	if (clear) {  # Found a segment that doesn't intersect anything, so join the two polys
	  i <- pairs[p,1]
	  j <- pairs[p,2]
	  ind <- c(fwd1[1:i], rev1[j:length(rev1)], rev1[1:j])
	  if (i < length(fwd1))
	    ind <- c(ind, fwd1[i:length(fwd1)])
	  verts[[fwd]] <<- fwd1 <- ind
	  verts[[rev]] <<- integer(0)
	  done <- TRUE
	  break
	}
      }
      if (!done)
        stop("Cannot simplify polygon")
    }
    ind <- verts[[fwd]]
    tri <- triangulateSimple(x[ind], y[ind], random, plot, partial=FALSE)
    if (is.null(tri)) 
      stop("Cannot triangulate polygon")
    # Convert back to original numbering
    dim <- dim(tri)
    tri <- ind[tri]
    dim(tri) <- dim
    # Put in place as triangulation of the forward poly
    subtri[[fwd]] <<- tri
  }
  
  subtri <- list()
  for (i in nesting$toplevel)
    processOutside(i)
  
  # Done all polys, now combine
  res <- matrix(nrow=3, ncol=0)
  for (i in seq_along(subtri))
    res <- cbind(res, subtri[[i]])
  attr(res, "nextvert") <- nextvert
  res
}

# Rewrite a complex polygon as a list of the individual parts, oriented correctly,
# with attribute showing nesting

nestPolys <- function(x,y = NULL) {
  xy <- xy.coords(x, y)
  x <- xy$x
  y <- xy$y
  n <- length(x)
  nas <- c(which(is.na(x) | is.na(y)), n + 1L)
  prev <- 0L
  verts <- list()
  for (i in seq_along(nas)) {
    verts[[i]] <- ind <- (prev + 1L):(nas[i] - 1L)
    tri <- triangulateSimple(x[ind], y[ind], random=TRUE, plot=FALSE, partial=FALSE)
    if (is.null(tri))
      verts[[i]] <- rev(verts[[i]])
    prev <- nas[i]
  }
  # nesting is a list of vectors
  # of poly numbers that are directly nested within the corresponding element of verts
  # The last one at length(verts)+1 lists polys not nested anywhere
  
  nesting <- rep(list(integer()), length(verts)+1)
  place <- function(new, toplevel) {    
    placed <- FALSE
    contains <- integer()
    if (length(nesting[[toplevel]])) {
      newverts <- rbind(x[verts[[new]]], y[verts[[new]]])
    
      for (j in nesting[[toplevel]]) {
        prev <- rbind(x[verts[[j]]], y[verts[[j]]])    
        if (pointInPoly(prev, newverts[,1])) {
	  place(new, j)
	  placed <- TRUE
	  break
        }
        if (pointInPoly(newverts, prev[,1]))
	  contains <- c(contains, j)
      }
    }
    if (!placed) {
      nesting[[toplevel]] <<- c(setdiff(nesting[[toplevel]], contains), new)
      nesting[[new]] <<- contains
    }
  }
    
  for (i in seq_along(verts)) {
    place(i, length(verts)+1)
  }
  
  list(verts=verts, nesting=nesting[-length(nesting)], 
       toplevel=nesting[length(nesting)])
} 
      
      
extrude3d <- function(x,y = NULL, thickness=1, smooth=FALSE, ...) {
  xy <- xy.coords(x, y)
  x <- xy$x
  y <- xy$y
  it <- triangulate(x, y, partial=FALSE)
  nextvert <- attr(it, "nextvert")
  n <- length(x)
  res <- tmesh3d(rbind(c(x,x), c(y,y), c(rep(thickness,n), rep(0,n)), 1),
                 cbind(it, it[c(1,3,2),]+n), ...)
  i1 <- 1:n
  i2 <- nextvert
  i3 <- i2 + n
  i4 <- i1 + n
  keep <- !is.na(nextvert)
  res$ib <- rbind(i4,i3,i2,i1)[,keep]
  if (smooth) {
    res$ib <- res$ib + ncol(res$vb)
    res$vb <- cbind(res$vb, res$vb)
    i3 <- nextvert[nextvert]
    diff <- cbind(x[i3] - x[i1],  y[i3] - y[i1])
    len <- sqrt(apply(diff^2, 1, sum))
    diff <- diff/len
    
    res$normals <- cbind( rbind(0,0,c(rep(1, n), rep(-1, n))) )
    res$normals <- cbind(res$normals, res$normals)
    i2 <- c(i2 + 2*n, i2 + 3*n)
    keep <- !is.na(i2)
    res$normals[,i2[keep]] <- rbind(rep(diff[,2], 2), -rep(diff[,1], 2), 0)[,keep]   
  }
  res
}

polygon3d <- function(x, y = NULL, z = NULL, fill = TRUE, plot = TRUE, 
                      coords = 1:2, random = TRUE, ...) {
  xyz <- xyz.coords(x,y,z)
  if (!fill) {
    n <- length(xyz$x)
    nas <- with(xyz, c(which(is.na(x) | is.na(y) | is.na(z)), n + 1L))
    prev <- 0L
    loop <- integer()
    for (i in seq_along(nas)) {
      loop <- c(loop, if (i > 1) NA, (prev + 1L):(nas[i] - 1L), prev + 1L)
      prev <- nas[i]
    }
    res <- cbind(xyz$x[loop], xyz$y[loop], xyz$z[loop])
    if (plot)
      lines3d(res, ...)
    else
      res
  } else {
    cnames <- c("x", "y", "z")
    x <- xyz[[cnames[coords[1]]]]
    y <- xyz[[cnames[coords[2]]]]
    tri <- triangulate(x, y, random = random)
    shape <- tmesh3d(rbind(xyz$x, xyz$y, xyz$z, 1), indices = tri)
    if (plot)
      shade3d(shape, ...)
    else
      shape
  }
}  
