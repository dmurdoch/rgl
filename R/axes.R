# This internal function returns a list with the following components:
# xlim, ylim, zlim:  the bounding box expanded so no coordinate has zero or negative extent
# strut:  a boolean indicating whether an expansion was done above
# x, y, z:  the box above expanded by a factor of expand

.getRanges <- function(expand = 1.03, ranges=par3d('bbox')) {
  ranges <- list(xlim=ranges[1:2], ylim=ranges[3:4], zlim=ranges[5:6])
  
  strut <- FALSE
  
  ranges <- lapply(ranges, function(r) {
    d <- diff(r)
    if (d > 0) return(r)
    strut <<- TRUE
    if (d < 0) return(c(0,1))
    else if (r[1] == 0) return(c(-1, 1))
    else return(r[1] + 0.4*abs(r[1])*c(-1,1))
  })
  
  ranges$strut <- strut
  
  ranges$x <- (ranges$xlim - mean(ranges$xlim))*expand + mean(ranges$xlim)
  ranges$y <- (ranges$ylim - mean(ranges$ylim))*expand + mean(ranges$ylim)
  ranges$z <- (ranges$zlim - mean(ranges$zlim))*expand + mean(ranges$zlim)
  
  ranges
}

axis3d <- function(edge, at = NULL, labels = TRUE, tick = TRUE, line = 0,
                   pos = NULL, nticks = 5, ...) {
  save <- par3d(skipRedraw = TRUE, ignoreExtent = TRUE)
  on.exit(par3d(save))
  
  ranges <- .getRanges()
  
  edge <- c(strsplit(edge, '')[[1]], '-', '-')[1:3]
  coord <- match(toupper(edge[1]), c('X', 'Y', 'Z')) 
  
  # Put the sign in the appropriate entry of edge
  if (coord == 2) edge[1] <- edge[2]
  else if (coord == 3) edge[1:2] <- edge[2:3]
  
  range <- ranges[[coord]]
  
  if (is.null(at)) {
    at <- pretty(range, nticks)
    at <- at[at >= range[1] & at <= range[2]]
  }
  
  if (is.logical(labels)) {
    if (labels) labels <- format(at)
    else labels <- NA
  }
  
  mpos <- matrix(NA,3,length(at))
  if (edge[1] == '+') mpos[1,] <- ranges$x[2]
  else mpos[1,] <- ranges$x[1]
  if (edge[2] == '+') mpos[2,] <- ranges$y[2]
  else mpos[2,] <- ranges$y[1]
  if (edge[3] == '+') mpos[3,] <- ranges$z[2]
  else mpos[3,] <- ranges$z[1]
  
  ticksize <- 0.05*(mpos[,1]-c(mean(ranges$x),mean(ranges$y),mean(ranges$z)))
  ticksize[coord] <- 0
  
  if (!is.null(pos)) mpos <- matrix(pos,3,length(at))
  mpos[coord,] <- at
  
  x <- c(mpos[1,1],mpos[1,length(at)])
  y <- c(mpos[2,1],mpos[2,length(at)])
  z <- c(mpos[3,1],mpos[3,length(at)])
  if (tick) {
    x <- c(x,as.double(rbind(mpos[1,],mpos[1,]+ticksize[1])))
    y <- c(y,as.double(rbind(mpos[2,],mpos[2,]+ticksize[2])))
    z <- c(z,as.double(rbind(mpos[3,],mpos[3,]+ticksize[3])))
  }
  result <- c(ticks=segments3d(x,y,z,...))
  
  if (!all(is.na(labels)))
    result <- c(result, labels=text3d(mpos[1,]+3*ticksize[1],
                                      mpos[2,]+3*ticksize[2],
                                      mpos[3,]+3*ticksize[3],
                                      labels, ...))
  lowlevel(result)
}

