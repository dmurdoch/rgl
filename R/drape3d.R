drape3d <- function(obj, ...) 
  UseMethod("drape3d")

drape3d.default <- function(obj, ...) 
  drape3d(as.mesh3d(obj), ...)
  
drape3d.mesh3d <- function (obj, x, y = NULL, z = NULL,
    plot = TRUE, up = c(0, 0, 1), P = projectDown(up), ...) 
{
  # Takes segment number as input; returns
  # NULL if in no triangle, otherwise matrix of projected locations and triangle numbers.
  ztri <- function(i){
    p <- psegs[,i]
    oo <- p[1] < TRI[1,1,] | p[1] > TRI[2,1,] |
      p[2] < TRI[1,2,] | p[2] > TRI[2,2,]
    result <- NULL
    lam <- numeric(3)
    for(j in which(!oo)){
      ## get barycentric coords of p in projected triangle
      v <- pverts[,obj$it[,j]]  ## v[i,] vertices of projected triangle i
      D <- (v[2,2]-v[2,3]) * (v[1,1]-v[1,3]) +
        (v[1,3]-v[1,2]) * (v[2,1]-v[2,3])
      if (D == 0) next
      l <- (v[2,2]-v[2,3]) * (p[1]  -v[1,3]) +
        (v[1,3]-v[1,2]) * (p[2]  -v[2,3])
      lam[1] <- l/D
      if (lam[1] < 0 || lam[1] > 1) next   ## not in this triangle
      l <- (v[2,3]-v[2,1]) * (p[1]  -v[1,3]) +
        (v[1,1]-v[1,3]) * (p[2]  -v[2,3])
      lam[2] <- l/D
      if (lam[2] < 0 || lam[2] > 1) next   ## not in this triangle
      lam[3] <- 1-sum(lam[1:2])
      if (lam[3] < 0 || lam[3] > 1) next   ## not in this triangle
      v <- matrix(verts[,obj$it[,j]], 3,3)  ## Now v is vertices of original triangle
      result <- rbind(result, c(v %*% lam, j))
    }
    result
  }
  op <- function(v)
    v[if(v[1] > v[2]) c(2,1) else c(1,2)] ## orders pair
  
  obj <- as.tmesh3d(obj)
  
  verts <- t(asEuclidean(t(obj$vb)))
  
  segs <- xyz.coords(x, y, z, recycle=TRUE)
  segs <- rbind(segs$x, segs$y, segs$z)
  
  if (length(dim(P)) != 2 || !all(dim(P) == c(2,3)))
    stop("P should be a 2 x 3 matrix.")
  
  pverts <- P %*% verts  # projected vertices
  psegs <- P %*% segs # projected segments
  
  ## get unique point pairs making a triangle side
  tri <- matrix(NA,nrow=3*ncol(obj$it),ncol=2)
  n <- 0
  for (j in seq_len(ncol(obj$it))) {
    v <- obj$it[,j]
    tri[n<-n+1,] <- v[c(1,2)]
    tri[n<-n+1,] <- v[c(2,3)]
    tri[n<-n+1,] <- v[c(3,1)]
  }
  
  TRI <- array(NA,c(2,2,ncol(obj$it)))
  for(j in seq_len(ncol(obj$it))){
    v <- obj$it[,j]       ## vertices of triangle
    TRI[,,j] <- matrix(c(range(pverts[1,v]),range(pverts[2,v])),2,2)
  }
  
  ## now TRI[,1,i] is x coord range for projected triangle i
  ## now TRI[,2,i] is y coord range for projected triangle i
  
  result <- matrix(numeric(), ncol = 3)
  
  p2 <- NA
  p2tri <- NULL
  
  for (i in seq_len(ncol(psegs))) {
    p1 <- p2
    p1tri <- p2tri
    if (!length(p1tri))
      zs <- NULL
    else
      zs <- cbind(p1tri, 0)  # First point
    
    p2 <- psegs[,i]
    if (any(is.na(p2))) {
      p2tri <- NULL
      next
    } else {
      p2tri <- ztri(i)
      zs <- rbind(zs, cbind(p2tri, 1)) # Last point
    }
    
    if (any(is.na(p1)))
      next

    ## add middle points    
    p21 <- p2 - p1

    s <- matrix(c(p1,p2),2,2)  ## speedup: winnow futile intersection calcs
    s <- t(apply(s,1,op))
    ## triangle seg x extent is all below or above line seg x extent
    sx <- (pverts[1,tri[,1]] < s[1,1] & pverts[1,tri[,2]] < s[1,1]) |
      (pverts[1,tri[,1]] > s[1,2] & pverts[1,tri[,2]] > s[1,2])
    ## triangle seg y extent is all below or above line seg y extent
    sy <- (pverts[2,tri[,1]] < s[2,1] & pverts[2,tri[,2]] < s[2,1]) |
      (pverts[2,tri[,1]] > s[2,2] & pverts[2,tri[,2]] > s[2,2])
    for(j in which(!sx & !sy)){     ## possible intersections
      p3 <- pverts[,tri[j,1]]
      p4 <- pverts[,tri[j,2]]
      p43 <- p4-p3
      p31 <- p3-p1
      D <- -p21[1]*p43[2] + p21[2]*p43[1]
      if (D == 0) next                    ## parallel line segs
      T1<- -p31[1]*p43[2] + p31[2]*p43[1]
      t1 <- T1/D
      if (t1 < 0 || t1 > 1) next          ## not within p1 ... p2
      T2<-  p21[1]*p31[2] - p21[2]*p31[1]
      t2 <- T2/D
      if (t2 < 0 || t2 > 1) next          ## not within p3 ... p4
      v3 <- verts[,tri[j,1]]
      v43 <- verts[,tri[j,2]] - v3
      k <- (j+2)%/%3   # triangle number
      zs <- rbind(zs, c(v3+t2*v43, k, t1))## t1 along line seg & point value
    }
    
    if (length(zs)) {
      # Order by triangle to group them, then by t
      # within triangle 
      o <- order(zs[,4], zs[,5])
      zs <- zs[o, , drop = FALSE]
      # Only keep cases that are on the same triangle
      # Rounding may give us 1 or 3 intersections with a 
      # triangle; discard singletons, use first and last
      # for triples.
      k <- zs[,4]
      dup <- duplicated(k)
      nextdup <- c(dup[-1], FALSE)
      keep <- xor(dup, nextdup) # The first or last for a triangle
      zs <- zs[keep,,drop = FALSE]
      # Order by t value
      finish <- 2*seq_len(nrow(zs)/2)
      start <- finish - 1
      o <- order(zs[start, 5])
      start <- start[o]
      finish <- finish[o]
      # Drop zero length segments
      keep <- zs[start, 5] < zs[finish, 5]
      start <- start[keep]
      finish <- finish[keep]
      both <- as.numeric(rbind(start, finish))
      result <- rbind(result, zs[both, -(4:5), drop = FALSE])
    }
  }
  if (plot)
    segments3d(result, ...)
  else
    result
}
