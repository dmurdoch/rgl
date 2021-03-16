drape3d <- function(obj, ...) 
  UseMethod("drape3d")

drape3d.rglId <- function(obj, ...) 
  drape3d(as.mesh3d(obj), ...)
  
drape3d.mesh3d <- function (obj, x, y = NULL, log = NULL, minVertices = 0,
    plot = TRUE, z_offset = 0, TRI = NULL, ...) 
{
    ztri <- function(p){
        ## Finds triangle with point p inside of it and returns z at that point
        if(is.null(TRI)){
            TRI <- array(NA,c(2,2,ncol(obj$it)))
            for(j in 1:ncol(obj$it)){
                v <- obj$it[,j]       ## vertices of triangle
                TRI[,,j] <- matrix(c(range(verts[v,1]),range(verts[v,2])),2,2)
            }
        }
        ## now TRI[,1,i] is x coord range for triangle i
        ## now TRI[,2,i] is y coord range for triangle i
        oo <- (p[1] < TRI[1,1,] | p[1] > TRI[2,1,]) &
              (p[2] < TRI[1,2,] | p[2] > TRI[2,2,])
        lam <- vector()
        for(j in (1:ncol(obj$it))[!oo]){
            ## get barycentric coords of p in triangle
            v <- matrix(verts[obj$it[,j],],3,3)  ## v[i,] vertices of triangle i
            D <- (v[2,2]-v[3,2]) * (v[1,1]-v[3,1]) +
                 (v[3,1]-v[2,1]) * (v[1,2]-v[3,2])
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
            return(sum(lam*v[,3]))
        }
        NA
    }

    uniq <- function(...) mgcv::uniquecombs(...) ## current version

    obj <- as.tmesh3d(obj)
    nverts <- ncol(obj$vb)
    oldnverts <- nverts - 1
    while (nverts < minVertices && oldnverts < nverts) {
        oldnverts <- nverts
        obj <- subdivision3d(obj, deform = FALSE, normalize = TRUE)
        nverts <- ncol(obj$vb)
    }

    verts <- asEuclidean(t(obj$vb))
    result <- data.frame(x = numeric(), y = numeric(), z = numeric())

    if (is.function(x)) {
        fn <- x
        verts <- t(verts)         ## verts is n x 3:  each row is a point
        values <- (               ## values is 3 x t:  each col is a tri
            fn(verts)
        )[obj$it]
        dim(values) <- dim(obj$it)
        counts <-                 ## t vector: # pts cut by fn in each triangle
            apply(values >= 0, 2, sum)
        hits <-                   ## 3 x t matrix: each tri with two sides hit
            obj$it[,counts == 2 | counts == 1]
        if (ncol(hits)) {
            hitValues <-          ## 3 x t matrix: values at vertex of each tri hit
                values[,counts == 2 | counts == 1]
            hitValues[hitValues == 0] <- .Machine$double.eps ## make 0 slightly +ve
            pm <-                 ## +1,-1 depending on whether 2 pts>=0 or 1 pt>=0
                apply(hitValues, 2, function(col) 2*sum(col >= 0)-3)
            pm <-                 ## make 2 values positive in each triangle
                matrix(rep(pm,each=3),3) * hitValues
            vtx2 <- apply(pm, 2, function(col) which(col >= 0))
            vtx1 <- apply(pm, 2, function(col) which(col < 0))
            newvert <- matrix(NA, 2, 3)
            for (j in 1:ncol(hitValues)) {
                snglval <- hitValues[vtx1[j], j]
                for (i in 1:2) {
                    dublval <- hitValues[vtx2[i,j], j]
                    alpha <- dublval/(dublval - snglval)
                    newvert[i,] <-
                      (1-alpha)*verts[,hits[vtx2[i,j], j]] +
                         alpha *verts[,hits[vtx1[j], j]]
                }
                result <- rbind(result, data.frame(
                    x=newvert[,1], y=newvert[,2], z=newvert[,3]
                ))
            }
        }

        if (plot) 
            return(segments3d(result, ...))

    } else {
        segs <- xy.coords(x, y, log=log, recycle=FALSE, setLab=FALSE)

        ## get unique point pairs making a triangle side in the grid
        op <- function(v)v[if(v[1]>v[2])c(2,1) else c(1,2)] ## orders pair
        tri <- matrix(NA,nrow=3*ncol(obj$it),ncol=2)
        n <- 0
        for (j in 1:ncol(obj$it)) {
            v <- obj$it[,j]
            tri[n<-n+1,] <- op(v[c(1,2)])
            tri[n<-n+1,] <- op(v[c(2,3)])
            tri[n<-n+1,] <- op(v[c(3,1)])
        }
        tri <- uniq(tri)

        ## add first segment point assuming not on a triangle edge
        z1 <- with(segs,ztri(c(x[1],y[1])))
        if (!is.na(z1)) result <- with(segs,
            rbind(result, data.frame( x=x[1], y=y[1], z=z1 + z_offset ))
        )
        for (i in 2:length(segs$x)){
            p1 <- c(segs$x[i-1],segs$y[i-1])
            p2 <- c(segs$x[i],segs$y[i])
            p21 <- p2 - p1
            if (any(is.na(p2))) {
                ## add last segment point assuming not on triangle edge
                zi <- ztri(p1)
                if (!is.na(zi)) result <- rbind(result,
                    data.frame( x=p1[1], y=p1[2], z=zi + z_offset )
                )
                next
            }
            if (any(is.na(p1))) {
                ## NAs break line and move to next point
                result <- rbind(result, data.frame( x=NA, y=NA, z=NA ))
                zi <- ztri(p2)
                if (!is.na(zi)) result <- rbind(result,
                    data.frame( x=p2[1], y=p2[2], z=zi + z_offset )
                )
                next
            }
            zs <- matrix(NA,nrow=0,ncol=2)
            s <- matrix(c(p1,p2),2,2)  ## speedup: winnow futile intersection calcs
            s <- t(apply(s,1,op))
            ## triangle seg x extent is all below or above line seg x extent
            sx <- (verts[tri[,1],1] < s[1,1] & verts[tri[,2],1] < s[1,1]) |
                  (verts[tri[,1],1] > s[1,2] & verts[tri[,2],1] > s[1,2])
            ## triangle seg y extent is all below or above line seg y extent
            sy <- (verts[tri[,1],2] < s[2,1] & verts[tri[,2],2] < s[2,1]) |
                  (verts[tri[,1],2] > s[2,2] & verts[tri[,2],2] > s[2,2])
            for(j in (1:nrow(tri))[!sx & !sy]){     ## possible intersections
                p3 <- verts[tri[j,1],]
                p4 <- verts[tri[j,2],]
                p43 <- p4-p3
                p31 <- p3[1:2]-p1
                D <- -p21[1]*p43[2] + p21[2]*p43[1]
                if (D == 0) next                    ## parallel line segs
                T1<- -p31[1]*p43[2] + p31[2]*p43[1]
                t1 <- T1/D
                if (t1 < 0 || t1 > 1) next          ## not within p1 ... p2
                T2<-  p21[1]*p31[2] - p21[2]*p31[1]
                t2 <- T2/D
                if (t2 < 0 || t2 > 1) next          ## not within p3 ... p4
                zs <- rbind(zs,c(t1,(p3+t2*p43)[3]))## t1 along line seg & z value
            }
            if (nrow(zs)>0) {
                ## add points in order of increasing t on segment
                o <- order(zs[,1])
                result <- rbind(result, data.frame(
                    x=p1[1] + zs[o,1]*p21[1], y=p1[2] + zs[o,1]*p21[2],
                    z=zs[o,2] + z_offset
                ))
            }
        }

        ## add last segment point assuming not on triangle edge
        zn <- ztri(p2)
        if (!is.na(zn)) result <- rbind(result,
            data.frame( x=p2[1], y=p2[2], z=zn + z_offset )
        )

        if (plot) 
            return(lines3d(result, ...))
    }
    result
}
