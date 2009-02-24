#
# R 3d object : mesh3d
# triangle mesh object
#

tmesh3d <- function( vertices, indices, homogeneous=TRUE, material=NULL, normals=NULL ) {
  if (homogeneous == TRUE)
    vrows <- 4
  else
    vrows <- 3
  if ( !is.null(normals) ) {
    normals <- xyz.coords(normals, recycle=TRUE)
    nvertex <- length(vertices)/vrows
    x <- rep(normals$x, len=nvertex)
    y <- rep(normals$y, len=nvertex)
    z <- rep(normals$z, len=nvertex)
    normals <- rgl.vertex(x,y,z)
  }
  object <- list(
    vb=matrix(vertices,nrow=vrows),
    ib=matrix(indices,nrow=3),
    primitivetype="triangle",
    material=material,
    normals=normals
  ) 
  
  if (!homogeneous) object$vb <- rbind(object$vb, 1)
  
  class(object) <- c("tmesh3d", "mesh3d", "shape3d")
  return( object )
}

# rendering support

wire3d.tmesh3d <- function ( x, override = TRUE, ... ) {
  if ( override ) {
    material <- x$material
    if (is.null(material)) material <- list()    
    material[names(list(...))] <- list(...)
  } else {
    material <- list(...)
    material[names(x$material)] <- x$material
  }
  material["front"] <- "lines"
  material["back"] <- "lines"
  
  do.call("triangles3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                   y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                   z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                              material))
}

shade3d.tmesh3d <- function ( x, override = TRUE, ... ) {
  if ( override ) {
    material <- x$material
    if (is.null(material)) material <- list()    
    material[names(list(...))] <- list(...)
  } else {
    material <- list(...)
    material[names(x$material)] <- x$material
  }
  if ( is.null(x$normals) ) 
    do.call("triangles3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                     y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                     z = x$vb[3,x$ib]/x$vb[4,x$ib]), 
                                material))
  else
    do.call("triangles3d", args = c(list(x = x$vb[1,x$ib]/x$vb[4,x$ib],
                                     y = x$vb[2,x$ib]/x$vb[4,x$ib],
                                     z = x$vb[3,x$ib]/x$vb[4,x$ib],
                                     normals = t(x$normals[,x$ib])), 
                                material))                                
 }
