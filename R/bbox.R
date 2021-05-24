##
## bbox
##
##

rgl.bbox <- function( 
  xat=NULL, xlab=NULL, xunit=0, xlen=5,
  yat=NULL, ylab=NULL, yunit=0, ylen=5,
  zat=NULL, zlab=NULL, zunit=0, zlen=5,
  marklen=15.0, marklen.rel=TRUE, expand=1, draw_front=FALSE,
  ...) {
  
  rgl.material( ... )
  
  if (is.null(xat)) 
    xlab <- NULL
  else {
    xlen <- length(xat)
    if (is.null(xlab)) 
      xlab <- format(xat)
    else 
      xlab <- rep(xlab, length.out=xlen)
  }
  if (is.null(yat)) 
    ylab <- NULL
  else {
    ylen <- length(yat)
    if (is.null(ylab)) 
      ylab <- format(yat)
    else 
      ylab <- rep(ylab, length.out=ylen)
  }
  if (is.null(zat)) 
    zlab <- NULL
  else {
    zlen <- length(zat)
    if (is.null(zlab)) 
      zlab <- format(zat)
    else 
      zlab <- rep(zlab,length.out=length(zat))
  }
  xticks <- length(xat)
  yticks <- length(yat)
  zticks <- length(zat)
  
  if (identical(xunit, "pretty")) xunit <- -1
  if (identical(yunit, "pretty")) yunit <- -1
  if (identical(zunit, "pretty")) zunit <- -1
  
  length(xlen)        <- 1
  length(ylen)        <- 1
  length(zlen)        <- 1
  length(marklen.rel) <- 1
  length(draw_front)  <- 1
  length(xunit)       <- 1
  length(yunit)       <- 1
  length(zunit)       <- 1
  length(marklen)     <- 1
  length(expand)      <- 1
  
  idata <- as.integer(c(xticks,yticks,zticks, xlen, ylen, zlen, marklen.rel, draw_front))
  ddata <- as.numeric(c(xunit, yunit, zunit, marklen, expand))
  
  ret <- .C( rgl_bbox,
             success = as.integer(FALSE),
             idata,
             ddata,
             as.numeric(xat),
             as.character(xlab),
             as.numeric(yat),
             as.character(ylab),
             as.numeric(zat),
             as.character(zlab)
  )
  
  if (! ret$success)
    stop("'rgl_bbox' failed")
  
  lowlevel(ret$success)
  
}

rgl.addtomargin <- function(margin, ids, bboxdeco = ids3d(type = "bboxdeco", ...)$id, ...) {
  if (is.character(margin))
    margin <- parseMargin(margin, "floating")
  margin$mode <- match.arg(margin$mode, c("fixed", "floating"))
  
  stopifnot(length(bboxdeco) == 1,
            bboxdeco %in% rgl.ids("bboxdeco")$id,
            length(margin$coord) == 1,
            length(margin$edge) ==  3,
            length(margin$mode) == 1,
            margin$mode %in% c("fixed", "floating"),
            all(ids %in% ids3d(type = "shapes", ...)$id))
  
  
  margin <- c(margin$coord-1, 
              margin$edge,
              match(margin$mode, c("fixed", "floating")) - 1)
  
  for (id in ids) {
    nvertices <- rgl.attrib.count(id, "vertices")
    if (nvertices > 0)
      origvertices <- t(rgl.attrib(id, "vertices"))
    else
      origvertices <- numeric()
    ret <- .C( rgl_addtomargin,
               success = as.integer(FALSE),
               bboxid = as.integer(bboxdeco),
               itemid = as.integer(id),
               nvertices = as.integer(nvertices),
               origvertices = as.numeric(origvertices),
               margin = as.integer(margin),
               NAOK = TRUE)$success
    if (!ret)
      stop("Error adding object ", id, " to margin.")
  }
  lowlevel(bboxdeco)
}
