
convertScene <- function(x = scene3d(), width = NULL, height = NULL, reuse = NULL,
                         snapshot = FALSE, elementId = NULL) {

	# Lots of utility functions and constants defined first; execution starts way down there...

	getObj <- function(id) {
	  result$objects[[as.character(id)]]
	}

	setObj <- function(id, newval) {
	  result$objects[[as.character(id)]] <<- newval
	}

	getIdsByType <- function(type, subscene = NULL) {
	  if (is.null(subscene))
	    ids <- vapply(result$objects, function(x)
	                    if (x$type == type) x$id else NA, numeric(1))
	  else {
	    ids <- vapply(getObj(subscene)$objects, function(x) {
	                    obj <- getObj(x)
	                    if (obj$type == type) obj$id
	                    else NA
	                  }, numeric(1))
	  }
	  ids[!is.na(ids)]
	}

	getMaterial <- function(id) {
	  default <- result$material
	  obj <- getObj(id)
	  mat <- obj$material
	  missing <- setdiff(names(default), names(mat))
	  mat[missing] <- default[missing]
	  mat
	}

	# This counts how many clipping planes might affect a particular object
	countClipplanes <- function(id, minValue = getOption("rgl.minClipplanes", 0)) {
	  recurse <- function(subscene) {
	    count <- 0
	    ids <- getIdsByType("clipplanes", subscene)
	    for (clipid in ids)
	      count <- count + nrow(getObj(clipid)$normals)

	    subscenes <- getIdsByType("subscene", subscene)
	    for (sub in subscenes) {
	      if (count >= bound)
	        break
	      count <- max(count, recurse(sub))
	    }
	    count
	  }
	  ids <- getIdsByType("clipplanes")
	  bound <- 0
	  for (i in seq_along(ids))
	    bound <- bound + nrow(getObj(ids[i])$normals)
	  if (bound < minValue) return(minValue)
	  max(minValue, recurse(result$rootSubscene))
	}

	makeList <- function(x) {
	  if (is.list(x)) x <- lapply(x, makeList)
	  if (length(names(x))) x <- as.list(x)
	  x
	}

	initResult <- function() {
    result <<- makeList(x)

    recurse <- function(subscene) {
      subscenes <- subscene$subscenes
      for (i in seq_along(subscenes)) {
        subscenes[[i]]$parent <- subscene$id
        subscenes[[i]] <- recurse(subscenes[[i]])
      }
      if (length(subscenes)) {
        subscene$subscenes <- unlist(subscenes)
        subscene$objects <- c(subscene$objects, subscene$subscenes)
      } else
        subscene$subscenes <- numeric(0)
      setObj(subscene$id, subscene)
      subscene$id
    }
    result$rootSubscene <<- recurse(result$rootSubscene)

    snapshotimg <- NULL
    snapshotfile <- NULL
    if (is.logical(snapshot) && snapshot) {
      snapshotfile <- tempfile(fileext = ".png")
      on.exit(unlink(snapshotfile))
      snapshot3d(snapshotfile)
    } else if (is.character(snapshot) && substr(snapshot, 1, 5) != "data:") {
      snapshotfile <- snapshot
    } else if (is.character(snapshot))
      snapshotimg <- snapshot
    if (!is.null(snapshotfile))
      snapshotimg <- image_uri(snapshotfile)
    if (!is.null(snapshotimg))
      result$snapshot <<- snapshotimg
	}

	flagnames <- c("is_lit", "is_smooth", "has_texture", "is_indexed",
		       "depth_sort", "fixed_quads", "is_transparent",
		       "is_lines", "sprites_3d", "sprite_3d",
		       "is_subscene", "is_clipplanes",
		       "fixed_size", "is_points", "is_twosided",
		       "fat_lines")

	getFlags <- function(id) {

	  obj <- getObj(id)
	  type <- obj$type

	  if (type == "subscene")
	    return(getSubsceneFlags(id))

	  result <- structure(rep(FALSE, length(flagnames)), names = flagnames)
	  if (type == "clipplanes") {
	    result["is_clipplanes"] <- TRUE
	    return(result)
	  }

	  if (type %in% c("light", "bboxdeco"))
	    return(result)

          mat <- getMaterial(id)
	  result["is_lit"] <- mat$lit && type %in% c("triangles", "quads", "surface", "planes",
						     "spheres", "sprites")

	  result["is_smooth"] <- mat$smooth && type %in% c("triangles", "quads", "surface", "planes",
							   "spheres")

	  result["has_texture"] <- has_texture <- !is.null(mat$texture)

	  result["is_transparent"] <- is_transparent <- (has_texture && mat$isTransparent) || any(obj$colors[,"a"] < 1)

	  result["depth_sort"] <- depth_sort <- is_transparent && type %in% c("triangles", "quads", "surface",
										    "spheres", "sprites", "text")
	  result["sprites_3d"] <- sprites_3d <- type == "sprites" && length(obj$ids)

	  result["is_indexed"] <- (depth_sort ||
				   type %in% c("quads", "surface", "text", "sprites") ||
				   type %in% c("triangles") && length(intersect(c("points", "lines"), c(mat$front, mat$back)))) && 
			          !sprites_3d

	  result["fixed_quads"] <- type %in% c("text", "sprites") && !sprites_3d
	  result["is_lines"]    <- type %in% c("lines", "linestrip", "abclines")
	  result["is_points"]   <- type == "points" || "points" %in% c(mat$front, mat$back)
	  result["is_twosided"] <- type %in% c("quads", "surface", "triangles") && 
			           length(unique(c(mat$front, mat$back))) > 1
	  result["fixed_size"]  <- type == "text" || isTRUE(obj$fixedSize)
	  result["fat_lines"]   <- mat$lwd != 1 && (result["is_lines"] || 
	  					    "lines" %in% unlist(mat[c("front", "back")]))
	  result
	}

	getSubsceneFlags <- function(id) {
		result <- structure(rep(FALSE, length(flagnames)), names = flagnames)
		result["is_subscene"] <- TRUE
		objs <- getObj(id)$objects
		for (i in seq_along(objs))
			result <- result | getFlags(objs[i])
		return(result)
	}

	numericFlags <- function(flags) {
		if (is.matrix(flags))
			n <- ncol(flags)
		else
			n <- length(flags)
		unname(flags %*% 2^(seq_len(n)-1))
	}

	expandFlags <- function(numericflags) {
	  result <- matrix(FALSE, nrow = length(numericflags),
	                          ncol = length(flagnames),
	                   dimnames = list(names(numericflags), flagnames))
    for (i in seq_along(flagnames)) {
      result[,i] <- numericflags %% 2 == 1
      numericflags <- numericflags %/% 2
    }
	  result
	}

	plotClipplanes <- function(subscene) {
	  for (id in subscene$objects) {
	    obj <- getObj(id)
	    if (obj$type == "clipplanes") {
	      class(obj) <- "rglobject"
	      plot3d(obj)
	    } else if (obj$type == "subscene")
	      plotClipplanes(getObj(id))
	  }
	}

	convertBBox <- function(id, subscene) {
	  obj <- getObj(id)
	  verts <- obj$vertices
	  text <- obj$texts
	  if (!length(text))
	    text <- rep("", NROW(verts))
	  else
	    text <- text[,"text"]
	  mat <- getMaterial(id)
	  if (length(mat$color) > 1)
	    mat$color <- mat$color[2] # We ignore the "box" colour

	  if(any(missing <- text == ""))
	    text[missing] <- apply(verts[missing,], 1, function(row) format(row[!is.na(row)]))

	  res <- numeric(0)
	  repeat { # Need to make sure the ids here don't clash with those in the scene
	    tempID <- points3d(subscene$par3d$bbox[1:2],
	                       subscene$par3d$bbox[3:4],
	                       subscene$par3d$bbox[5:6])
	    if (tempID > lastID)
	      break
	    else
	      delFromSubscene3d(tempID)
	  }

	  # plot the clipping planes as they affect the bounding box
	  plotClipplanes(subscene)

	  if (any(inds <- is.na(verts[,2]) & is.na(verts[,3])))
	    res <- c(res, do.call(axis3d, c(list(edge = "x", at = verts[inds, 1], labels = text[inds]), mat)))
	  if (any(inds <- is.na(verts[,1]) & is.na(verts[,3])))
	    res <- c(res, do.call(axis3d, c(list(edge = "y", at = verts[inds, 2], labels = text[inds]), mat)))
	  if (any(inds <- is.na(verts[,1]) & is.na(verts[,2])))
	    res <- c(res, do.call(axis3d, c(list(edge = "z", at = verts[inds, 3], labels = text[inds]), mat)))
	  res <- c(res, do.call(box3d, mat))
	  delFromSubscene3d(c(res, tempID))
	  res
	}

	convertBBoxes <- function (id) {
	  ids <- origIds <- NULL
	  id <- as.character(id)
	  sub <- getObj(id)
	  types <- vapply(sub$objects,
	                  function(x) getObj(x)$type,
	                  character(1))
	  names(types) <- as.character(sub$objects)
	  if (length(bboxes <- names(types)[types == "bboxdeco"])) {
	    for (i in bboxes) {
	      newids <- convertBBox(i, sub)
	      sub$objects <- c(sub$objects, as.numeric(newids))
	      setObj(id, sub)
	      ids <- c(ids, newids)
	      origIds <- c(origIds, rep(i, length(newids)))
	    }
	  }
	  children <- sub$subscenes
	  for (i in children) {
	    childids <- convertBBoxes(i)
	    ids <- c(ids, childids)
	    origIds <- c(origIds, attr(childids, "origIds"))
	  }
	  if (length(origIds))
	    names(origIds) <- as.character(ids)
	  if (is.null(ids)) ids
	  else structure(ids, origIds = origIds)
	}

		knowntypes <- c("points", "linestrip", "lines", "triangles", "quads",
				"surface", "text", "abclines", "planes", "spheres",
				"sprites", "clipplanes", "light", "background", "bboxdeco",
				"subscene")

	#  Execution starts here!

	# Do a few checks first

	if (is.null(elementId))
	  elementId <- ""

	if (is.null(reuse) || isTRUE(reuse))
		reuseDF <- data.frame(id = numeric(), elementId = character(), texture = character(),
				       stringsAsFactors = FALSE)
	else {
		if (!is.data.frame(reuse) || !all(c("id", "elementId", "texture") %in% names(reuse)))
			stop("'reuse' should be a dataframe with columns 'id', 'elementId', 'texture'")
		reuseDF <- reuse[reuse$elementId != elementId,
		                 c("id", "elementId", "texture")]
		reuseDF$id         <- as.numeric(reuseDF$id)
		reuseDF$elementId  <- as.character(reuseDF$elementId)
		reuseDF$texture    <- as.character(reuseDF$texture)
	}

	if (is.logical(snapshot) && snapshot) {
		if (rgl.useNULL()) {
	    warning("Can't take snapshot with NULL rgl device")
	    snapshot <- FALSE
	  } else if (!missing(x))
		  warning("Will take snapshot of current scene which may differ from x.")
  }
	if (is.list(x$rootSubscene))
	  rect <- x$rootSubscene$par3d$windowRect
	else
	  rect <- x$objects[[x$rootSubscene]]$par3d$windowRect

	rwidth <- rect[3] - rect[1] + 1
	rheight <- rect[4] - rect[2] + 1
	if (is.null(width)) {
	  if (is.null(height)) {
	    wfactor <- hfactor <- 1  # width = wfactor*rwidth, height = hfactor*rheight
	  } else
	    wfactor <- hfactor <- height/rheight
	} else {
	  if (is.null(height)) {
	    wfactor <- hfactor <- width/rwidth
	  } else {
	    wfactor <- width/rwidth;
	    hfactor <- height/rheight;
	  }
	}
	width <- wfactor*rwidth;
	height <- hfactor*rheight;

  result <- NULL

	initResult()

	result$width <- width
	result$height <- height

	types <- vapply(result$objects, function(x) x$type, character(1))
	if (any(types == "bboxdeco")) {
	  lastID <- max(vapply(result$objects, function(x) x$id, numeric(1)))
	  saveNULL <- options(rgl.useNULL = TRUE)
	  dev <- rgl.cur()
	  open3d()
	  ids <- convertBBoxes(result$rootSubscene)
	  origIds <- attr(ids, "origIds")
	  scene <- scene3d()
	  temp <- lapply(as.character(ids),
	                 function(id) {
	                   x <- scene$objects[[id]]
	                   x$origId <- as.numeric(origIds[id])
	                   x
	                 })
	  result$objects[as.character(ids)] <- temp
	  for (id in unique(origIds))
	    result$objects[[as.character(id)]]$newIds <- as.numeric(ids[origIds == id])
	  types <- vapply(result$objects, function(x) x$type, character(1))
	  rgl.close()
	  if (dev)
	    rgl.set(dev)
	  options(saveNULL)
	}

	ids <- vapply(result$objects, function(x) x$id, numeric(1))
  flags <- vapply(result$objects, function(obj) numericFlags(getFlags(obj$id)),
                                 numeric(1), USE.NAMES = FALSE)

	unknowntypes <- setdiff(types, knowntypes)
	if (length(unknowntypes))
		warning(gettextf("Object type(s) %s not handled",
				 paste("'", unknowntypes, "'", sep="", collapse=", ")), domain = NA)

	for (i in seq_along(ids)) {
	  if (length(preventry <- which(reuseDF$id == ids[i]) ) ) {
	    obj <- list(id = as.numeric(ids[i]), reuse = reuseDF$elementId[preventry[1]])
	    setObj(as.character(ids[i]), obj)
	    types[i] <- "reused"
	  }
	}
	simple <- types %in% c("light")
	if (any(simple))
	  reuseDF <- rbind(reuseDF, data.frame(id = ids[simple],
	                                     elementId = elementId,
	                                     texture = "", stringsAsFactors = FALSE))
	keep <- types %in% setdiff(knowntypes, c("light", "bboxdeco"))
	ids <- ids[keep]
	cids <- as.character(ids)
	nflags <- flags[keep]
	types <- types[keep]
	flags <- expandFlags(nflags)
	rownames(flags) <- cids
	fullviewport <- getObj(result$rootSubscene)$par3d$viewport

	for (i in seq_along(ids)) {
	  obj <- getObj(cids[i])
	  if (obj$type == "sprites" && flags[i, "sprites_3d"]) {
	    obj$objects <- NULL
	    for (j in seq_along(obj$ids)) {
	      objid <- as.character(obj$ids[j])
	      k <- which(objid == cids)
	      flags[k, "sprite_3d"] <- TRUE
	      nflags[k] <- numericFlags(flags[k,])
	    }
	  }
	}
	for (i in seq_along(ids)) {
	  obj <- getObj(cids[i])
	  obj$flags <- nflags[i]
	  if (obj$type != "subscene") {
	    texturefile <- ""
	    if (!is.null(obj$material) && !is.null(texture <- obj$material$texture)) {
	      if (length(prev <- which(texture == reuseDF$texture))) {
	        prev <- prev[1]
	        if (reuseDF$elementId[prev] != elementId)
	          obj$material$uriElementId <- reuseDF$elementId[prev]
	        obj$material$uriId <- reuseDF$id[prev]
	      } else {
	        texturefile <- obj$material$texture
	        obj$material$uri <- image_uri(texturefile)
	      }
	      obj$material$texture <- NULL
	    }
	    if (!is.null(obj$material)) # Never use material$color
	      obj$material$color <- NULL
	    reuseDF <- rbind(reuseDF, data.frame(id = ids[i], elementId = elementId,
	                                         texture = texturefile, stringsAsFactors = FALSE))
	  } else if (obj$type == "subscene") {
	    obj$par3d$viewport$x <- obj$par3d$viewport$x/fullviewport$width
	    obj$par3d$viewport$width <- obj$par3d$viewport$width/fullviewport$width
	    obj$par3d$viewport$y <- obj$par3d$viewport$y/fullviewport$height
	    obj$par3d$viewport$height <- obj$par3d$viewport$height/fullviewport$height
	  }
	  if (obj$type == "planes" && nrow(obj$vertices) > 3) {
	    obj$vertices = obj$vertices[1:3,] # These will be redone
	                                      # in Javascript
	  } else if (obj$type == "spheres")
	    obj$centers <- obj$vertices
	  setObj(cids[i], obj)
	}

	sphereId <- reuseDF$elementId[reuseDF$id == -1]
	if (length(sphereId)) {
	  result$sphereVerts <- list(reuse = sphereId[1])
	} else {
	  # Make model sphere
	  segments <- 16
	  sections <- 16
	  iy <- 0:sections
	  fy <- iy/sections
	  phi <- fy - 0.5
	  ix <- 0:segments
	  fx <- ix/segments
	  theta <- 2*fx
	  qx <- as.numeric(outer(phi, theta, function(phi, theta) sinpi(theta)*cospi(phi)))
	  qy <- as.numeric(outer(phi, theta, function(phi, theta) sinpi(phi)))
	  qz <- as.numeric(outer(phi, theta, function(phi, theta) cospi(theta)*cospi(phi)))
	  inds <- rep(seq_len(sections), segments) + (sections + 1)*rep(seq_len(segments)-1, each = sections)
	  x <- tmesh3d(vertices = rbind(qx, qy, qz, 1), 
	  	       texcoords = cbind(rep(fx, each = sections+1),
	  	       		         rep(fy, segments+1)),
	  	       indices = cbind(rbind(inds, inds + sections + 1, 
	  	       		             inds + sections + 2),
	  	       		       rbind(inds, inds + sections + 2, 
	  	       		             inds + 1)))
	  x$it <- x$it - 1
	  x$vb <- x$vb[1:3,]
          result$sphereVerts <- x
          reuseDF <- rbind(reuseDF,
                     data.frame(id = -1, elementId = elementId,
                                texture = "", stringsAsFactors = FALSE))
	}
	structure(result, reuse = reuseDF)
}