axes3d <- function(edges='bbox', labels=TRUE,
                   tick=TRUE, nticks = 5, box = FALSE, expand = 1.03, ...) {
  save <- par3d(skipRedraw = TRUE, ignoreExtent = TRUE)
  on.exit(par3d(save))
  if (identical(edges, 'bbox')) {
    bboxargs <- names(formals(rgl.bbox))
    bboxargs <- intersect(bboxargs, names(list(...)))
    otherargs <- setdiff(names(list(...)), bboxargs)
    bboxargs <- list(...)[bboxargs]
    otherargs <- list(...)[otherargs]
    result <- do.call('bbox3d', c(list(draw_front=box, expand=expand), bboxargs, 
                                  do.call('.fixMaterialArgs', c(otherargs, list(Params = list(front='lines', back='lines'))))))
  } else {
    result <- numeric(0)
    for (e in edges)
      result <- c(result, axis3d(e,labels=labels,tick=tick,nticks=nticks, ...))
    names(result) <- e
  }	
  lowlevel(result)  
}

box3d <- function(...) {
  save <- par3d(ignoreExtent = TRUE)        
  on.exit(par3d(save))
  
  result <- numeric(0)
  
  ranges <- .getRanges()          
  if (ranges$strut) {
    par3d(ignoreExtent = FALSE)
    result <- c(result, strut=segments3d(rep(ranges$xlim, c(2,2)),
                                         rep(ranges$ylim, c(2,2)),
                                         rep(ranges$zlim, c(2,2))))
    par3d(ignoreExtent = TRUE)
  }
  
  x <- c(rep(ranges$x[1],8),rep(ranges$x,4),rep(ranges$x[2],8))
  y <- c(rep(ranges$y,2),rep(ranges$y,c(2,2)),rep(ranges$y,c(4,4)),
         rep(ranges$y,2),rep(ranges$y,c(2,2)))
  z <- c(rep(ranges$z,c(2,2)),rep(ranges$z,2),rep(rep(ranges$z,c(2,2)),2),
         rep(ranges$z,c(2,2)),rep(ranges$z,2))
  lowlevel(c(result, lines=segments3d(x,y,z,...)))
}

# Convert edge code into values:
# coord = 1:3 for coordinate
# edge = 3 of "+" or "-" for other coords (ignore the one
# that matches coord)
# floating = TRUE if edge should move as bboxdeco moves
# labels

parseMargin <- function(code, mode = c("legacy", "fixed", "floating")) {
  stopifnot(length(code) == 1)
  mode <- match.arg(mode)
  if (!nchar(code)) 
    list(coord = 0, edge = c(0,0,0), mode = mode)
  else {
    default <- if (mode == "floating") "+" else "-"
    edge <- c(strsplit(code, '')[[1]], default, default)[1:3]
    coord <- match(toupper(edge[1]), c('X', 'Y', 'Z')) 
    edge <- match(edge, c("-", "+"))*2 - 3 # +/- 1
    edge[is.na(edge)] <- 0
    # Put the sign in the appropriate entry of edge
    if (coord == 2) edge[1] <- edge[2]
    else if (coord == 3) edge[1:2] <- edge[2:3]
    list(coord = coord, edge = edge, mode = mode)
  }
}

deparseMargin <- function(margin) {
  if (margin$coord %in% 1:3) {
    coord <- margin$coord
    edge <- margin$edge[-coord]
    edge <- c("-", ".", "+")[edge + 2]
    paste(c("x", "y", "z")[coord], 
          edge[1],
          edge[2], sep = "")
  } else
    ""
}

