writeASY <- function(scene = scene3d(),
                     title = "scene",
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
    userMatrix <- get.par3d("userMatrix")
    defaultObserver <- (c(get.par3d("observer"), 1) %*% userMatrix)[1:3]
    up <- (c(0, 1, 0, 1) %*% userMatrix)[1:3]
    FOV <- get.par3d("FOV")*pi/180
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
  
  # simulate rgl.attrib
  get.attrib <- function(id, attrib) { 
    obj <- scene$objects[[as.character(id)]]
    obj[[attrib]]
  }
  
  # simulate rgl.ids
  get.ids <- function(type = "shapes") {
    ids <- names(scene$objects)
    types <- vapply(ids, function(x) scene$objects[[x]]$type, "")
    if (length(s <- which(type %in% "shapes"))) {
      type <- c(type[-s], "points", "linestrip", "lines",
                "text", "triangles", "quads", "surface",
                "spheres", "planes", "abclines",
                "clipplanes", "sprites")
    }
    keep <- types %in% type
    data.frame(id = as.numeric(ids[keep]), type = types[keep])
  }
  
  getmaterial <- function(id) {
    result <- scene$material
    this <- scene$objects[[as.character(id)]]$material
    result[names(this)] <- this
    result
  }
  
  getVertices <- function(id) {
    scale <- get.par3d("scale")
    scale <- scale/avgScale()
    vertices <- get.attrib(id, "vertices")
    vertices[,1:3] <- vertices[,1:3] %*% diag(scale)
    if (withColors) {
      colors <- get.attrib(id, "colors")
      if (nrow(colors) == 1)
        colors <- colors[rep(1, nrow(vertices)),,drop = FALSE]
    }
    if (withNormals) {
      normals <- get.attrib(id, "normals")
      if (!nrow(normals))
      	normals <- 0*vertices
    }
    cbind(vertices, 
          if (withColors) colors,
          if (withNormals) normals)
  }
  
  get.par3d <- function(attr = NULL) {
    par3d <- scene$rootSubscene$par3d
    if (!is.null(attr))
      par3d <- par3d[[attr]]
    par3d
  }
  rgba <- c("r", "g", "b", "a")
  lastCol <- c(0,0,0,1)  
  lastSize <- 0.5
  setPen <- function(col = lastCol, size = lastSize) {
    if (any(col[1:3] != lastCol[1:3])) {
      result <<- c(result, subst(
  	'currentpen = colorless(currentpen) + rgb(%r%, %g%, %b%);', 
  	r = col[1], g = col[2], b = col[3]))
      lastCol[1:3] <<- col[1:3]
    }
    if (col[4] != lastCol[4]) {
      result <<- c(result, subst(
    	  'currentpen += opacity(%a%);', a = col[4]))
      lastCol[4] <<- col[4]
    }
    if (size != lastSize) {
      result <<- c(result, subst(
    	'currentpen += linewidth(%size%);', size))
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
    dims <- get.attrib(id, "dim")
    nx <- dims[1]
    nz <- dims[2]
    for (i in seq_len(nz)[-nz]) 
      for (j in seq_len(nx)[-nx]) 
      	writePoly(vertices[c((i-1)*nx + j, i*nx + j, i*nx + j + 1, (i-1)*nx + j + 1),])
  }
  
  writeSpheres <- function(id) {
    vertices <- getVertices(id)
    n <- nrow(vertices)    
    radii <- get.attrib(id, "radii")
    radii <- rep(radii, length.out=n)
    for (i in seq_len(n)) {
      setPen(vertices[i, rgba])
      v <- vertices[i, 1:3]
      result <<- c(result, subst('draw(shift((%x%, %y%, %z%))*scale3(%r%)*unitsphere);',
      	x = v[1], y = v[2], z = v[3], r = radii[i]))  
    }
  }  
  
  avgScale <- function() {
    bbox <- get.par3d("bbox")
    ranges <- c(bbox[2]-bbox[1], bbox[4]-bbox[3], bbox[6]-bbox[5])
    if (prod(ranges) == 0) 1
    else exp(mean(log(ranges)))
  }  
   
  writePoints <- function(id) {
    setPen(size = getmaterial(id)$size*72/ppi)
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
    texts <- get.attrib(id, "texts")
    texts <- rep(texts, length.out = n)
    adj <- get.attrib(id, "adj")
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
    setPen(size = getmaterial(0, id)$lwd*72/ppi)
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
    setPen(size = getmaterial(0, id)$lwd*72/ppi)          
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
    col <- get.attrib(id, "colors")
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

  if (NROW(bbox <- get.ids("bboxdeco")) && (is.null(ids) || bbox$id %in% ids)) {
    ids <- setdiff(ids, bbox$id)
    save <- par3d(skipRedraw = TRUE)
    id <- bbox$id
    bbox <- convertBBox(verts = get.attrib(id, "vertices"),
                        text = get.attrib(id, "text"),
                        mat = getmaterial(id))
    on.exit({ rgl.pop(id=bbox); par3d(save) }, add=TRUE)
    dobbox <- TRUE
  } else dobbox <- FALSE 
  
  if (is.null(ids)) {
    ids <- get.ids(c("shapes", "background"))
    types <- as.character(ids$type)
    ids <- ids$id
  } else {
    if (dobbox) ids <- c(ids, bbox)
    allids <- get.ids()
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
