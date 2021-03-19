drape3d <- function(obj, ...) 
  UseMethod("drape3d")

drape3d.rglId <- function(obj, ...) 
  drape3d(as.mesh3d(obj), ...)
  
drape3d.mesh3d <- function (obj, x, y = NULL, z = NULL,
    plot = TRUE, P = cbind(diag(2), 0), ...) 
{
    ids <- NULL
    
    # Takes segment number as input; returns
    # NULL if in no triangle, otherwise matrix of projected locations and triangle numbers.
    ztri <- function(i){
      p <- psegs[,i]
      TRI <- array(NA,c(2,2,ncol(obj$it)))
      for(j in seq_len(ncol(obj$it))){
        v <- obj$it[,j]       ## vertices of triangle
        TRI[,,j] <- matrix(c(range(pverts[1,v]),range(pverts[2,v])),2,2)
      }
      
      ## now TRI[,1,i] is x coord range for projected triangle i
      ## now TRI[,2,i] is y coord range for projected triangle i
      oo <- (p[1] < TRI[1,1,] | p[1] > TRI[2,1,]) &
        (p[2] < TRI[1,2,] | p[2] > TRI[2,2,])
      result <- NULL
      lam <- numeric(3)
      for(j in seq_len(ncol(obj$it))[!oo]){
        ## get barycentric coords of p in projected triangle
        v <- matrix(pverts[,obj$it[,j]],3,2)  ## v[i,] vertices of projected triangle i
        D <- (v[2,2]-v[3,2]) * (v[1,1]-v[3,1]) +
          (v[3,1]-v[2,1]) * (v[1,2]-v[3,2])
        if (D == 0) next
        l <- (v[2,2]-v[3,2]) * (p[1]  -v[3,1]) +
          (v[3,1]-v[2,1]) * (p[2]  -v[3,2])
        lam[1] <- l/D
        if (lam[1] < 0 || lam[1] > 1) next   ## not in this triangle
        l <- (v[3,2]-v[1,2]) * (p[1]  -v[3,1]) +
          (v[1,1]-v[3,1]) * (p[2]  -v[3,2])
        lam[2] <- l/D
        if (lam[2] < 0 || lam[2] > 1) next   ## not in this triangle
        lam[3] <- 1-sum(lam[1:2])
        if (lam[3] < 0 || lam[3] > 1) next   ## not in this triangle
        v <- matrix(verts[obj$it[,j],], 3,3)  ## Now v is vertices of original triangle
        result <- rbind(result, c(lam %*% v, j))
      }
      result
    }
    
    obj <- as.tmesh3d(obj)
    nverts <- ncol(obj$vb)

    verts <- asEuclidean(t(obj$vb))
    pverts <- P %*% t(verts)  # projected vertices
    
    result <- matrix(numeric(), ncol = 3)

    segs <- xyz.coords(x, y, z, recycle=TRUE)
    segs <- rbind(segs$x, segs$y, segs$z)
    psegs <- P %*% segs # projected segments
    
    ## get unique point pairs making a triangle side
    op <- function(v)v[if(v[1]>v[2])c(2,1) else c(1,2)] ## orders pair
    tri <- matrix(NA,nrow=3*ncol(obj$it),ncol=2)
    n <- 0
    for (j in seq_len(ncol(obj$it))) {
      v <- obj$it[,j]
      tri[n<-n+1,] <- op(v[c(1,2)])
      tri[n<-n+1,] <- op(v[c(2,3)])
      tri[n<-n+1,] <- op(v[c(3,1)])
    }

    ## add first segment point assuming not on a triangle edge
    z1 <- ztri(1)
    if (length(z1)) 
      zs <- cbind(z1, 0) # Entries are triangle no, pt, t in segment
    else
      zs <- NULL

    for (i in seq_len(ncol(segs))[-1]){
      p1 <- psegs[,i-1]
      p2 <- psegs[,i]
      p21 <- p2 - p1
      if (any(is.na(p2))) {
        ## add last segment point assuming not on triangle edge
        zi <- ztri(i-1)
        if (!is.null(zi)) result <- rbind(result,zi)
        next
      }
      if (any(is.na(p1))) {
        ## NAs break line and move to next point
        zi <- ztri(i)
        if (length(zi)) 
          zs <- rbind(zs, cbind(zi, 0))
        next
      }

      s <- matrix(c(p1,p2),2,2)  ## speedup: winnow futile intersection calcs
      s <- t(apply(s,1,op))
      ## triangle seg x extent is all below or above line seg x extent
      sx <- (pverts[1,tri[,1]] < s[1,1] & pverts[1,tri[,2]] < s[1,1]) |
        (pverts[1,tri[,1]] > s[1,2] & pverts[1,tri[,2]] > s[1,2])
      ## triangle seg y extent is all below or above line seg y extent
      sy <- (pverts[2,tri[,1]] < s[2,1] & pverts[2,tri[,2]] < s[2,1]) |
        (pverts[2,tri[,1]] > s[2,2] & pverts[2,tri[,2]] > s[2,2])
      for(j in seq_len(nrow(tri))[!sx & !sy]){     ## possible intersections
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
        v3 <- verts[tri[j,1],]
        v43 <- verts[tri[j,2],] - v3
        k <- (j+2)%/%3   # triangle number
        zs <- rbind(zs, c(v3+t2*v43, k, t1))## t1 along line seg & point value
      }
      ## add last segment point assuming not on triangle edge
      zn <- ztri(i)
      if (!is.null(zn)) 
        zs <- rbind(zs, cbind(zn, 1))
      
      if (nrow(zs) > 0) {
        o <- order(zs[,4])
        zs <- zs[o, , drop = FALSE]
        ## Only keep cases that are on the same triangle
        k <- zs[,4]
        dup <- duplicated(k)
        nextdup <- c(dup[-1], FALSE)
        prevdup <- c(FALSE, dup[-length(dup)])
        keep <- (!dup & nextdup) | # The first for a tri
                (!prevdup & dup)   # The second
        zs <- zs[keep,,drop = FALSE]
        ## add points in order of increasing t on segment
        o <- order(zs[,4], zs[,5])
        result <- rbind(result, zs[o,-(4:5)])
      }
    }
    if (plot)
      segments3d(result, ...)
    else
      result
}
