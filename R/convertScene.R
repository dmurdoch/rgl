
convertScene <- function(x = scene3d(minimal), width = NULL, height = NULL,
                         elementId = NULL,
                         minimal = TRUE, webgl = TRUE,
                         snapshot = FALSE,
                         oldConvertBBox = FALSE) {
  
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
    
    if (snapshot)
      result$snapshot <- getSnapshot()
  }
  
  flagnames <- c("is_lit", "is_smooth", "has_texture",
           "depth_sort", "fixed_quads", "is_transparent",
           "is_lines", "sprites_3d", 
           "is_subscene", "is_clipplanes",
           "fixed_size", "is_points", "is_twosided",
           "fat_lines", "is_brush", "has_fog")
  
  getFlags <- function(id) {
    
    obj <- getObj(id)
    if (is.null(obj)) {
      warning("object", id, " not found.")
      return(structure(rep(FALSE, length(flagnames)), names = flagnames))
    }
    type <- obj$type
    
    if (type == "subscene")
      return(getSubsceneFlags(id))
    
    result <- structure(rep(FALSE, length(flagnames)), names = flagnames)
    if (type == "clipplanes") {
      result["is_clipplanes"] <- TRUE
      return(result)
    }
    
    if (type == "light")
      return(result)
    
    result["is_transparent"] <- any(obj$colors[,"a"] < 1); # More later...
    
    mat <- getMaterial(id)
    result["is_lit"] <- mat$lit && type %in% c("triangles", "quads", "surface", "planes",
                 "spheres", "sprites", "bboxdeco")
    
    result["is_smooth"] <- mat$smooth && type %in% c("triangles", "quads", "surface", "planes",
                 "spheres")

    result["sprites_3d"] <- sprites_3d <- type == "sprites" && length(obj$ids)
    
    result["has_texture"] <- has_texture <- !is.null(mat$texture) &&
                                            (!is.null(obj$texcoords) 
                                             || (type == "sprites" && !sprites_3d))
    
    result["is_transparent"] <- is_transparent <- (has_texture && mat$isTransparent) || result["is_transparent"]
    
    result["depth_sort"] <- depth_sort <- is_transparent && type %in% c("triangles", "quads", "surface",
                        "spheres", "sprites", "text")
    
    result["fixed_quads"] <- type %in% c("text", "sprites") && !sprites_3d
    result["is_lines"]    <- type %in% c("lines", "linestrip", "abclines")
    result["is_points"]   <- type == "points" || "points" %in% c(mat$front, mat$back)
    result["is_twosided"] <- type %in% c("quads", "surface", "triangles", "spheres", "bboxdeco") && 
      length(unique(c(mat$front, mat$back))) > 1
    result["fixed_size"]  <- type == "text" || isTRUE(obj$fixedSize)
    result["fat_lines"]   <- mat$lwd != 1 && (result["is_lines"] || 
                  "lines" %in% unlist(mat[c("front", "back")]))
    result["is_brush"] <- !is.na(brushId) && id == brushId
    result["has_fog"] <- mat$fog
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
    bbox <- subscene$par3d$bbox
    repeat { # Need to make sure the ids here don't clash with those in the scene
      tempID <- points3d(bbox[1:2],
             bbox[3:4],
             bbox[5:6])
      if (tempID > lastID)
        break
      else
        delFromSubscene3d(tempID)
    }
    
    lastID <<- tempID
    
    intersect <- function(limits, points)
      which(limits[1] <= points & points <= limits[2])
    
    # plot the clipping planes as they affect the bounding box
    plotClipplanes(subscene)
    
    mat$front <- mat$back <- "fill"
    
    if (any(inds <- is.na(verts[,2]) & is.na(verts[,3])) && length(keep <- intersect(bbox[1:2], verts[inds, 1])))
      res <- c(res, do.call(axis3d, c(list(edge = "x", at = verts[inds, 1][keep], labels = text[inds][keep]), mat)))
    if (any(inds <- is.na(verts[,1]) & is.na(verts[,3])) && length(keep <- intersect(bbox[3:4], verts[inds, 2])))
      res <- c(res, do.call(axis3d, c(list(edge = "y", at = verts[inds, 2][keep], labels = text[inds][keep]), mat)))
    if (any(inds <- is.na(verts[,1]) & is.na(verts[,2])) && length(keep <- intersect(bbox[5:6], verts[inds, 3])))
      res <- c(res, do.call(axis3d, c(list(edge = "z", at = verts[inds, 3][keep], labels = text[inds][keep]), mat)))
    res <- c(res, do.call(box3d, mat))
    delFromSubscene3d(c(res, tempID))
    res
  }
  
  convertBBoxes <- function(id) {
    if (!oldConvertBBox)
      return(NULL)
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
  
  createBrush <- function() {
    repeat { # Need to make sure the id doesn't clash with those in the scene
      tempID <- lines3d(x = c(0, 1, 1, 0, 0),
      		        y = c(0, 0, 1, 1, 0), 
      		        z = rep(-.999, 5), 
      		        depth_test = "always",
      		        lit = FALSE,
      		        alpha = 0.5)
      if (tempID > lastID)
        break
      else
        delFromSubscene3d(tempID)
    } 
    lastID <<- tempID
  }
  
  getSnapshot <- function() 
    knitr::include_graphics(snapshot3d(scene = x, width = width, height = height))
  
  knowntypes <- c("points", "linestrip", "lines", "triangles", "quads",
      "surface", "text", "abclines", "planes", "spheres",
      "sprites", "clipplanes", "light", "background", "bboxdeco",
      "subscene")
  
  #  Execution starts here!

  # Do a few checks first

  if (!webgl)
    return(getSnapshot())
  
  if (is.null(elementId))
    elementId <- ""
  
  if (is.list(x$rootSubscene))
    rect <- x$rootSubscene$par3d$windowRect
  else
    rect <- x$objects[[x$rootSubscene]]$par3d$windowRect
  
  rwidth <- rect[3] - rect[1] + 1
  rheight <- rect[4] - rect[2] + 1
  if (!length(width)) {
    if (!length(height)) {
      wfactor <- hfactor <- 1  # width = wfactor*rwidth, height = hfactor*rheight
    } else
      wfactor <- hfactor <- height/rheight
  } else {
    if (!length(height)) {
      wfactor <- hfactor <- width/rwidth
    } else {
      wfactor <- width/rwidth
      hfactor <- height/rheight
    }
  }
  width <- wfactor*rwidth
  height <- hfactor*rheight
  
  shared <- x$crosstalk$id
  
  result <- NULL
  
  initResult()
  
  result$width <- width
  result$height <- height
  
  types <- vapply(result$objects, function(x) x$type, character(1))
  lastID <- max(vapply(result$objects, function(x) x$id, numeric(1)))
  
  if (any(types == "bboxdeco")) {
    saveNULL <- options(rgl.useNULL = TRUE)
    dev <- cur3d()
    open3d()
    ids <- convertBBoxes(result$rootSubscene)
    origIds <- attr(ids, "origIds")
    scene <- scene3d(minimal)
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
    close3d()
    if (dev)
      set3d(dev)
    options(saveNULL)
  }
  
  if (length(shared)) {
    saveNULL <- options(rgl.useNULL = TRUE)
    dev <- cur3d()
    open3d()
    result$brushId <- brushId <- createBrush()
    brush <- as.character(result$brushId)
    scene <- scene3d(minimal)
    result$objects[[brush]] <- scene$objects[[brush]]
    close3d()
    if (dev)
      set3d(dev)
    options(saveNULL)
  } else
    brushId <- NA
  
  ids <- vapply(result$objects, function(x) x$id, numeric(1))
  flags <- vapply(result$objects, function(obj) numericFlags(getFlags(obj$id)),
      numeric(1), USE.NAMES = FALSE)
  
  unknowntypes <- setdiff(types, knowntypes)
  if (length(unknowntypes))
    warning(gettextf("Object type(s) %s not handled",
         paste("'", unknowntypes, "'", sep="", collapse=", ")), domain = NA)
  
  keep <- types %in% setdiff(knowntypes, c("light"))
  ids <- ids[keep]
  cids <- as.character(ids)
  nflags <- flags[keep]
  types <- types[keep]
  flags <- expandFlags(nflags)
  rownames(flags) <- cids
  fullviewport <- getObj(result$rootSubscene)$par3d$viewport
  
  for (i in seq_along(ids)) {
    obj <- getObj(cids[i])
    obj$flags <- nflags[i]
    if (obj$type != "subscene") {
      texturefile <- ""
      if (!is.null(obj$material) && "texture" %in% names(obj$material))
        texture <- obj$material$texture
      else
        texture <- result$material$texture
      if (!is.null(texture) && nchar(texture)) {
        texturefile <- texture
        obj$material$uri <- image_uri(texturefile)
        obj$material$texture <- NULL
      }
      if (!is.null(obj$material)) # Never use material$color
        obj$material$color <- NULL
      
    } else if (obj$type == "subscene") {
      obj$par3d$viewport$x <- obj$par3d$viewport$x/fullviewport$width
      obj$par3d$viewport$width <- obj$par3d$viewport$width/fullviewport$width
      obj$par3d$viewport$y <- obj$par3d$viewport$y/fullviewport$height
      obj$par3d$viewport$height <- obj$par3d$viewport$height/fullviewport$height
    }
    if (obj$type == "planes" && nrow(obj$vertices) > 3) {
      obj$vertices <- obj$vertices[1:3,] # These will be redone
      # in Javascript
    } else if (obj$type == "spheres")
      obj$centers <- obj$vertices
    if (!is.null(obj$material$margin)) {
      margin <- parseMargin(obj$material$margin, obj$material$floating)
      obj$material$margin <- margin$coord - 1
      obj$material$floating <- margin$floating
      obj$material$edge <- margin$edge
    }
    setObj(cids[i], obj)
  }
  # Put the data into the buffer
  buffer <- Buffer$new()
  for (i in seq_along(ids)) {
    obj <- getObj(cids[i])
    for (n in c("vertices", "normals", "indices", 
                "texcoords", "colors", "centers")) {
      if (!is.null(obj[[n]]))
        obj[[n]] <- as.character(buffer$addAccessor(t(obj[[n]])))
    }
    setObj(cids[i], obj)
  }

  result$context <- list(shiny = inShiny(), rmarkdown = rmarkdownOutput())
  buffer$closeBuffers()
  buf <- buffer$as.list()

  buf$buffers[[1]]$bytes <- buffer$dataURI(0)
  result$buffer <- buf

  result
}
