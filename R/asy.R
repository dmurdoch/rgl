writeASY <- function(title = "scene",
		     outtype = c("pdf", "eps", "asy", "latex", "pdflatex"),
		     prc = TRUE,
		     runAsy = "asy %filename%",
		     defaultFontsize = 12,
		     width = 7, height = 7,
		     ppi = 100,
                     ids = NULL) {
  withColors <- TRUE
  withNormals <- FALSE

  outtype <- match.arg(outtype)
  
  writeHeader <- function() {
    outformat <- c(pdf = "pdf", eps = "eps", asy = "",
    	           latex = "eps", pdflatex = "pdf")[outtype]
    prc <- if (prc) "true" else "false"
    userMatrix <- par3d("userMatrix")
    defaultObserver <- (c(par3d("observer"), 1) %*% userMatrix)[1:3]
    up <- (c(0, 1, 0, 1) %*% userMatrix)[1:3]
    FOV <- par3d("FOV")*pi/180
    if (FOV > 0) {
      projection <- "perspective"
      dist <- 0.8/tan(FOV/2)
      defaultObserver <- defaultObserver*dist/sqrt(sum(defaultObserver^2))
    } else 
      projection <- "orthographic"
    result <<- c(result, subst(
'// %title% produced by rgl', title),
      if (outtype %in% c("pdf", "eps")) subst(
'settings.outformat = "%outformat%";', outformat),
      subst(
'settings.prc = %prc%;
size(%width%inches, %height%inches);
import three;
currentprojection = %projection%(%x%, %y%, %z%, up = (%ux%, %uy%, %uz%));
defaultpen(fontsize(%defaultFontsize%));', 
  prc, width, height,
  x=defaultObserver[1], y=defaultObserver[2], z=defaultObserver[3],
  ux = up[1], uy = up[2], uz = up[3],
  projection,
  defaultFontsize))
  }
  
  getVertices <- function(id) {
    scale <- par3d("scale")
    scale <- scale/avgScale()
    vertices <- rgl.attrib(id, "vertices")
    vertices[,1:3] <- vertices[,1:3] %*% diag(scale)
    if (withColors) {
      colors <- rgl.attrib(id, "colors")
      if (nrow(colors) == 1)
        colors <- colors[rep(1, nrow(vertices)),,drop = FALSE]
    }
    if (withNormals) {
      normals <- rgl.attrib(id, "normals")
      if (!nrow(normals))
      	normals <- 0*vertices
    }
    cbind(vertices, 
          if (withColors) colors,
          if (withNormals) normals)
  }
  
  rgba <- c("r", "g", "b", "a")
  lastCol <- c(0,0,0,1)  
  lastSize <- 0.5
  setPen <- function(col = lastCol, size = lastSize) {
    if (any(col != lastCol) || size != lastSize) {
      result <<- c(result, subst(
  	'currentpen = rgb(%r%, %g%, %b%) + opacity(%a%) + linewidth(%size%);',
  	r = col[1], g = col[2], b = col[3], a = col[4], size = size))
      lastCol <<- col
      lastSize <<- size
    }
  }
  	
  writePoly <- function(vertices) {
    if (any(!is.finite(vertices)))
      return();
    setPen(apply(vertices[, rgba], 2, mean))
    v <- vertices[1, 1:3]
    result <<- c(result, subst('draw(surface((%x%, %y%, %z%)', x=v[1], y=v[2], z=v[3]))
    for (j in seq_len(nrow(vertices))[-1]) {
      v <- vertices[j, 1:3]
      result <<- c(result, subst('--(%x%, %y%, %z%)', x=v[1], y=v[2], z=v[3]))
    }
    result <<- c(result, '--cycle));')
  }
  
  writeTriangles <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices) %/% 3
    for (i in seq_len(n)) 
      writePoly(vertices[3*i-2:0,])
  }
  
  writeQuads <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices) %/% 4
    for (i in seq_len(n)) 
      writePoly(vertices[4*i-3:0,])
  }
  
  writeSurface <- function(id) {
    vertices <- getVertices(id)
    dims <- rgl.attrib(id, "dim")
    nx <- dims[1]
    nz <- dims[2]
    for (i in seq_len(nz)[-nz]) 
      for (j in seq_len(nx)[-nx]) 
      	writePoly(vertices[c((i-1)*nx + j, i*nx + j, i*nx + j + 1, (i-1)*nx + j + 1),])
  }
  
  writeSpheres <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices)    
    radii <- rgl.attrib(id, "radii")
    radii <- rep(radii, length.out=n)
    for (i in seq_len(n)) {
      setPen(vertices[i, rgba])
      v <- vertices[i, 1:3]
      result <<- c(result, subst('draw(shift((%x%, %y%, %z%))*scale3(%r%)*unitsphere);',
      	x = v[1], y = v[2], z = v[3], r = radii[i]))  
    }
  }  
  
  avgScale <- function() {
    bbox <- par3d("bbox")
    ranges <- c(bbox[2]-bbox[1], bbox[4]-bbox[3], bbox[6]-bbox[5])
    if (prod(ranges) == 0) 1
    else exp(mean(log(ranges)))
  }  
   
  writePoints <- function(id) {
    setPen(size = rgl.getmaterial(0, id)$size*72/ppi)
    vertices <- getVertices(id)
    n <- nrow(vertices)
    for (i in seq_len(n)) {
      setPen(vertices[i, rgba])
      result <<- c(result, subst('draw((%x%, %y%, %z%));', 
        x = vertices[i, 1], y = vertices[i, 2], z = vertices[i, 3]))
    }
  }
  
  writeText <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices)
    texts <- rgl.attrib(id, "texts")
    texts <- rep(texts, length.out = n)
    adj <- rgl.attrib(id, "adj")
    adj <- adj[rep(seq_len(nrow(adj)), length.out = n),, drop = FALSE]
    for (i in seq_len(n)) {
      setPen(vertices[i, rgba])	
      if (all(!is.na(vertices[i, 1:3]))) 
      	result <<- c(result, subst('label("%text%", position = (%x%, %y%, %z%), align = (%ax%,%ay%));', 
          x = vertices[i, 1], y = vertices[i, 2], z = vertices[i, 3],
          text = texts[i], ax = 1-2*adj[i, 1], ay = 1-2*adj[i, 2]))
    }
  }
  
  writeSegments <- function(id) {
    setPen(size = rgl.getmaterial(0, id)$lwd*72/ppi)
    vertices <- getVertices(id)
    n <- nrow(vertices) %/% 2    
    for (i in seq_len(n)) {
      i1 <- 2*i - 1
      i2 <- i1 + 1
      if (all(!is.na(vertices[c(i1, i2), 1:3]))) {
      	setPen((vertices[i1, rgba] + vertices[i2, rgba])/2)
  	result <<- c(result, subst('draw((%x1%, %y1%, %z1%)--(%x2%, %y2%, %z2%));', 
          x1 = vertices[i1, 1], y1 = vertices[i1, 2], z1 = vertices[i1, 3],
          x2 = vertices[i2, 1], y2 = vertices[i2, 2], z2 = vertices[i2, 3]))
      }
    }
  }
  
  writeLines <- function(id) {
    setPen(size = rgl.getmaterial(0, id)$lwd*72/ppi)          
    vertices <- getVertices(id)
    n <- nrow(vertices)    
    inds <- seq_len(n)
    open <- FALSE
    for (i in seq_len(n)) {
      if (open) {
      	if (any(is.na(vertices[i, 1:3]))) {
      	  result <<- c(result, ");")
      	  open <- FALSE
      	} else 
      	  result <<- c(result, subst('--(%x%, %y%, %z%)',
      	    x = vertices[i, 1], y = vertices[i, 2], z = vertices[i, 3]))
      } else 
      	if (all(!is.na(vertices[i, 1:3]))) {
      	  setPen(vertices[i, rgba])
      	  result <<- c(result, subst('draw((%x%, %y%, %z%)',
      	    x = vertices[i, 1], y = vertices[i, 2], z = vertices[i, 3]))
      	  open = TRUE
      	}
    }
    if (open)
      result <<- c(result, ');')
  }
  
  writeBackground <- function(id) {
    col <- rgl.attrib(id, "color")
    result <<- c(result, subst(
      'currentlight.background = rgb(%r%, %g%, %b%);',
      r = col[1], g=col[2], b=col[3]
    ))
  }
  
  knowntypes <- c("points", "linestrip", "lines",
  		  "text", "triangles", "quads", "surface",
  		  "spheres", "planes", "abclines",
  		  "background")
  
  #  Execution starts here!

  if (NROW(bbox <- rgl.ids("bboxdeco")) && (is.null(ids) || bbox$id %in% ids)) {
    ids <- setdiff(ids, bbox$id)
    save <- par3d(skipRedraw = TRUE)
    bbox <- convertBBox(bbox$id)
    on.exit({ rgl.pop(id=bbox); par3d(save) }, add=TRUE)
    dobbox <- TRUE
  } else dobbox <- FALSE 
  
  if (is.null(ids)) {
    ids <- rgl.ids(c("shapes", "background"))
    types <- as.character(ids$type)
    ids <- ids$id
  } else {
    if (dobbox) ids <- c(ids, bbox)
    allids <- rgl.ids()
    ind <- match(ids, allids$id)
    keep <- !is.na(ind)
    if (any(!keep)) warning(gettextf("Object(s) with id %s not found", paste(ids[!keep], collapse=" ")), 
    			    domain = NA)
    ids <- ids[keep]
    types <- allids$type[ind[keep]]
  }  
    
  unknowntypes <- setdiff(types, knowntypes)
  if (length(unknowntypes))
    warning(gettextf("Object type(s) %s not handled", 
      paste("'", unknowntypes, "'", sep="", collapse=", ")), domain = NA)

  keep <- types %in% knowntypes
  ids <- ids[keep]
  types <- types[keep]
  
  result <- NULL
  writeHeader()

  for (i in seq_along(ids)) {
    result <<- c(result, subst('// %type% object %id%', type = types[i], id = ids[i]))
    switch(types[i],
      planes =,
      triangles = writeTriangles(ids[i]),
      quads = writeQuads(ids[i]),
      surface = writeSurface(ids[i]),
      spheres = writeSpheres(ids[i]),
      points = writePoints(ids[i]),
      abclines =,
      lines = writeSegments(ids[i]),
      linestrip = writeLines(ids[i]),
      text = writeText(ids[i]),
      background = writeBackground(ids[i])
    )
  }
  if (outtype %in% c("latex", "pdflatex")) {
    filename <- paste0(title, ".tex")
    result <- c("\\begin{asy}", result, "\\end{asy}")
  } else
    filename <- paste0(title, ".asy")
  base::writeLines(result, filename) 
  if (outtype %in% c("pdf", "eps")) {
    system(subst(runAsy, filename))
    filename <- paste0(title, outtype)
  }
  invisible(filename)
}
