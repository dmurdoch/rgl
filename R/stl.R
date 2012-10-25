writeSTL <- function(con, ascii=FALSE) {
 
  writeHeader <- function() {
    ident <- paste(filename, " produced by RGL\n")
    if (ascii) 
      cat("solid ", ident, file=con)
    else {
      padding <- paste(rep(" ", 80), collapse="")
      ident <- substr( paste("binary", ident, padding), 1, 80)
      writeChar(ident, con, nchars=80, useBytes=TRUE, eos=NULL)
      writeBin(0L, con, size=4, endian="little")
    }
  }
      
  triangles <- 0
  
  writeTriangles <- function(vertices) {
    if (nrow(vertices) %% 3 != 0) stop("Need 3N vertices")
    n <- nrow(vertices) / 3
    for (i in seq_len(n)) {
      vec0 <- vertices[3*i - 2,]
      vec1 <- vertices[3*i - 1,]
      vec2 <- vertices[3*i,]
      normal <- normalize(xprod(vec2-vec0, vec1-vec0))
      if (ascii) {
        cat("facet normal ", normal, "\n", file=con)
        cat("outer loop\n", file=con)
        cat("vertex ", vec0, "\n", file=con)
        cat("vertex ", vec1, "\n", file=con)
        cat("vertex ", vec2, "\n", file=con)
        cat("endloop\n", file=con)
        cat("endfacet\n", file=con)
      } else {
        writeBin(c(normal, vec0, vec1, vec2), con, size=4, endian="little")
        writeBin(0L, con, size=2, endian="little")
      }
    }
    triangles <<- triangles + n
  }
  
  writeQuads <- function(vertices) {
    if (nrow(vertices) %% 4 != 0) stop("Need 4N vertices")
    n <- nrow(vertices) / 4
    indices <- rep(seq_len(n)*4, each=6) - rep(c(3, 2, 1, 3, 1, 0), n)
    writeTriangles( vertices[indices,] )
  }
      
  writeSurface <- function(id) {
    vertices <- rgl.attrib(id, "vertices")
    dims <- rgl.attrib(id, "dim")
    nx <- dims[1]
    nz <- dims[2]
    indices <- integer(0)
    for (j in seq_len(nx-1) - 1) {
      v1 <- j + nx*(seq_len(nz) - 1) + 1
      indices <- c(indices, rbind(v1[-nz], v1[-nz]+1, v1[-1]+1, v1[-1]))
    }
    writeQuads(vertices[indices,])
  }
      
  knowntypes <- c("triangles", "quads",
                  "surface", "planes", # "spheres"
                  )
  
  #  Execution starts here!

  if (is.character(con)) {
    con <- file(con, if (ascii) "w" else "wb")
    on.exit(close(con))
  }
  filename <- summary(con)$description
  
  ids <- rgl.ids()
  types <- as.character(ids$type)
  ids <- ids$id
    
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
      triangles = writeTriangles(rgl.attrib(ids[i], "vertices")),
      quads = writeQuads(rgl.attrib(ids[i], "vertices")),
      surface = writeSurface(ids[i])
    )
  
  if (!ascii) {
    seek(con, 80)
    writeBin(as.integer(triangles), con, size=4, endian="little")
  }
    
  invisible(filename)
}

readSTL <- function(con, ascii=FALSE, plot=TRUE, ...) {
 
  # Utility functions and constants defined first; execution starts way down there...
  
  triangles <- NULL
  
  readHeader <- function() {
    if (ascii) {
      ident <- readLines(con, 1)
      if (!grepl("^solid ", ident)) stop("this does not appear to be an ASCII STL file")
    }
    if (!ascii) {
      seek(con, 80)
      triangles <<- readBin(con, "integer", n=1, size=4, endian="little")
    }
  }
  
  readTriangles <- function(n) {
    
    if (ascii) {
      lines <- readLines(con)
      if (is.null(n)) n <- lines %/% 7
    }
   
    vertices <- matrix(NA, 3*n, 3)
    
    if (!ascii) {
      for (i in seq_len(n)) {
        m <- matrix(readBin(con, "double", n=12, size=4, endian="little"), 4, 3, byrow=TRUE)
        vertices[3*i + c(-2,-1,0),] <- m[2:4,]
        count <- readBin(con, "integer", n=1, size=2, endian="little")
      }
    }
    vertices
  }
      
  #  Execution starts here!
  
  if (ascii) stop("ASCII input not yet supported")

  if (is.character(con)) {
    con <- file(con, if (ascii) "rt" else "rb")
    on.exit(close(con))
  }
  
  readHeader()
  vertices <- readTriangles(triangles)
  if (plot)
    triangles3d(vertices, ...)
  else
    vertices
}