mtext3d <- function(text, edge, at = NULL, line = 0,
                    level = 0, 
                    mode = c("fixed", "floating", "legacy"), 
                    pos = NA, ...) {
  save <- par3d(ignoreExtent = TRUE)
  on.exit(par3d(save))
  
  if (!missing(pos) && missing(mode))
    mode <- "legacy"
  
  ranges <- .getRanges()
  mode <- match.arg(mode)
  
  newlen <- max(length(text),length(line),length(at))
  text <- rep(text, len = newlen)
  line <- rep(line, len = newlen)
  
  if (mode == "legacy") {
    margin <- parseMargin(edge, mode)
    coord <- margin$coord
    if (!(coord %in% 1:3))
      stop("Bad edge spec.")
    range <- ranges[[coord]]
    if (is.null(at)) at <- mean(range)
    at <- rep(at, len = newlen)
    if (all(is.na(pos))) {
      edge <- margin$edge
      pos <- matrix(NA,3,length(at))
      if (edge[1] == +1) pos[1,] <- ranges$x[2]
      else pos[1,] <- ranges$x[1]
      if (edge[2] == +1) pos[2,] <- ranges$y[2]
      else pos[2,] <- ranges$y[1]
      if (edge[3] == +1) pos[3,] <- ranges$z[2]
      else pos[3,] <- ranges$z[1]
    }
    else pos <- matrix(pos,3,length(at))
    pos[coord,] <- at
    ticksize <- 0.05*(pos[,1]-c(mean(ranges$x),mean(ranges$y),mean(ranges$z)))
    ticksize[coord] <- 0
    
    text3d(pos[1,]+3*ticksize[1]*line,
           pos[2,]+3*ticksize[2]*line,
           pos[3,]+3*ticksize[3]*line,
           text, ...)
  } else {
    if (!missing(pos))
      stop("'pos' is only used with mode 'legacy'")
    if (is.null(at))
      at <- NA
    text3d(x = cbind(at, line, level),
           texts = text, margin = edge,
           floating = mode == "floating", 
           ...)
  }
}   

title3d <- function(main = NULL, sub = NULL, xlab = NULL, ylab = NULL, 
                    zlab = NULL, line = NA, level = NA, mode = NULL, ...) {
  save <- par3d(skipRedraw = TRUE, ignoreExtent = TRUE)
  on.exit(par3d(save))
  
  if (length(mode))
    mode <- match.arg(mode, c("floating", "fixed", "legacy"))
  if ((is.null(mode) || mode != "legacy") && !nrow(rgl.ids("bboxdeco"))) {
    if (length(mode))
      warning("'mode' changed to 'legacy', as no bound box decoration found.")
    mode <- "legacy"
  }
  result <- numeric(0)
  if (!is.null(main)) {
    aline <- ifelse(is.na(line), 2, line)
    alevel <- ifelse(is.na(level), 2, level)
    amode <- if (is.null(mode)) "fixed" else mode
    result <- c(result, 
                main=mtext3d(main, 'x++', line = aline, level = alevel, mode = amode, ...))
  }
  if (!is.null(sub)) {
    aline <- ifelse(is.na(line), 2, line)
    alevel <- ifelse(is.na(level), 2, level)
    amode <- if (is.null(mode)) "fixed" else mode 
    result <- c(result, sub=mtext3d(sub, 'x--', line = aline, mode = amode, ...))
  }
  if (!is.null(xlab)) {
    aline <- ifelse(is.na(line), 4, line)
    alevel <- ifelse(is.na(level), 1, level)
    amode <- if (is.null(mode)) "floating" else mode 
    result <- c(result, xlab=mtext3d(xlab, 'x', line = aline, level = alevel, mode = amode, ...))
  }
  if (!is.null(ylab)) {
    aline <- ifelse(is.na(line), 4, line)
    alevel <- ifelse(is.na(level), 1, level)
    amode <- if (is.null(mode)) "floating" else mode 
    result <- c(result, ylab=mtext3d(ylab, 'y', line = aline, level = alevel, mode = amode, ...))
  }
  if (!is.null(zlab)) {
    aline <- ifelse(is.na(line), 4, line)
    alevel <- ifelse(is.na(level), 1, level)
    amode <- if (is.null(mode)) "floating" else mode 
    result <- c(result, zlab=mtext3d(zlab, 'z', line = aline, level = alevel, mode = amode, ...))
  }                  
  lowlevel(result)
}
