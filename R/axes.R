axis3d <- function (edge, at = NULL, labels = TRUE, tick = TRUE, line = 0,
    pos = NULL, ...)
{
        save <- par3d(skipRedraw = TRUE, ignoreExtent = TRUE, ...)
        on.exit(par3d(save))
        
        ranges <- par3d('bbox')
        ranges <- list(xlim=ranges[1:2], ylim=ranges[3:4], zlim=ranges[5:6])

        ranges$x <- (ranges$xlim - mean(ranges$xlim))*1.03 + mean(ranges$xlim)
        ranges$y <- (ranges$ylim - mean(ranges$ylim))*1.03 + mean(ranges$ylim)
        ranges$z <- (ranges$zlim - mean(ranges$zlim))*1.03 + mean(ranges$zlim)

	edge <- c(strsplit(edge, '')[[1]], '-', '-')[1:3]
	coord <- match(toupper(edge[1]), c('X', 'Y', 'Z')) 
	
	# Put the sign in the appropriate entry of edge
	if (coord == 2) edge[1] <- edge[2]
	else if (coord == 3) edge[1:2] <- edge[2:3]
	
        range <- ranges[[coord]]

        if (is.null(at)) {
                at <- pretty(range)
                at <- at[at >= range[1] & at <= range[2]]
        }

        if (is.logical(labels)) {
                if (labels) labels <- as.character(at)
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
        segments3d(x,y,z)
        if (!all(is.na(labels)))
                text3d(mpos[1,]+3*ticksize[1],
                       mpos[2,]+3*ticksize[2],
                       mpos[3,]+3*ticksize[3],
                       labels)
}

axes3d <- function(edges='bbox', labels=TRUE,
                   tick=TRUE, ...)
{
    save <- par3d(skipRedraw = TRUE, ignoreExtent = TRUE)
    on.exit(par3d(save))
    if (identical(edges, 'bbox')) {
        do.call('bbox3d', .fixMaterialArgs(..., Params = list(front='lines', back='lines')))
    } else {
    	for (e in edges)
            axis3d(e,labels=labels,tick=tick)
    }
}

box3d <- function(...)
{
        save <- par3d(ignoreExtent = TRUE, ...)
        on.exit(par3d(save))
        ranges <- par3d('bbox')
        ranges <- list(xlim=ranges[1:2], ylim=ranges[3:4], zlim=ranges[5:6])

        ranges$x <- (ranges$xlim - mean(ranges$xlim))*1.03 + mean(ranges$xlim)
        ranges$y <- (ranges$ylim - mean(ranges$ylim))*1.03 + mean(ranges$ylim)
        ranges$z <- (ranges$zlim - mean(ranges$zlim))*1.03 + mean(ranges$zlim)
        x <- c(rep(ranges$x[1],8),rep(ranges$x,4),rep(ranges$x[2],8))
        y <- c(rep(ranges$y,2),rep(ranges$y,c(2,2)),rep(ranges$y,c(4,4)),
               rep(ranges$y,2),rep(ranges$y,c(2,2)))
        z <- c(rep(ranges$z,c(2,2)),rep(ranges$z,2),rep(rep(ranges$z,c(2,2)),2),
               rep(ranges$z,c(2,2)),rep(ranges$z,2))
        segments3d(x,y,z)
}

mtext3d <- function(text, edge, line = 0, at = NULL, pos = NA, ...)
{
        save <- par3d(ignoreExtent = TRUE, ...)
        on.exit(par3d(save))

        ranges <- par3d('bbox')
        ranges <- list(xlim=ranges[1:2], ylim=ranges[3:4], zlim=ranges[5:6])

        ranges$x <- (ranges$xlim - mean(ranges$xlim))*1.03 + mean(ranges$xlim)
        ranges$y <- (ranges$ylim - mean(ranges$ylim))*1.03 + mean(ranges$ylim)
        ranges$z <- (ranges$zlim - mean(ranges$zlim))*1.03 + mean(ranges$zlim)

	edge <- c(strsplit(edge, '')[[1]], '-', '-')[1:3]
	coord <- match(toupper(edge[1]), c('X', 'Y', 'Z')) 
	
	# Put the sign in the appropriate entry of edge
	if (coord == 2) edge[1] <- edge[2]
	else if (coord == 3) edge[1:2] <- edge[2:3]

        range <- ranges[[coord]]

        if (is.null(at)) at <- mean(range)

        newlen <- max(length(text),length(line),length(at))
        text <- rep(text, len = newlen)
        line <- rep(line, len = newlen)
        at <- rep(at, len = newlen)

        if (all(is.na(pos))) {
                pos <- matrix(NA,3,length(at))
                if (edge[1] == '+') pos[1,] <- ranges$x[2]
                else pos[1,] <- ranges$x[1]
                if (edge[2] == '+') pos[2,] <- ranges$y[2]
                else pos[2,] <- ranges$y[1]
                if (edge[3] == '+') pos[3,] <- ranges$z[2]
                else pos[3,] <- ranges$z[1]
        }
        else pos <- matrix(pos,3,length(at))
        pos[coord,] <- at
        ticksize <- 0.05*(pos[,1]-c(mean(ranges$x),mean(ranges$y),mean(ranges$z)))
        ticksize[coord] <- 0

        invisible(text3d(pos[1,]+3*ticksize[1]*line,
               pos[2,]+3*ticksize[2]*line,
               pos[3,]+3*ticksize[3]*line,
               text))
}   

title3d <- function (main = NULL, sub = NULL, xlab = NULL, ylab = NULL, 
    zlab = NULL, line = NA, ...) 
{
        save <- par3d(skipRedraw = TRUE, ignoreExtent = TRUE, ...)
        on.exit(par3d(save))
        if (!is.null(main)) {
            aline <- ifelse(is.na(line), 2, line)
            mtext3d(main, 'x++', line = aline)
        }
        if (!is.null(sub)) {
            aline <- ifelse(is.na(line), 3, line)
            mtext3d(sub, 'x', line = aline)
        }
        if (!is.null(xlab)) {
            aline <- ifelse(is.na(line), 2, line)
            mtext3d(xlab, 'x', line = aline)
        }
        if (!is.null(ylab)) {
            aline <- ifelse(is.na(line), 2, line)
            mtext3d(ylab, 'y', line = aline)
        }
        if (!is.null(zlab)) {
            aline <- ifelse(is.na(line), 2, line)
            mtext3d(zlab, 'z', line = aline)
        }                  

}
