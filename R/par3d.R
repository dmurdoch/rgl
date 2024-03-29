rgl.par3d.names <- c("antialias", "FOV", "ignoreExtent", "listeners",
            "mouseMode", "observer", 
            "modelMatrix", "projMatrix", "skipRedraw", "userMatrix",
            "userProjection",
            "scale", "viewport", "zoom", "bbox", "windowRect",
            "family", "font", "cex", "useFreeType", "fontname",
            "maxClipPlanes", "glVersion", "activeSubscene"
)

rgl.par3d.readonly <- c( 
  "antialias", "observer",
  "modelMatrix", "projMatrix",
  "bbox", "fontname",
  "maxClipPlanes", "glVersion",
  "activeSubscene"
)

par3d <- function(..., no.readonly = FALSE, dev = cur3d(), subscene = currentSubscene3d(dev)) {
  single <- FALSE
  args <- list(...)
  if (!length(args))
    args <- as.list(if (no.readonly)
      rgl.par3d.names[-match(rgl.par3d.readonly, rgl.par3d.names)]
      else rgl.par3d.names)
  else {
    if (is.null(names(args)) && all(unlist(lapply(args, is.character))))
      args <- as.list(unlist(args))
    if (length(args) == 1) {
      if (is.list(args[[1]]) || is.null(args[[1]]))
        args <- args[[1]]
      else
        if(is.null(names(args)))
          single <- TRUE
    }
  }
  if ("dev" %in% names(args)) {
    if (!missing(dev) && dev != args[["dev"]]) stop("'dev' specified inconsistently")
    dev <- args[["dev"]]
    args[["dev"]] <- NULL
  }
  if (specifiedSubscene <- ("subscene" %in% names(args))) {
    if (!missing(subscene) && subscene != args[["subscene"]]) stop("'subscene' specified inconsistently")
    subscene <- args[["subscene"]]
    args[["subscene"]] <- NULL
  }
  dev <- as.integer(dev)
  if (!dev) dev <- open3d()
  subscene <- as.integer(subscene)
  
  if ("userMatrix" %in% names(args)) {
    m <- args$userMatrix
    svd <- svd(m[1:3, 1:3])
    m[1:3, 1:3] <- svd$u %*% t(svd$v)
    theta <- atan2(-m[1,3], m[1,1])
    m <-  m %*% rotationMatrix(theta, 0,1,0)
    svd <- svd(m[1:3, 1:3])
    m[1:3,1:3] <- svd$u %*% t(svd$v)	
    phi <- atan2(-m[2,3], m[3,3])
    args$.position <- c(theta, phi)*180/pi
  }
  if ("mouseMode" %in% names(args)) {
    m <- args$mouseMode
    if (is.null(names(m))) {
      if (length(m) < 5) 
        args$mouseMode <- c("none", m)
    } else {
      m0 <- par3d("mouseMode")
      m0[names(m)] <- m
      args$mouseMode <- m0
    }
  }
  if (forceViewport <- ("windowRect" %in% names(args) &&
      !("viewport" %in% names(args)))) {
    if (specifiedSubscene)
      warning("Viewport for subscene ", subscene,
              " will be adjusted; other viewports will not be.")
    oldviewport <- .Call(rgl_par3d, dev, subscene, list("viewport","windowRect"))
  }
  value <-
    if (single) .Call(rgl_par3d, dev, subscene, args)[[1]] 
  else .Call(rgl_par3d, dev, subscene, args)
  
  # The windowRect might be modified by the window manager (if
  # too large, for example), so we need to read it after the
  # change
  if (forceViewport) {
    oldsize <- oldviewport$windowRect[3:4] - oldviewport$windowRect[1:2]
    Sys.sleep(0.1)
    windowRect <- .Call(rgl_par3d, dev, subscene, list("windowRect"))$windowRect
    newsize <- windowRect[3:4] - windowRect[1:2]
    .Call(rgl_par3d, dev, subscene, 
          list(viewport = round(oldviewport$viewport*newsize/oldsize)))
  }
  
  if(!is.null(names(args))) invisible(value) else value
}
