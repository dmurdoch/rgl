legend3d <- function(...) {
  args <- list(...)
  idx <- which(names(args) %in% c("sphere", "fogtype", "bg.color"))
  if (length(idx)) {
    bgargs <- args[idx]
    args <- args[-idx]
  } else
    bgargs <- NULL
  do.call(bgplot3d, c(list(quote({
    par(mar=c(0,0,0,0))
    plot(0,0, type="n", xlim=0:1, ylim=0:1, xaxs="i", yaxs="i", axes=FALSE, bty="n")
    do.call(legend, args)
  })), bgargs))
}

bgplot3d <- function(expression, bg.color = getr3dDefaults("bg", "color"), 
                     ...) {
  viewport <- par3d("viewport")
  width <- viewport["width"]
  height <- viewport["height"]
  if (width > 0 && height > 0) {
    filename <- tempfile(fileext = ".png")
    png(filename = filename, width = width, height = height,
        bg = bg.color)
    value <- try(expression)  
    dev.off()
    result <- bg3d(texture = filename, col = "white", lit = FALSE, ...)
  } else {
    value <- NULL
    result <- bg3d(col = bg.color, ...)
  }
  lowlevel(structure(result, value = value))
}

show2d <- function(expression, 
		   face = "z-",
		   line = 0,
		   reverse = FALSE,
		   rotate = 0,
		   x = NULL, y = NULL, z = NULL, 
		   width = 480,
		   height = 480,
		   filename = NULL,
		   ignoreExtent = TRUE,
		   color = "white", specular = "black",
		   lit = FALSE, 
		   texmipmap = TRUE,
		   texminfilter = "linear.mipmap.linear",
		   expand = 1.03,
		   texcoords = matrix(c(0,1,1,0,0,0,1,1), ncol=2),
		   ...) {
	
  save <- par3d(ignoreExtent = ignoreExtent)
  on.exit(par3d(save))
  
  if (is.null(filename)) {
    stopifnot(width > 0, height > 0)
    filename <- tempfile(fileext = ".png")
    png(filename = filename, width=width, height=height)
    value <- try(expression)  
    dev.off()
  } else
    value <- filename
  face <- c(strsplit(face, '')[[1]], '-')[1:2]
  coord <- tolower(face[1])
  lower <- face[2] == '-'
  
  ranges <- .getRanges(expand = expand)
    switch(coord,
      x = {
      	if (is.null(x)) 
      	  x <- with(ranges, if (lower) 
      	  	               x[1] - 0.075*line*diff(x)
      	  	            else
      	  	               x[2] + 0.075*line*diff(x))
      	if (is.null(y))
      	  y <- with(ranges, c(y[1], y[2], y[2], y[1]))
      	if (is.null(z))
      	  z <- with(ranges, c(z[1], z[1], z[2], z[2]))
      },
      y = {
      	if (is.null(x)) 
      		x <- with(ranges, c(x[1], x[2], x[2], x[1]))
      	if (is.null(y))
      		y <- with(ranges, if (lower) 
      			            y[1] - 0.075*line*diff(y)
      			          else
      				    y[2] + 0.075*line*diff(y))
      	if (is.null(z))
      		z <- with(ranges, c(z[1], z[1], z[2], z[2]))
      },      	
      z = {
      	if (is.null(x)) 
      		x <- with(ranges, c(x[1], x[2], x[2], x[1]))
      	if (is.null(y))
      		y <- with(ranges, c(y[1], y[1], y[2], y[2]))
      	if (is.null(z))
      		z <- with(ranges,  if (lower) 
      			             z[1] - 0.075*line*diff(z)
      			           else
      				     z[2] + 0.075*line*diff(z))
      }) 
  x <- cbind(x, y, z)  
  if (nrow(x) != 4) 
    stop("Exactly 4 corners must be specified.")
  
  if (reverse) {
    temp <- x[2,]
    x[2,] <- x[4,]
    x[4,] <- temp
  }
  if (rotate) 
    x <- x[(0:3 + rotate) %% 4 + 1, ]
  
  result <- quads3d(x, texture=filename, texcoords = texcoords,
  		  color = color, lit = lit, texmipmap = texmipmap, 
  		  texminfilter = texminfilter, ...)
  lowlevel(structure(result, value = value, xyz = x, texcoords = texcoords,
            filename = filename))
}
