grid3d <- function (side, at = NULL, col="gray",
                    lwd = 1, lty = 1, n = 5) {

  save <- par3d(skipRedraw = TRUE, ignoreExtent = TRUE)
  on.exit(par3d(save))

  if (!missing(side) && length(side)>1)
    return(lowlevel(sapply(side,grid3d,at=at,col=col,lwd=lwd,lty=lty,n=n)))
  
  ranges <- .getRanges()

  side <- c(strsplit(side, '')[[1]], '-')[1:2]
  coord <- match(toupper(side[1]), c('X', 'Y', 'Z'))
  spos <- match(side[2],c('-','+'))

  sidenames <- c('x', 'y', 'z')
  
  sides <- 1:3
  sides <- sides[-coord]

  if (is.null(at)) at <- list()
  else if (is.numeric(at)) {
    at <- list(x=at, y=at, z=at)
    at[[coord]] <- NULL
  }
  
  result <- c()
  
  for (cside in sides) {
    range <- ranges[[cside]]
    if (is.null(at1 <- at[[sidenames[cside]]]))
      at1 <- pretty(range, n)
    at1 <- at1[at1 >= range[1] & at1 <= range[2]]
    mpos1 <- matrix(rep(c(ranges$x[1],ranges$y[1],ranges$z[1]),
                        each=length(at1)),
                    ncol=3)
    mpos2 <- matrix(rep(c(ranges$x[2],ranges$y[2],ranges$z[2]),
                        each=length(at1)),
                  ncol=3)
    mpos1[,cside] <- mpos2[,cside] <- at1
    if (is.null(at[[sidenames[coord]]]))
      mpos1[,coord] <- mpos2[,coord] <- ranges[c("x","y","z")][[coord]][spos]
    else {
      # may need to duplicate 
      temp1 <- temp2 <- matrix(NA, nrow=0, ncol=3)
      planes <- at[[sidenames[coord]]]
      planes <- planes[planes >= ranges[[coord]][1] & planes <= ranges[[coord]][2]]
      for (at2 in planes) {
      	mpos1[,coord] <- mpos2[,coord] <- at2
      	temp1 <- rbind(temp1, mpos1)
      	temp2 <- rbind(temp2, mpos2)
      }
      mpos1 <- temp1
      mpos2 <- temp2
    }
      
    result[sidenames[cside]] <- segments3d(x=c(rbind(mpos1[,1],mpos2[,1])),
               y=c(rbind(mpos1[,2],mpos2[,2])),
               z=c(rbind(mpos1[,3],mpos2[,3])),
               lwd=lwd,color=col)
  }
  lowlevel(result)
}
