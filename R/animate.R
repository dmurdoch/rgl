# These quaternion functions are adapted from the orientlib package

# Convert an array of rotation matrices to a matrix of unit quaternions
toQuaternions <- function(x) {
  nicesqrt <- function(x) sqrt(pmax(x,0))
  q4 <- nicesqrt((1 + x[1,1,] + x[2,2,] + x[3,3,])/4)  # may go negative by rounding
  zeros <- zapsmall(q4) == 0 
  q1 <- ifelse(!zeros, (x[2,3,] - x[3,2,])/4/q4, nicesqrt(-(x[2,2,]+x[3,3,])/2))
  q2 <- ifelse(!zeros, (x[3,1,] - x[1,3,])/4/q4, 
               ifelse(zapsmall(q1) != 0, x[1,2,]/2/q1, nicesqrt((1-x[3,3,])/2)))
  q3 <- ifelse(!zeros, (x[1,2,] - x[2,1,])/4/q4, 
               ifelse(zapsmall(q1) != 0, x[1,3,]/2/q1, 
                      ifelse(zapsmall(q2) != 0, x[2,3,]/2/q2, 1)))
  cbind(q1, q2, q3, q4)
}

# Convert a single quaternion to a rotation matrix

toRotmatrix <- function(x) {
  x <- x/sqrt(sum(x^2))
  matrix(c(1-2*x[2]^2-2*x[3]^2, 
           2*x[1]*x[2]-2*x[3]*x[4],
           2*x[1]*x[3]+2*x[2]*x[4],
           2*x[1]*x[2]+2*x[3]*x[4],
           1-2*x[1]^2-2*x[3]^2,
           2*x[2]*x[3] - 2*x[4]*x[1],
           2*x[1]*x[3] - 2*x[2]*x[4],
           2*x[2]*x[3] + 2*x[1]*x[4],
           1 - 2*x[1]^2 - 2*x[2]^2), 3,3)
}

par3dinterp <- function(times=NULL, userMatrix, scale, zoom, FOV, method=c("spline", "linear"), 
                        extrapolate = c("oscillate","cycle","constant", "natural"),
                        dev = cur3d(), subscene = par3d("listeners", dev = dev)) {
  force(dev)
  force(subscene)
  
  if (is.list(times)) {
    for (n in setdiff(names(times), "times")) assign(n, times[[n]])
    if ("times" %in% names(times)) times <- times[["times"]]
    else times <- NULL
  }
  
  if (!missing(userMatrix) && is.list(userMatrix)) userMatrix <- do.call(cbind, userMatrix)
  if (!missing(scale) && is.list(scale)) scale <- do.call(rbind, scale)
  if (!missing(zoom) && is.list(zoom)) zoom <- unlist(zoom)
  if (!missing(FOV) && is.list(FOV)) FOV <- unlist(FOV)
  
  if (is.null(times)) {
    times <- if (!missing(userMatrix)) 0:(length(userMatrix)/16 - 1)
    else if (!missing(scale)) 0:(dim(scale)[1] - 1)
    else if (!missing(zoom)) 0:(length(zoom) - 1)
    else if (!missing(FOV)) 0:(length(FOV) - 1)
  }
  data <- matrix(0, length(times), 0)
  if (!missing(userMatrix)) {
    stopifnot( length(userMatrix) == 16*length(times) )
    userMatrix <- array(userMatrix, c(4,4,length(times)))
    xlat <- ncol(data) + 1:4
    data <- cbind(data, t(userMatrix[,4,, drop = TRUE]))
    persp <- ncol(data) + 1:3
    data <- cbind(data, t(userMatrix[4,1:3,, drop = TRUE]))
    rot <- ncol(data) + 1:4
    quat <- toQuaternions(userMatrix[1:3, 1:3, , drop = FALSE])
    # Since q and -q are the same rotation, we want to interpolate
    # to the nearer one.
    for (i in seq_len(nrow(quat))[-1]) {
      if (sum((quat[i - 1, ] - quat[i, ])^2) > sum((quat[i - 1, ] + quat[i, ])^2)) 
        quat[i, ] <- -quat[i, ]
    }
    data <- cbind(data, quat)	
  } else {
    xlat <- NULL
  }
  if (!missing(scale)) {
    stopifnot( dim(scale)[1] == length(times) )
    sc <- ncol(data) + 1:3
    data <- cbind(data, log(scale))
  } else sc <- NULL
  if (!missing(zoom)) {
    stopifnot( length(zoom) == length(times) )
    zm <- ncol(data) + 1
    data <- cbind(data, log(zoom))
  } else zm <- NULL
  if (!missing(FOV)) {
    stopifnot( length(FOV) == length(times) )
    fov <- ncol(data) + 1
    data <- cbind(data, FOV)
  } else fov <- NULL
  
  method <- match.arg(method)
  extrapolate <- match.arg(extrapolate)
  if (extrapolate == "oscillate") {
    n <- length(times)
    times <- c(times[-n], -rev(times) + 2*times[length(times)])
    data <- rbind(data[-n,,drop=FALSE], data[n:1,,drop=FALSE])
    n <- 2*n - 1
    extrapolate <- "cycle"
  } else if (extrapolate == "natural" && method != "spline")
    stop("'natural' extrapolation only supported for spline method")
  
  if (method == "spline") {
    fns <- apply(data, 2, function(col) splinefun(times, col, 
                                                  method = ifelse(extrapolate == "cycle", "periodic", "natural")))
  } else {
    fns <- apply(data, 2, function(col) approxfun(times, col, rule=2))
  }
  
  mintime <- min(times)
  maxtime <- max(times)
  
  function(time) {
    if (time < mintime || time > maxtime) {
      if (extrapolate == "constant" || mintime == maxtime)
        time <- ifelse(time < mintime, mintime, maxtime)
      else if (extrapolate == "cycle")
        time <- (time - mintime) %% (maxtime - mintime) + mintime
    }
    data <- sapply(fns, function(f) f(time))
    result <- list(dev = dev, subscene = subscene)
    if (!is.null(xlat)) {
      userMatrix <- matrix(0, 4,4)
      userMatrix[,4] <- data[xlat]
      userMatrix[4,1:3] <- data[persp]
      userMatrix[1:3,1:3] <- toRotmatrix(data[rot])
      result$userMatrix <- userMatrix
    }
    if (!is.null(sc)) 
      result$scale <- exp(data[sc])
    if (!is.null(zm))
      result$zoom <- exp(data[zm])
    if (!is.null(fov))
      result$FOV <- data[fov]
    result
  }
}

