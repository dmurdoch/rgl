writePLY <- function(
    con,
    format = c("little_endian", "big_endian", "ascii"),
    pointRadius = 0.005,
    pointShape = icosahedron3d(),
    lineRadius = pointRadius,
    lineSides = 20,
    pointsAsEdges = FALSE,
    linesAsEdges = pointsAsEdges,
    withColors = TRUE,
    withNormals = !(pointsAsEdges || linesAsEdges),
    ids = tagged3d(tags), tags = NULL) {
  ##############################################################################
  ### DEFINE INTERNAL FUNCTIONS ################################################
  ##############################################################################

  # Write Data -----------------------------------------------------------------
  writeData <- function() {
    cat("ply\n", file = con)
    
    fmt <- switch(format,
      little_endian = "binary_little_endian",
      big_endian = "binary_big_endian",
      ascii = "ascii"
    )

    cat("format", fmt, "1.0\n", file = con)
    cat("element vertex", nrow(Vertices), "\n", file = con)
    cat("property float x\nproperty float y\nproperty float z\n", file = con)
    
    if (withNormals) {
      cat(
        "property float nx\nproperty float ny\nproperty float nz\n",
        file = con
      )
    }
    
    if (withColors) {
      cat(
        "property uchar red\nproperty uchar green\nproperty uchar blue\nproperty uchar alpha\n",
        file = con
      )
    }
    
    cat("element face", nrow(Triangles) + nrow(Quads), "\n", file = con)
    cat("property list uchar int vertex_indices\n", file = con)
    
    if (nrow(Edges) > 0) {
      cat("element edge", nrow(Edges), "\n", file = con)
      cat("property int vertex1\nproperty int vertex2\n", file = con)
    }
    
    cat("end_header\n", file = con)

    if (format == "ascii") {
      
      for (i in seq_len(nrow(Vertices))) {
        cat(Vertices[i, ], file = con)
        if (withColors) {
          cat("", Colors[i, ], file = con)
        }
        cat("\n", file = con)
      }
      
      for (i in seq_len(nrow(Triangles))) {
        cat("3", Triangles[i, ], "\n", file = con)
      }
      
      for (i in seq_len(nrow(Quads))) {
        cat("4", Quads[i, ], "\n", file = con)
      }
      
      for (i in seq_len(nrow(Edges))) {
        cat(Edges[i, ], "\n", file = con)
      }
      
    } else {
      endian <- if (format == "little_endian") "little" else "big"
      
      if (nrow(Vertices)) {
        for (i in seq_len(nrow(Vertices))) {
          writeBin(as.numeric(Vertices[i, ]), con, size = 4, endian = endian)
          if (withColors) {
            writeBin(as.integer(Colors[i, ]), con, size = 1, endian = endian)
          }
        }
      }
      
      if (nrow(Triangles)) {
        for (i in seq_len(nrow(Triangles))) {
          writeBin(3L, con, size = 1, endian = endian)
          writeBin(as.integer(Triangles[i, ]), con, size = 4, endian = endian)
        }
      }
      
      if (nrow(Quads)) {
        for (i in seq_len(nrow(Quads))) {
          writeBin(4L, con, size = 1, endian = endian)
          writeBin(as.integer(Quads[i, ]), con, size = 4, endian = endian)
        }
      }
      
      if (nrow(Edges)) {
        writeBin(as.integer(t(Edges)), con, size = 4, endian = endian)
      }
    }
  }

  # Get Vertices  --------------------------------------------------------------
  getVertices <- function(id) {
    vertices <- rgl.attrib(id, "vertices")
    if (withNormals) {
      normals <- rgl.attrib(id, "normals")
      if (!nrow(normals)) {
        normals <- 0 * vertices
      }
    }
    cbind(
      vertices,
      if (withNormals) normals
    )
  }

  # Get Colors -----------------------------------------------------------------
  getColors <- function(id) {
    vertices <- rgl.attrib(id, "vertices")
    if (withColors) {
      colors <- rgl.attrib(id, "colors")
      if (nrow(colors) == 1) {
        colors <- colors[rep(1, nrow(vertices)), , drop = FALSE]
      }
      colors <- round(255 * colors)
      mode(colors) <- "integer"
      colors
    } else {
      NULL
    }
  }

  # Writing Functions ----------------------------------------------------------
  writeTriangles <- function(id) {
    vertices <- getVertices(id)
    colors <- getColors(id)
    n <- nrow(vertices)
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, vertices)
    Colors <<- rbind(Colors, colors)
    Triangles <<- rbind(Triangles, matrix(base + getIndices(id) - 1,
      ncol = 3, byrow = TRUE
    ))
  }

  writeQuads <- function(id) {
    vertices <- getVertices(id)
    colors <- getColors(id)
    n <- nrow(vertices)
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, vertices)
    Colors <<- rbind(Colors, colors)
    Quads <<- rbind(Quads, matrix(base + getIndices(id) - 1,
      ncol = 4, byrow = TRUE
    ))
  }

  writeSurface <- function(id) {
    vertices <- getVertices(id)
    colors <- getColors(id)
    dims <- rgl.attrib(id, "dim")
    nx <- dims[1]
    nz <- dims[2]
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, vertices)
    Colors <<- rbind(Colors, colors)
    rows <- seq_len(nx)
    for (i in seq_len(nz)[-nz]) {
      indices <- getIndices(id)[(i - 1) * nx +
        c(
          rows[-nx], rows[-nx],
          rows[-1] + nx, rows[-nx] + nx,
          rows[-1], rows[-1] + nx
        )]
      Triangles <<- rbind(
        Triangles,
        matrix(base + indices - 1,
          ncol = 3
        )
      )
    }
  }

  writeMesh <- function(mesh, scale = 1, offset = c(0, 0, 0)) {
    vertices <- asEuclidean(t(mesh$vb)) * scale
    vertices <- vertices + rep(offset, each = nrow(vertices))
    if (withColors) {
      colors <- mesh$material$col
      if (!length(colors)) colors <- material3d("color")
      colors <- rep(colors, length.out = nrow(vertices))
      colors <- t(col2rgb(colors, alpha = TRUE))
      Colors <<- rbind(Colors, colors)
    }
    if (withNormals) {
      normals <- asEuclidean(t(mesh$normals))
    }
    base <- nrow(Vertices)
    Vertices <<- rbind(Vertices, cbind(
      vertices,
      if (withNormals) normals
    ))
    nt <- length(mesh$it) / 3
    nq <- length(mesh$ib) / 4
    if (nt) {
      Triangles <<- rbind(Triangles, t(mesh$it) - 1 + base)
    }
    if (nq) {
      Quads <<- rbind(Quads, t(mesh$ib) - 1 + base)
    }
  }

  writeSpheres <- function(id) {
    vertices <- expandVertices(id)
    n <- nrow(vertices)
    colors <- expandColors(id)
    if (nrow(colors) == 1) {
      colors <- colors[rep(1, n), , drop = FALSE]
    }
    radii <- expandAttrib(id, "radii")
    radii <- rep(radii, length.out = n)
    x <- subdivision3d(icosahedron3d(), 3)
    r <- sqrt(x$vb[1, ]^2 + x$vb[2, ]^2 + x$vb[3, ]^2)
    x$vb[4, ] <- r
    x$normals <- x$vb
    for (i in seq_len(n)) {
      col <- colors[i, ]
      x$material$col <- rgb(col[1], col[2], col[3], col[4], maxColorValue = 255)
      writeMesh(x, radii[i], vertices[i, ])
    }
  }

  writePoints <- function(id) {
    vertices <- getVertices(id)
    colors <- getColors(id)
    n <- nrow(vertices)
    inds <- getIndices(id)
    if (pointsAsEdges) {
      base <- nrow(Vertices)
      Vertices <<- rbind(Vertices, vertices)
      if (withColors) {
        Colors <<- rbind(Colors, colors)
      }
      Edges <<- rbind(Edges, base + cbind(inds, inds) - 1)
    } else {
      radius <- pointRadius * avgScale()
      if (withNormals && is.null(pointShape$normals)) {
        pointShape <- addNormals(pointShape)
      }
      for (i in inds) {
        if (withColors) {
          col <- vertices[i, 4:7]
          pointShape$material$col <- rgb(col[1], col[2], col[3], col[4], maxColorValue = 255)
        }
        writeMesh(pointShape, radius, vertices[i, 1:3])
      }
    }
  }

  writeSegments <- function(id) {
    vertices <- getVertices(id)
    colors <- getColors(id)
    inds <- getIndices(id)
    n <- length(inds) / 2
    if (linesAsEdges) {
      base <- nrow(Vertices)
      Vertices <<- rbind(Vertices, vertices)
      if (withColors) {
        Colors <<- rbind(Colors, colors)
      }
      Edges <<- rbind(Edges, base + matrix(inds, ncol = 2, byrow = TRUE) - 1)
    } else {
      radius <- lineRadius * avgScale()
      for (i in seq_len(n)) {
        cyl <- cylinder3d(vertices[inds[(2 * i - 1):(2 * i)], 1:3],
          radius = radius,
          sides = lineSides,
          closed = -2
        )
        if (withColors) {
          col1 <- colors[inds[2 * i - 1], ]
          col1 <- rgb(col1[1], col1[2], col1[3], col1[4], maxColorValue = 255)
          col2 <- colors[inds[2 * i], ]
          col2 <- rgb(col2[1], col2[2], col2[3], col2[4], maxColorValue = 255)

          cyl$material$col <- c(
            rep(col1, lineSides),
            rep(col2, lineSides), col1, col2
          )
        }
        if (withNormals) {
          cyl <- addNormals(cyl)
        }
        writeMesh(cyl)
      }
    }
  }

  writeLines <- function(id) {
    vertices <- getVertices(id)
    colors <- getColors(id)
    if (linesAsEdges) {
      inds <- getIndices(id)
      n <- length(inds)
      base <- nrow(Vertices)
      Vertices <<- rbind(Vertices, vertices)
      if (withColors) {
        Colors <<- rbind(Colors, colors)
      }
      Edges <<- rbind(Edges, base + cbind(inds[-n], inds[-1]) - 1)
    } else {
      n <- nrow(vertices) - 1
      radius <- lineRadius * avgScale()
      colors <- vertices[, 4:7, drop = FALSE]
      for (i in seq_len(n)) {
        cyl <- cylinder3d(vertices[inds[i:(i + 1)], 1:3],
          radius = radius,
          sides = lineSides,
          closed = -2
        )
        if (withColors) {
          col1 <- colors[inds[i], ]
          col1 <- rgb(col1[1], col1[2], col1[3], col1[4], maxColorValue = 255)
          col2 <- colors[inds[i + 1], ]
          col2 <- rgb(col2[1], col2[2], col2[3], col2[4], maxColorValue = 255)

          cyl$material$col <- c(
            rep(col1, lineSides),
            rep(col2, lineSides), col1, col2
          )
        }
        if (withNormals) {
          cyl <- addNormals(cyl)
        }
        writeMesh(cyl)
      }
    }
  }

  # Average Scale --------------------------------------------------------------
  avgScale <- function() {
    bbox <- par3d("bbox")
    ranges <- c(bbox[2] - bbox[1], bbox[4] - bbox[3], bbox[6] - bbox[5])
    if (prod(ranges) == 0) {
      1
    } else {
      exp(mean(log(ranges)))
    }
  }

  # Define Known Types ---------------------------------------------------------
  knowntypes <- c(
    "triangles", "quads",
    "surface", "spheres", "linestrip", "lines", "planes",
    "points"
  )

  ##############################################################################
  ### RUN WRITEPLY #############################################################
  ##############################################################################
  
  Vertices <- matrix(0, 0, 3 + 3 * withNormals)
  Colors <- matrix(0L, 0, 4 * withColors)
  
  Triangles <- matrix(1L, 0, 3)
  Quads <- matrix(1L, 0, 4)
  Edges <- matrix(1L, 0, 2)
  
  format <- match.arg(format)

  if (is.character(con)) {
    con <- file(con, if (format == "ascii") "w" else "wb")
    on.exit(close(con))
  }

  filename <- summary(con)$description

  if (NROW(bbox <- ids3d("bboxdeco")) && (is.null(ids) || bbox$id %in% ids)) {
    ids <- setdiff(ids, bbox$id)
    save <- par3d(skipRedraw = TRUE)
    bbox <- convertBBox(bbox$id)
    on.exit(
      {
        pop3d(id = bbox)
        par3d(save)
      },
      add = TRUE
    ) # nolint
    dobbox <- TRUE
  } else {
    dobbox <- FALSE
  }

  if (is.null(ids)) {
    ids <- ids3d()
    types <- as.character(ids$type)
    ids <- ids$id
  } else {
    if (dobbox) ids <- c(ids, bbox)
    allids <- ids3d()
    ind <- match(ids, allids$id)
    keep <- !is.na(ind)
    if (any(!keep)) {
      warning(gettextf("Object(s) with id %s not found", paste(ids[!keep], collapse = " ")),
        domain = NA
      )
    }
    ids <- ids[keep]
    types <- allids$type[ind[keep]]
  }

  unknowntypes <- setdiff(types, knowntypes)
  if (length(unknowntypes)) {
    warning(gettextf(
      "Object type(s) %s not handled",
      paste("'", unknowntypes, "'", sep = "", collapse = ", ")
    ), domain = NA)
  }

  keep <- types %in% knowntypes
  ids <- ids[keep]
  types <- types[keep]

  for (i in seq_along(ids)) {
    switch(types[i],
      planes = ,
      triangles = writeTriangles(ids[i]),
      quads = writeQuads(ids[i]),
      surface = writeSurface(ids[i]),
      spheres = writeSpheres(ids[i]),
      points = writePoints(ids[i]),
      lines = writeSegments(ids[i]),
      linestrip = writeLines(ids[i])
    )
  }

  writeData()

  invisible(filename)
}
