writeOBJ <- function(con,
                     pointRadius=0.005, 
                     pointShape = icosahedron3d(),
                     lineRadius = pointRadius,
                     lineSides = 20,
                     pointsAsPoints = FALSE,
                     linesAsLines = FALSE,
                     withNormals = TRUE,
                     withTextures = TRUE,
                     separateObjects = TRUE,
                     ids = NULL) {
 
  writeHeader <- function() {
    ident <- paste(filename, " produced by RGL")
    cat("#", ident, "\n", file=con)
  }   
    
  Vertices <- 0
  Normals <- 0
  Texcoords <- 0
  
  writeData <- function(id) {
    vbase <- Vertices
    tbase <- Texcoords
    nbase <- Normals
    vertices <- rgl.attrib(id, "vertices")
    cat(paste("v", vertices[,1], vertices[,2], vertices[,3]), 
        sep="\n", file=con)
    n <- nrow(vertices)
    Vertices <<- Vertices + n
    if (withTextures) {
      textures <- rgl.attrib(id, "texcoords")
      if (nrow(textures)) 
        cat(paste("vt", textures[,1], textures[,2]),
          sep="\n", file=con)
      Texcoords <<- Texcoords + nrow(textures)
    }
    if (withNormals) {
      normals <- rgl.attrib(id, "normals")
      if (nrow(normals))
        cat(paste("vn", normals[,1], normals[,2], normals[,3]),
          sep="\n", file=con)
      Normals <<- Normals + nrow(normals)
    }
    list(n=n, 
         ntexcoords=if (withTextures) nrow(textures) else 0,
         nnormals=if (withNormals) nrow(normals) else 0,
         vbase=vbase,
         tbase=tbase,
         nbase=nbase)
  }
  
  refnum <- function(n) sprintf("%d", n)
  
  writeTriangles <- function(id) {
    if (separateObjects)
      cat("o triangles", id, "\n", sep="", file=con)
    x <- writeData(id)
    indices <- refnum(x$vbase + seq_len(x$n))
    if (x$ntexcoords)
      indices <- paste0(indices, "/", refnum(x$tbase + seq_len(x$n)))
    if (x$nnormals)
      indices <- paste0(indices, if (!x$ntexcoords) "/", 
      			"/", refnum(x$nbase + seq_len(x$n)))
    indices <- matrix(indices, ncol=3, byrow=TRUE)
    cat(paste("f", indices[,1], indices[,2], indices[,3]), 
        sep="\n", file=con)
  }
  
  writeQuads <- function(id) {
    if (separateObjects)
      cat("o quads", id, "\n", sep="", file=con)
    x <- writeData(id)
    indices <- refnum(x$vbase + seq_len(x$n))
    if (x$ntexcoords)
      indices <- paste0(indices, "/", refnum(x$tbase + seq_len(x$n)))
    if (x$nnormals)
      indices <- paste0(indices, if (!x$ntexcoords) "/", 
      			"/", refnum(x$nbase + seq_len(x$n)))
    indices <- matrix(indices, ncol=4, byrow=TRUE)
    cat(paste("f", indices[,1], indices[,2], indices[,3], indices[,4]), 
        sep="\n", file=con)
  }
      
  writeSurface <- function(id) {
    if (separateObjects)
      cat("o surface", id, "\n", sep="", file=con)
    x <- writeData(id)
    dims <- rgl.attrib(id, "dim")
    nx <- dims[1]
    nz <- dims[2]
    rows <- seq_len(nx)
    
    vertices <- matrix(character(0), ncol=3)
    for (i in seq_len(nz)[-nz]) {
      indices <- (i-1)*nx + 
      		c(rows[-nx],rows[-nx],
                  rows[-1]+nx,rows[-nx]+nx,
                  rows[-1],rows[-1]+nx)
      cindices <- refnum(x$vbase + indices)
      if (x$ntexcoords)
        cindices <- paste0(cindices, "/", refnum(x$tbase + indices))
      if (x$nnormals)
        cindices <- paste0(cindices, if (!x$ntexcoords) "/",
                           "/", refnum(x$nbase + indices))
      vertices <- rbind(vertices, matrix(cindices, ncol=3))
    }
    cat(paste("f", vertices[,1], vertices[,2], vertices[,3]),
        sep="\n", file=con)
  }      
  
  writeMesh <- function(mesh, scale=1, offset=c(0,0,0)) {
    vertices <- asEuclidean(t(mesh$vb))*scale 
    n <- nrow(vertices)
    vertices <- vertices + rep(offset, each=n)
    vbase <- Vertices
    cat(paste("v", vertices[,1], vertices[,2], vertices[,3]), 
        sep="\n", file=con)
    Vertices <<- Vertices + n
    if (withTextures && length(textures <- mesh$texcoords)) {
      tbase <- Texcoords
      textures <- asEuclidean(t(textures))
      cat(paste("vt", textures[,1], textures[,2]),
          sep="\n", file=con)
      Texcoords <<- Texcoords + nrow(textures)
    } else
      withTextures <- FALSE
    if (withNormals && length(normals <- mesh$normals)) {
      nbase <- Normals
      normals <- asEuclidean(t(normals))
      cat(paste("vn", normals[,1], normals[,2], normals[,3]),
          sep="\n", file=con)
      Normals <<- Normals + nrow(normals)
    } else
      withNormals <- FALSE
    nt <- length(mesh$it)/3
    nq <- length(mesh$ib)/4
    if (nt) {
      indices <- t(mesh$it)
      cindices <- refnum(vbase + indices)
      if (withTextures)
        cindices <- paste0(cindices, "/", refnum(tbase + indices))
      if (withNormals)
        cindices <- paste0(cindices, if (!withTextures) "/",
                           "/", refnum(nbase + indices))
      cindices <- matrix(cindices, ncol=3)
      cat(paste("f", cindices[,1], cindices[,2], cindices[,3]), 
          sep="\n", file=con)
    }
    if (nq) {
      indices <- t(mesh$ib)
      cindices <- refnum(vbase + indices)
      if (withTextures)
        cindices <- paste0(cindices, "/", refnum(tbase + indices))
      if (withNormals)
        cindices <- paste0(cindices, if (!withTextures) "/",
                           "/", refnum(nbase + indices))
      cindices <- matrix(cindices, ncol=4)
      cat(paste("f", cindices[,1], cindices[,2], 
                     cindices[,3], cindices[,4]), 
          sep="\n", file=con)
    }
  }

  writeSpheres <- function(id) {
    if (separateObjects)
      cat("o sphere", id, "\n", sep="", file=con) 
    vertices <- rgl.attrib(id, "vertices")
    n <- nrow(vertices)    
    radii <- rgl.attrib(id, "radii")
    radii <- rep(radii, length.out=n)
    x <- subdivision3d(icosahedron3d(),3)
    r <- sqrt(x$vb[1,]^2 + x$vb[2,]^2 + x$vb[3,]^2)
    x$vb[4,] <- r
    x$normals <- x$vb
    for (i in seq_len(n)) 
      writeMesh(x, radii[i], vertices[i,])
  }  
  
  avgScale <- function() {
    bbox <- par3d("bbox")
    ranges <- c(bbox[2]-bbox[1], bbox[4]-bbox[3], bbox[6]-bbox[5])
    if (prod(ranges) == 0) 1
    else exp(mean(log(ranges)))
  }  
   
  writePoints <- function(id) {
    if (separateObjects)
      cat("o points", id, "\n", sep="", file=con)
    if (pointsAsPoints) {
      x <- writeData(id)
      cat("p", refnum(x$vbase + seq_len(x$n)), "\n", file=con)
    } else {
      vertices <- rgl.attrib(id, "vertices")
      n <- nrow(vertices)
      radius <- pointRadius*avgScale()
      if (withNormals && is.null(pointShape$normals))
        pointShape <- addNormals(pointShape)
      for (i in seq_len(n)) 
        writeMesh(pointShape, radius, vertices[i,])
    }
  }
  
  writeSegments <- function(id) {
    if (separateObjects)
      cat("o segments", id, "\n", sep="", file=con)
    if (linesAsLines) {
      x <- writeData(id)
      indices <- matrix(refnum(x$vbase + seq_len(x$n)), ncol=2, byrow=TRUE)
      cat(paste("l", indices[,1], indices[,2]), sep="\n", file=con)
    } else {
      vertices <- rgl.attrib(id, "vertices")
      n <- nrow(vertices)    
      n <- n/2
      radius <- lineRadius*avgScale()
      for (i in seq_len(n)) {
        cyl <- cylinder3d( vertices[(2*i-1):(2*i),1:3],
     			   radius = radius,
     			   sides = lineSides, 
     			   closed = -2 )
        if (withNormals)
          cyl <- addNormals(cyl)
        writeMesh(cyl)
      }
    }
  }
  
  writeLines <- function(id) {
    if (separateObjects)
      cat("o lines", id, "\n", sep="", file=con)
    if (linesAsLines) {
      x <- writeData(id)
      indices <- refnum(x$vbase + seq_len(x$n))
      cat("l", indices, "\n", file=con)
    } else {
      vertices <- rgl.attrib(id, "vertices")
      n <- nrow(vertices) - 1
      radius <- lineRadius*avgScale()
      for (i in seq_len(n)) {
        cyl <- cylinder3d( vertices[i:(i+1),],
     			   radius = radius,
     			   sides = lineSides, 
     			   closed = -2 )
        if (withNormals) 
          cyl <- addNormals(cyl)
        writeMesh(cyl)
      }
    }
  }
  
  knowntypes <- c("triangles", "quads", #,
                  "surface", "spheres", "points", 
                  "linestrip", "lines", "planes")
  
  #  Execution starts here!

  if (is.character(con)) {
    con <- file(con, "w")
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
  
  writeHeader()

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
  
  invisible(filename)
}

readOBJ <- function(con, ...) {
  lines <- readLines(con)
  instrs <- sub(" .*", "", lines)
  vertices <- read.table(textConnection(lines[instrs == "v"]),
                         col.names = c("instr", "x", "y", "z"),
                         colClasses = c(instr = "character", 
                                        x="numeric",
                                        y="numeric",
                                        z="numeric"))
  vertices <- with(vertices, rbind(x, y, z))
  tfaces <- grepl("^f\\W+\\w+\\W+\\w+\\W+\\w+$", lines)
  triangles <- read.table(textConnection(lines[tfaces]),
                      col.names = c("instr", "v1", "v2", "v3"),
                      colClasses = "character")
  triangles <- with(triangles, rbind(v1, v2, v3))
  if (length(grep("/", triangles))) {
    warning("normals and/or textures ignored")
    triangles <- sub("/.*", "", triangles)   
  }
  triangles <- structure(as.numeric(triangles),
                         dim = dim(triangles))
  qfaces <- grepl("^f\\W+\\w+\\W+\\w+\\W+\\w+\\W+\\w+$", lines)
  if (any(qfaces)) {
    quads <- read.table(textConnection(lines[qfaces]),
                        col.names = c("instr", "v1", "v2", "v3", "v4"),
                        colClasses = "character")
    quads <- with(quads, rbind(v1, v2, v3, v4))
    if (length(grep("/", quads))) {
      warning("normals and/or textures ignored")
      quads <- sub("/.*", "", quads)
    }
    quads <- structure(as.numeric(quads), dim = dim(quads))
  }
  others <- strsplit(lines[instrs == "f" & !tfaces & !qfaces], " ")
  # FIXME:  this will be really slow if there are a lot of others
  # Should pre-allocate extra space.
  for (i in seq_along(others)) {
    v <- as.numeric(others[[i]][-1])
    tri <- triangulate(t(vertices[,v]))
    tri <- structure(v[tri], dim = dim(tri))
    triangles <- cbind(triangles, tri)
  }  
  ignored <- unique(instrs)
  ignored <- ignored[!(ignored %in% c("v", "f", "", "#"))]
  if (length(ignored))
    warning("instructions ", paste0('"', ignored, '"', collapse = ", "), " ignored.")
  result <- tmesh3d(vertices, triangles, homogeneous = FALSE, ...)
  if (any(qfaces)) 
    result$ib <- quads
  result
}
