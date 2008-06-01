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
                     extrapolate = c("oscillate","cycle","constant", "natural")) {                
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
	data <- cbind(data, t(userMatrix[,4,]))
	persp <- ncol(data) + 1:3
	data <- cbind(data, t(userMatrix[4,1:3,]))
	rot <- ncol(data) + 1:4
	data <- cbind(data, toQuaternions(userMatrix[1:3,1:3,]))
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
    	stop("natural extrapolation only supported for spline method")
    
    if (method == "spline") {
    	fns <- apply(data, 2, function(col) splinefun(times, col, 
    	                         method = ifelse(extrapolate == "cycle", "periodic", "natural")))
    } else {
    	fns <- apply(data, 2, function(col) approxfun(times, col, rule=2))
    }
    
    mintime <- min(times)
    maxtime <- max(times)
    
    function(time) {
        stopifnot(rgl.cur() != 0)
        if (time < mintime || time > maxtime) {
            if (extrapolate == "constant")
            	time <- ifelse(time < mintime, mintime, maxtime)
            else if (extrapolate == "cycle")
                time <- (time - mintime) %% (maxtime - mintime) + mintime
        }
    	data <- sapply(fns, function(f) f(time))
    	result <- list()
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

spin3d <- function(axis = c(0, 0, 1), rpm = 5) {
    M <- par3d("userMatrix")
    function(time) 
    	list(userMatrix = rotate3d(M, time*rpm*pi/30, axis[1], axis[2], axis[3]))
}
    
play3d <- function(f, duration = Inf, dev = rgl.cur(), ...) {
    # Don't want to start timing until args are known: they may be obtained
    # interactively
    force(f)  
    force(duration)
    force(dev)
    start <- proc.time()[3]
    repeat {
       if(rgl.cur() != dev) rgl.set(dev)
       time <- proc.time()[3] - start
       if (time > duration) return(invisible(NULL))
       par3d(f(time, ...))
    }
}

movie3d <- function(f, duration, dev = rgl.cur(), ..., fps=10, 
                    movie = "movie", frames = movie, dir = tempdir(), 
                    convert = TRUE, clean = TRUE, verbose=TRUE,
                    top = TRUE) {
    
    olddir <- setwd(dir)
    on.exit(setwd(olddir))

    for (i in 0:(duration*fps)) {
	time <- i/fps        
	if(rgl.cur() != dev) rgl.set(dev)
	par3d(f(time, ...))
	filename <- sprintf("%s%03d.png",frames,i)
	if (verbose) {
	    cat("Writing", filename, "\r")
	    flush.console()
	}
        rgl.snapshot(filename=filename, fmt="png", top=top)
    }	
    cat("\n")
    if (.Platform$OS.type == "windows") system <- shell
    if (is.logical(convert) && convert) {
        # Check for ImageMagick
        version <- system("convert --version", intern=TRUE)
        if (!length(grep("ImageMagick", version)))
            stop("ImageMagick not found")    
        filename <- paste(movie, ".gif", sep="")
        if (verbose) cat("Will create: ", file.path(dir, filename), "\n")
        wildcard <- paste(frames,"*.png", sep="")
    	convert <- paste("convert -delay 1x", fps, " ",wildcard, " ", filename, sep="")
    }
    if (is.character(convert)) {
	if (verbose) {
	    cat("Executing: ", convert, "\n")
	    flush.console()
	}
	system(convert)
	if (clean) {
	    if (verbose)
	    	cat("Deleting frames.\n")
	    for (i in 0:(duration*fps)) {
	    	filename <- sprintf("%s%03d.png",frames,i)
	    	unlink(filename)
	    }
	}
    }
}