spin3d <- function(axis = c(0, 0, 1), rpm = 5, dev = cur3d(), subscene = par3d("listeners", dev = dev)) {
  force(axis)
  force(rpm)    
  force(dev)
  force(subscene)
  M <- par3d("userMatrix", dev = dev, subscene = subscene)
  function(time, base = M) 
    list(userMatrix = rotate3d(base, time*rpm*pi/30, axis[1], axis[2], axis[3]), dev = dev, subscene = subscene)
}

play3d <- function(f, duration = Inf, dev = cur3d(), ..., startTime = 0) {
  # Don't want to start timing until args are known: they may be obtained
  # interactively
  force(f)  
  force(duration)
  force(dev)
  start <- proc.time()[3] - startTime
  rgl.setselectstate("none")
  repeat {
    if(!missing(dev) && cur3d() != dev) set3d(dev)
    time <- proc.time()[3] - start
    if (time > duration || rgl.selectstate()$state == msABORT) return(invisible(NULL))
    stopifnot(cur3d() != 0)
    args <- f(time, ...)
    subs <- args$subscene
    if (is.null(subs))
      subs <- currentSubscene3d(dev)
    else
      args$subscene <- NULL
    for (s in subs)
      par3d(args, subscene = s)
  }
}

movie3d <- function(f, duration, dev = cur3d(), ..., fps=10, 
                    movie = "movie", frames = movie, dir = tempdir(), 
                    convert = NULL, clean = TRUE, verbose=TRUE,
                    top = !rgl.useNULL(), type = "gif", startTime = 0) {
  
  olddir <- setwd(dir)
  on.exit(setwd(olddir))
  
  for (i in round(startTime*fps):(duration*fps)) {
    time <- i/fps        
    if(cur3d() != dev) set3d(dev)
    stopifnot(cur3d() != 0)
    args <- f(time, ...)
    subs <- args$subscene
    if (is.null(subs))
      subs <- currentSubscene3d(dev)
    else
      args$subscene <- NULL
    for (s in subs)
      par3d(args, subscene = s)
    filename <- sprintf("%s%03d.png",frames,i)
    if (verbose) {
      cat(gettextf("Writing '%s'\r", filename))
      flush.console()
    }
    if (top)
      rgl.bringtotop()
    snapshot3d(filename=filename)
  }	
  cat("\n")
  if (.Platform$OS.type == "windows") system <- shell  # nolint
  if (is.null(convert) && requireNamespace("magick")) {
    m <- NULL
    for (i in round(startTime*fps):(duration*fps)) {
      filename <- sprintf("%s%03d.png",frames,i)
      frame <- magick::image_read(filename)
      if (is.null(m)) m <- frame
      else m <- c(m, frame)
      if (clean)
        unlink(filename)
    }
    m <- magick::image_animate(m, fps = fps, loop = 1, dispose = "previous")
    magick::image_write(m, paste0(movie, ".", type))
    return(invisible(m))
  } else if (is.null(convert)) {
    warning("R package 'magick' is not installed; trying external package.")
    convert <- TRUE
  }
  if (is.logical(convert) && convert) {
    # Check for ImageMagick
    progname <- "magick"
    version <- try(system2(progname, "--version", stdout = TRUE,
                           stderr = TRUE), silent = TRUE)
    if (inherits(version, "try-error") || !length(grep("ImageMagick", version))) {
      progname <- "convert"
      version <- try(system2(progname, "--version", stdout = TRUE, 
                             stderr = TRUE), silent = TRUE)
    }
    if (inherits(version, "try-error") || !length(grep("ImageMagick", version)))
      stop("'ImageMagick' not found")    
    filename <- paste0(movie, ".", type)
    if (verbose) cat(gettextf("Will create: %s\n", file.path(dir, filename)))
    convert <- paste(progname, "-delay 1x%d %s*.png %s.%s")
  }
  if (is.character(convert)) {
    convert <- sprintf(convert, fps, frames, movie, type, duration, dir)
    if (verbose) {
      cat(gettextf("Executing: '%s'\n", convert))
      flush.console()
    }
    system(convert)
    if (clean) {
      if (verbose)
        cat(gettext("Deleting frames\n"))
      for (i in 0:(duration*fps)) {
        filename <- sprintf("%s%03d.png",frames,i)
        unlink(filename)
      }
    }
  }
  invisible(convert)
}
