writeASY <- function(scene = scene3d(),
                     title = "scene",
                     outtype = c("pdf", "eps", "asy", "latex", "pdflatex"),
                     prc = TRUE,
                     runAsy = "asy %filename%",
                     defaultFontsize = 12,
                     width = 7,
                     height = 7,
                     ppi = 100,
                     ids = NULL,
                     version = "2.65") {
  withColors <- TRUE
  withNormals <- FALSE

  outtype <- match.arg(outtype)
  version <- numeric_version(version)
  
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
import graph3;
currentprojection = %projection%(%x%, %y%, %z%, up = (%ux%, %uy%, %uz%));
defaultpen(fontsize(%defaultFontsize%));
ticklabel RGLstrings(real[] at, string[] label)
{
  return new string(real x) {
    int i = search(at, x);
    if (i < 0) return "";
    else return label[i];
  };
}

ticklabel RGLScale(real s)
{
  return new string(real x) {return format(s*x);};
}', 
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
  
  # simulate ids3d
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
  
  getScaling <- function() {
    scale <- get.par3d("scale")
    scale/avgScale()  
  }
  
  getCentre <- function() {
    bbox <- get.par3d("bbox")
    c(mean(bbox[1:2]), mean(bbox[3:4]), mean(bbox[5:6]))
  }
  
  getVertices <- function(id) {
    scale <- getScaling()
    vertices <- scale(get.attrib(id, "vertices"), center=FALSE, scale=1/scale)
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
    result <<- c(result, '--cycle), light=currentlight);')
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
    radii <- get.attrib(id, "radii")/4
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
    setPen(size = getmaterial(id)$size)
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
    setPen(size = getmaterial(id)$lwd)
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
    setPen(size = getmaterial(id)$lwd)          
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
  
  writeBBox <- function(id) {
    setPen(size = getmaterial(id)$lwd)
    bbox <- get.par3d("bbox")
    scale <- getScaling()
    vertices <- getVertices(id)
    ticks <- vertices[,1]
    ticks <- ticks[!is.na(ticks)]
    if (length(ticks))
    	xticks <- subst('Ticks3(1, Ticks = new real[] {%ticks%},
    			          ticklabel = RGLScale(%scale%))',
    			scale = 1/scale[1], ticks = paste(ticks, collapse=","))
    else
    	xticks <- subst('Ticks3(1, ticklabel = RGLScale(%scale%))',
    			scale = 1/scale[1])
    ticks <- vertices[,2]
    ticks <- ticks[!is.na(ticks)]
    if (length(ticks))
    	yticks <- subst('Ticks3(1, Ticks = new real[] {%ticks%},
    			ticklabel = RGLScale(%scale%))',
    			scale = 1/scale[2], ticks = paste(ticks, collapse=","))
    else
    	yticks <- subst('Ticks3(1, ticklabel = RGLScale(%scale%))',
    			scale = 1/scale[2])
    ticks <- vertices[,3]
    ticks <- ticks[!is.na(ticks)]
    if (length(ticks))
    	zticks <- subst('Ticks3(1, Ticks = new real[] {%ticks%},
    			ticklabel = RGLScale(%scale%))',
    			scale = 1/scale[3], ticks = paste(ticks, collapse=","))
    else
    	xticks <- subst('Ticks3(1, ticklabel = RGLScale(%scale%))',
    			scale = 1/scale[3])
    bbox <- bbox * rep(scale, each = 2)
    result <<- c(result, subst(
      'xaxis3(axis=YZEquals(y=%ymin%, z=%zmin%),
              xmin=%xmin%, xmax=%xmax%,
              ticks = %xticks%);
       xaxis3(axis=YZEquals(y=%ymin%, z=%zmax%),
              xmin=%xmin%, xmax=%xmax%);
       xaxis3(axis=YZEquals(y=%ymax%, z=%zmin%),
              xmin=%xmin%, xmax=%xmax%);
       xaxis3(axis=YZEquals(y=%ymax%, z=%zmax%),
              xmin=%xmin%, xmax=%xmax%);
       yaxis3(axis=XZEquals(x=%xmin%, z=%zmin%),
              ymin=%ymin%, ymax=%ymax%,
              ticks = %yticks%);
       yaxis3(axis=XZEquals(x=%xmin%, z=%zmax%),
              ymin=%ymin%, ymax=%ymax%);
       yaxis3(axis=XZEquals(x=%xmax%, z=%zmin%),
              ymin=%ymin%, ymax=%ymax%);
       yaxis3(axis=XZEquals(x=%xmax%, z=%zmax%),
              ymin=%ymin%, ymax=%ymax%);
       zaxis3(axis=XYEquals(x=%xmin%, y=%ymin%),
              zmin=%zmin%, zmax=%zmax%,
              ticks = %zticks%);
       zaxis3(axis=XYEquals(x=%xmin%, y=%ymax%),
              zmin=%zmin%, zmax=%zmax%);
       zaxis3(axis=XYEquals(x=%xmax%, y=%ymin%),
              zmin=%zmin%, zmax=%zmax%);
       zaxis3(axis=XYEquals(x=%xmax%, y=%ymax%),
              zmin=%zmin%, zmax=%zmax%);',
              xmin = bbox[1], xmax = bbox[2], ymin=bbox[3], ymax=bbox[4],
              zmin=bbox[5], zmax=bbox[6], 
              xticks, yticks, zticks))
  }
  
  writeLights <- function(ids) {
    if (!length(ids))
      result <<- c(result, 'currentlight = nolight;')
    else {
      col <- array(NA, c(length(ids), 3, 3))
      pos <- matrix(NA, nrow=length(ids), ncol=3)
      for (i in seq_along(ids)) {
      	col[i,,] <- get.attrib(ids[i], "colors")[1:3, 1:3]
      	pos[i,] <- get.attrib(ids[i], "vertices")[1,]
      }
      result <<- c(result, 'currentlight = light(')
      if (version < "2.50") {
        cols <-
          paste(paste0("rgb(", col[, 1, 1], ",", col[, 1, 2], ",", col[, 1, 3], ")"),
                collapse = ",")
        result <<-
          c(result,
            subst(
              'ambient=new pen[] {%cols%},',
              cols
            ))
      }
      cols <-
        paste(paste0("rgb(", col[, 2, 1], ",", col[, 2, 2], ",", col[, 2, 3], ")"),
              collapse = ",")
      result <<-
        c(result, subst('diffuse = new pen[] {%cols%},', cols))
      cols <-
        paste(paste0("rgb(", col[, 3, 1], ",", col[, 3, 2], ",", col[, 3, 3], ")"),
              collapse = ",")
      result <<-
        c(result, subst('specular = new pen[] {%cols%},', cols))
      pos <-
        paste(paste0("(", pos[, 1], ",", pos[, 2], ",", pos[, 3], ")"), collapse = ",")
      result <<-
        c(result, subst('position = new triple[] {%pos%}', pos))
      if (version < "2.47")
        result <<-
        c(
          result,
          subst(
            ', viewport = %viewpoint%',
            pos,
            viewpoint = if (get.attrib(ids[1], "viewpoint"))
              "true"
            else
              "false"
          )
        )
      result <<- c(result, ');')
    }
  }    
  knowntypes <- c("points", "linestrip", "lines",
  		  "text", "triangles", "quads", "surface",
  		  "spheres", "planes", "abclines",
  		  "background", "bboxdeco", "light")
  
  #  Execution starts here!
  
  allids <- get.ids(c("shapes", "background", "bboxdeco", "light"))
  if (is.null(ids)) {
    ids <- allids
    types <- as.character(ids$type)
    ids <- ids$id
  } else {
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
  
  # Lights are done first.
  writeLights(ids[types == "light"])

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
      background = writeBackground(ids[i]),
      bboxdeco = writeBBox(ids[i]),
      light = {}
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
    filename <- paste0(title, ".", outtype)
  }
  invisible(filename)
}
