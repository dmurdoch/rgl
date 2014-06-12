writePLY <- function(con, format=c("little_endian", "big_endian", "ascii"), 
                     pointRadius=0.005, 
                     pointShape = icosahedron3d(),
                     lineRadius = pointRadius,
                     lineSides = 20,
                     pointsAsEdges = FALSE,
                     linesAsEdges = pointsAsEdges,
                     withColors = TRUE,
                     withNormals = !(pointsAsEdges || linesAsEdges),
                     ids = NULL) {
 
  writeData <- function() {
    ident <- paste(filename, " produced by RGL\n")
    cat("ply\n", file=con)
    fmt <- switch(format,
      little_endian = "binary_little_endian",
      big_endian = "binary_big_endian",
      ascii = "ascii")
    
    cat("format", fmt, "1.0\n", file=con)
    cat("element vertex", nrow(Vertices), "\n", file=con)
    cat("property float x
property float y
property float z\n", file=con)
    if (withColors)
      cat("property float red
property float green
property float blue
property float alpha\n", file=con)
    if (withNormals)
      cat("property float nx
property float ny
property float nz\n", file=con)
    cat("element face", nrow(Triangles)+nrow(Quads), "\n", file=con)
    cat("property list int int vertex_indices\n", file=con)
    if (nrow(Edges) > 0) {
      cat("element edge", nrow(Edges), "\n", file=con)
      cat("property int vertex1
property int vertex2\n", file=con)
    }
    cat("end_header\n", file=con)
    
    if (format == "ascii") {
      for (i in seq_len(nrow(Vertices))) 
        cat(Vertices[i,], "\n", file=con)
      for (i in seq_len(nrow(Triangles))) 
        cat("3", Triangles[i,], "\n", file=con)
      for (i in seq_len(nrow(Quads)))
        cat("4", Quads[i,], "\n", file=con)
      for (i in seq_len(nrow(Edges)))
        cat(Edges[i,], "\n", file=con)
    } else {
      endian <- if (format == "little_endian") "little" else "big"
      if (nrow(Vertices))
        writeBin(as.numeric(t(Vertices)), con, size=4, endian=endian)
      if (nrow(Triangles))
        writeBin(as.integer(t(cbind(3L, Triangles))), con, size=4, endian=endian)
      if (nrow(Quads))
        writeBin(as.integer(t(cbind(4L, Quads))), con, size=4, endian=endian)
      if (nrow(Edges))
        writeBin(as.integer(t(Edges)), con, size=4, endian=endian)
    }  
  }  
    
  Vertices <- matrix(0, 0, 3 + 4*withColors + 3*withNormals)
  Triangles <- matrix(1L, 0, 3)
  Quads <- matrix(1L, 0, 4)
  Edges <- matrix(1L, 0, 2)

  getVertices <- function(id) {
    vertices <- rgl.attrib(id, "vertices")
    if (withColors) {
      colors <- rgl.attrib(id, "colors")
      if (nrow(colors) == 1)
        colors <- colors[rep(1, nrow(vertices)),]
    }
    if (withNormals) {
      normals <- rgl.attrib(id, "normals")
      if (!nrow(normals))
      	normals <- 0*vertices
    }
    cbind(vertices, 
          if (withColors) 255*colors,
          if (withNormals) normals)
  }
  
  writeTriangles <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices)      
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, vertices)
    Triangles <<- rbind(Triangles, matrix(base + seq_len(n) - 1, 
                        ncol=3, byrow=TRUE))
  }
  
  writeQuads <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices)
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, vertices)
    Quads <<- rbind(Quads, matrix(base + seq_len(n) - 1, 
                        ncol=4, byrow=TRUE))
  }
      
  writeSurface <- function(id) {
    vertices <- getVertices(id)
    dims <- rgl.attrib(id, "dim")
    nx <- dims[1]
    nz <- dims[2]
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, vertices)
    rows <- seq_len(nx)
    for (i in seq_len(nz)[-nz]) 
      Triangles <<- rbind(Triangles, 
                        matrix(base + (i-1)*nx + 
                               c(rows[-nx],rows[-nx],
                                 rows[-1]+nx,rows[-nx]+nx,
                                 rows[-1],rows[-1]+nx) - 1,
                               ncol=3))
  }
  
  writeMesh <- function(mesh, scale=1, offset=c(0,0,0)) {
    vertices <- asEuclidean(t(mesh$vb))*scale 
    vertices <- vertices + rep(offset, each=nrow(vertices))
    if (withColors) {
      colors <- mesh$material$col
      if (!length(colors)) colors <- material3d("color")
      colors <- rep(colors, length=nrow(vertices))
      colors <- t(col2rgb(colors, alpha=TRUE))
    }
    if (withNormals) 
      normals <- asEuclidean(t(mesh$normals))
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, cbind(vertices, 
                                       if (withColors) colors,
                                       if (withNormals) normals))
    
    nt <- length(mesh$it)/3
    nq <- length(mesh$ib)/4
    if (nt) 
      Triangles <<- rbind(Triangles, t(mesh$it) - 1 + base)
    if (nq)
      Quads <<- rbind(Quads, t(mesh$ib) - 1 + base)
  }

  writeSpheres <- function(id) {
    vertices <- rgl.attrib(id, "vertices")
    n <- nrow(vertices)    
    colors <- rgl.attrib(id, "colors")
    if (nrow(colors) == 1)
      colors <- colors[rep(1, n),]
    radii <- rgl.attrib(id, "radii")
    radii <- rep(radii, length.out=n)
    x <- subdivision3d(icosahedron3d(),3)
    r <- sqrt(x$vb[1,]^2 + x$vb[2,]^2 + x$vb[3,]^2)
    x$vb[4,] <- r
    x$normals <- x$vb
    for (i in seq_len(n)) {
      col <- colors[i,]
      x$material$col <- rgb(col[1], col[2], col[3], col[4], maxColorValue = 255)
      writeMesh(x, radii[i], vertices[i,])
    }
  }  
  
  avgScale <- function() {
    bbox <- par3d("bbox")
    ranges <- c(bbox[2]-bbox[1], bbox[4]-bbox[3], bbox[6]-bbox[5])
    if (prod(ranges) == 0) 1
    else exp(mean(log(ranges)))
  }  
   
  writePoints <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices)
    inds <- seq_len(n)    
    if (pointsAsEdges) {
      if (withNormals)
        normals <- 0*vertices
      base <- nrow(Vertices)
      Vertices <<- rbind(Vertices, cbind(vertices, 
      					 if (withColors) colors,
      					 if (withNormals) normals))
      Edges <<- rbind(Edges, base + cbind(inds, inds) - 1 )  
    } else {
      radius <- pointRadius*avgScale()
      if (withNormals && is.null(pointShape$normals))
        pointShape <- addNormals(pointShape)
      for (i in inds) {
        if (withColors) {
          col <- vertices[i,4:7]
          pointShape$material$col <- rgb(col[1], col[2], col[3], col[4], maxColorValue = 255)
        }
        writeMesh(pointShape, radius, vertices[i,1:3])
      }
    }
  }
  
  writeSegments <- function(id) {
    vertices <- getVertices(id)
    if (withColors) {
      colors <- vertices[, 4:7, drop=FALSE]
      vertices <- vertices[, 1:3, drop=FALSE]
    }
    n <- nrow(vertices)
    n <- n/2
    inds <- seq_len(n)
    if (linesAsEdges) {
      base <- nrow(Vertices)
      Vertices <<- rbind(Vertices, vertices)
      Edges <<- rbind(Edges, base + cbind(2*inds - 2, 2*inds - 1) )  
    } else {
      radius <- lineRadius*avgScale()
      for (i in seq_len(n)) {
        cyl <- cylinder3d( vertices[(2*i-1):(2*i),1:3],
     			   radius = radius,
     			   sides = lineSides, 
     			   closed = -2 )
	if (withColors) {
          col1 <- colors[2*i-1,]
          col1 <- rgb(col1[1], col1[2], col1[3], col1[4], maxColorValue = 255)
          col2 <- colors[2*i,]
          col2 <- rgb(col2[1], col2[2], col2[3], col2[4], maxColorValue = 255)
        
          cyl$material$col <- c(rep(col1, lineSides),
                                rep(col2, lineSides), col1, col2)
        }
        if (withNormals)
          cyl <- addNormals(cyl)
        writeMesh(cyl)
      }
    }
  }
  
  writeLines <- function(id) {
    vertices <- getVertices(id)
    if (linesAsEdges) {
      n <- nrow(vertices)    
      inds <- seq_len(n)
      base <- nrow(Vertices)
      Vertices <<- rbind(Vertices, vertices)
      Edges <<- rbind(Edges, base + cbind(inds[-n], inds[-1]) - 1)  
    } else {
      n <- nrow(vertices) - 1
      radius <- lineRadius*avgScale()
      for (i in seq_len(n)) {
        cyl <- cylinder3d( vertices[i:(i+1),1:3],
     			   radius = radius,
     			   sides = lineSides, 
     			   closed = -2 )
        if (withColors) {
	  colors <- vertices[i, 4:7]
          col1 <- colors[i,]
          col1 <- rgb(col1[1], col1[2], col1[3], col1[4], maxColorValue = 255)
          col2 <- colors[i+1,]
          col2 <- rgb(col2[1], col2[2], col2[3], col2[4], maxColorValue = 255)
        
          cyl$material$col <- c(rep(col1, lineSides),
                                rep(col2, lineSides), col1, col2)
        }
        if (withNormals) 
          cyl <- addNormals(cyl)
        writeMesh(cyl)
      }
    }
  }
  
  knowntypes <- c("triangles", "quads",
                  "surface", "spheres", "linestrip", "lines", "planes",
                  "points")
  
  #  Execution starts here!
  format <- match.arg(format)

  if (is.character(con)) {
    con <- file(con, if (format=="ascii") "w" else "wb")
    on.exit(close(con))
  }
  filename <- summary(con)$description
  
  if (NROW(bbox <- rgl.ids("bboxdeco")) && (is.null(ids) || bbox$id %in% ids)) {
    ids <- setdiff(ids, bbox$id)
    save <- par3d(skipRedraw = TRUE)
    bbox <- convertBBox(bbox$id)
    on.exit({ rgl.pop(id=bbox); par3d(save) }, add=TRUE)
    dobbox <- TRUE
  } else dobbox <- FALSE 
  
  if (is.null(ids)) {
    ids <- rgl.ids()
    types <- as.character(ids$type)
    ids <- ids$id
  } else {
    if (dobbox) ids <- c(ids, bbox)
    allids <- rgl.ids()
    ind <- match(ids, allids$id)
    keep <- !is.na(ind)
    if (any(!keep)) warning("object(s) with id ", paste(ids[!keep], collapse=" "), " not found")
    ids <- ids[keep]
    types <- allids$type[ind[keep]]
  }  
    
  unknowntypes <- setdiff(types, knowntypes)
  if (length(unknowntypes))
    warning("Object type(s) ", 
      paste("'", unknowntypes, "'", sep="", collapse=", "), " not handled.")

  keep <- types %in% knowntypes
  ids <- ids[keep]
  types <- types[keep]

  for (i in seq_along(ids)) 
    switch(types[i],
      planes =,
      triangles = writeTriangles(ids[i]),
      quads = writeQuads(ids[i]),
      surface = writeSurface(ids[i]),
      spheres = writeSpheres(ids[i]),
      points = writePoints(ids[i]),
      lines = writeSegments(ids[i]),
      linestrip = writeLines(ids[i])
    )
  
  writeData()
  
  invisible(filename)
}
