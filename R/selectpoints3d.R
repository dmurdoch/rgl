selectpoints3d <- function(objects = rgl.ids()$id, value = TRUE, closest = TRUE, 
                           multiple = FALSE, ...) {

  if (value) result <- cbind(x = numeric(0), y = numeric(0), z = numeric(0))
  else result <- cbind(id = integer(0), index = integer(0))
  rdist <- I

  first <- TRUE
  while (first || is.function(multiple) || multiple) {
    f <- select3d(...)
    if (is.null(f)) break
    
    e <- environment(f)
    
    dist <- Inf
    prev <- nrow(result)
    
    for (id in objects) {
      verts <- rgl.attrib(id, "vertices")
      hits <- f(verts)
      
      if (any(hits)) dist <- 0
      else if (closest && dist > 0 && nrow(verts)) {
        wincoords <- rgl.user2window(verts, projection = e$proj)
        wz <- wincoords[,3]
        keep <- (0 <= wz) && (wz <= 1)
        wincoords <- wincoords[keep,,drop=FALSE]
  
        if (!nrow(wincoords)) next 
  
        wx <- wincoords[,1]
        xdist <- ifelse(wx < e$llx, (wx-e$llx)^2, ifelse(wx < e$urx, 0, (wx-e$urx)^2))
   
        wy <- wincoords[,2]      
        ydist <- ifelse(wy < e$lly, (wy-e$lly)^2, ifelse(wy < e$ury, 0, (wy-e$ury)^2))  
  
        dists <- xdist + ydist
        hits <- (dists < dist) & (dists == min(dists))
        dist <- min(c(dist, dists))
      }
      
      if (!any(hits)) next
      
      if (prev && nrow(result) > prev  && rdist > dist)
        result <- result[seq_len(prev),,drop=FALSE]
        
      if (value)
        result <- rbind(result, verts[hits,])
      else
        result <- rbind(result, cbind(id, which(hits)))
        
      if (is.function(multiple) && nrow(result) > prev
          && !multiple(result[(prev+1):nrow(result),,drop=FALSE]))
        break  
        
      rdist <- dist
      
      first <- FALSE
    }
    
    if (value)
      result <- unique(result)
  
  }
  result
}
