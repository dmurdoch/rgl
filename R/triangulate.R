
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
  if (inherits(coeffs, "try-error")) return(FALSE)
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
  lb <- max( -coeffs[up,1]/(coeffs[up,2]-coeffs[up,1]) )
  ub <- 1 - max( -coeffs[dn,2]/(coeffs[dn,1] - coeffs[dn,2]) )
  lb <= ub
}

triangulate <- function(x, y = NULL, z = NULL, random = TRUE, plot = FALSE, partial = NA) {
  xyz <- xyz.coords(x, y, z)
  if (xyz$xlab == "Index" && is.null(z) && (is.null(ncol(x)) || ncol(x) == 2L)) {
    x <- xyz$y
    y <- xyz$z
  } else {
    x <- xyz$x
    y <- xyz$y
    if (!diff(range(x, na.rm = TRUE))) 
      x <- xyz$z
    else if (!diff(range(y, na.rm = TRUE))) 
      y <- xyz$z
  } 
  
  nesting <- nestPolys(x, y)
  verts <- nesting$verts
  
  processInside <- function(v) {
    result <- matrix(NA, ncol = 0, nrow = 3)
    indices <- verts[[v]]
    for (i in nesting$nesting[[v]]) {
      result <- cbind(result, processOutside(i))
      indices <- c(indices, NA, verts[[i]])
      
    }
    res0 <- .Call(rgl_earcut, x[indices], y[indices])
    result <- cbind(result, 
                matrix(indices[res0+1], nrow = 3))
  }
  
  processOutside <- function(fwd) {
    result <- matrix(NA, ncol = 0, nrow = 3)
    for (i in nesting$nesting[[fwd]])
      result <- cbind(result, processInside(i))
    
    result
  }
  
  # Done all polys, now combine
  res <- matrix(nrow=3, ncol=0)
  for (i in nesting$toplevel)
    res <- cbind(res, processInside(i))
  
  # Get vertex order
  nextvert <- rep(NA, length(x))
  for (i in seq_along(verts)) {
    poly <- verts[[i]]
    first <- poly[1]
    second <- poly[2]

    # Find first triangle holding first 
    # and second
    tri <- intersect(col(res)[res == first],
                     col(res)[res == second])
    if (!length(tri))
      warning("edge not found:", first, " ", second)
    else {
      tri <- tri[1]
      counter <- (which(res[,tri] == first) - which(res[,tri] == second) + 3) %% 3 == 2
      if (counter) {
        nextvert[poly[-length(poly)]] <- poly[-1]
        nextvert[poly[length(poly)]] <- poly[1]
      } else {
        nextvert[poly[-1]] <- poly[-length(poly)]
        nextvert[poly[1]] <- poly[length(poly)]
      }
    }
  }
  if (plot) {
    for (i in seq_len(ncol(res)))
      polygon(x[res[,i]], y[res[,i]], col = i)
  }
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
    verts[[i]] <- (prev + 1L):(nas[i] - 1L)
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
  it <- triangulate(x, y)
  nextvert <- attr(it, "nextvert")
  n <- length(x)
  res <- tmesh3d(rbind(c(x,x), c(y,y), c(rep(thickness,n), rep(0,n)), 1),
                 cbind(it, it[c(1,3,2),]+n), ...)
  i1 <- seq_len(n)
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
                      coords, random = TRUE, ...) {
  xyz <- xyz.coords(x,y,z, recycle = TRUE)
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
    if (missing(coords)) 
      tri <- triangulate(xyz)
    else {
      cnames <- c("x", "y", "z")
      x <- xyz[[cnames[coords[1]]]]
      y <- xyz[[cnames[coords[2]]]]
      tri <- triangulate(x, y)
    }
    shape <- tmesh3d(rbind(xyz$x, xyz$y, xyz$z, 1), indices = tri)
    if (plot)
      shade3d(shape, ...)
    else
      shape
  }
}  
