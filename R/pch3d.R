pch3d <- function(x, y = NULL, z = NULL, pch = 1, bg = material3d("color")[1], 
		  cex = 1, radius = avgscale*cex/8, color = "black", lit = FALSE, ...) {
  xyz <- xyz.coords(x, y, z)
  xyz <- cbind(xyz$x, xyz$y, xyz$z)
  pch <- rep(pch, length.out = nrow(xyz))
  color <- rep(color, length.out = nrow(xyz))
  bg <- rep(bg, length.out = nrow(xyz))
  
  basic <- function(p) 
  	switch(as.character(p),
  	       '0' = { # square
  	       	theta <- seq(pi/4, 2*pi + pi/4, length.out = 5)
  	       	cbind(cos(theta), sin(theta), 0)
  	       },
  	       '1' = { # circle (actually 16-gon)
  	       	theta <- seq(0, 2*pi, length.out = 17)
  	       	cbind(cos(theta), sin(theta), 0)*sqrt(0.75)
  	       },
  	       '2' = { # triangle
  	       	theta <- seq(pi/2, 2*pi + pi/2, length.out = 4)
  	       	cbind(cos(theta), sin(theta), 0)
  	       },
  	       '-2' = { # triangle in square
  	       	cbind(c(0, -1, 1, 0), c(1, -1, -1, 1), 0)*sqrt(0.5)
  	       },
  	       '3' = { # plus
  	       	theta <- seq(0, 2*pi, length.out = 5)
  	       	rbind(cbind(cos(theta[c(1,3)]), sin(theta[c(1,3)]), 0),
  	       	      c(NA, NA, NA),
  	       	      cbind(cos(theta[c(2,4)]), sin(theta[c(2,4)]), 0))
  	       },
  	       '4' = { # cross
  	       	theta <- seq(pi/4, 2*pi + pi/4, length.out = 5)
  	       	rbind(cbind(cos(theta[c(1,3)]), sin(theta[c(1,3)]), 0),
  	       	      c(NA, NA, NA),
  	       	      cbind(cos(theta[c(2,4)]), sin(theta[c(2,4)]), 0))
  	       },      	
  	       '5' = { # diamond
  	       	theta <- seq(0, 2*pi, length.out = 5)
  	       	cbind(cos(theta), sin(theta), 0)
  	       },
  	       '6' = { # nabla
  	       	theta <- seq(3*pi/2, 2*pi + 3*pi/2, length.out = 4)
  	       	cbind(cos(theta), sin(theta), 0)
  	       })*radius
  
  join <- function(s1, s2) 
    rbind(s1, c(NA, NA, NA), s2)
  
  if (missing(radius))
    avgscale <- sqrt(sum(c(diff(range(xyz[,1],na.rm=TRUE)), 
  			   diff(range(xyz[,2],na.rm=TRUE)), 
  			   diff(range(xyz[,3],na.rm=TRUE)))^2/3))
  
  rot <- rotate3d(r3dDefaults$userMatrix, pi/2, 1, 0, 0)
  
  draw <- function(s, color) {
    sprites3d(thisxyz, shapes = lines3d(s, color = color, lit = lit, ...), userMatrix = rot)
  }
  
  fill <- function(s, color)
    sprites3d(thisxyz, shapes = polygon3d(s, color = color, lit = lit, ...), userMatrix = rot)
  
  outline <- function(s, color, bg) {
    dots <- list(...)
    dots$color <- bg
    sprites3d(thisxyz, shapes = c(lines3d(s, color = color, lit = lit, ...), do.call(polygon3d, c(list(s, lit = lit), dots))),
    	      userMatrix = rot)
  }
  
  save <- par3d(skipRedraw = TRUE)
  on.exit(par3d(save))
  
  ids <- numeric()   
  if (is.numeric(pch)) {
    bg[!(pch %in% 21:25)] <- bg[1]
    pchcol <- data.frame(pch, color, bg)
    uniquePchcol <- unique(pchcol)
    for (i in seq_len(nrow(uniquePchcol))) {
      p <- uniquePchcol$pch[i]
      cl <- uniquePchcol$color[i]
      b <- uniquePchcol$bg[i]
      thisxyz <- xyz[p == pch & cl == color & b == bg,, drop = FALSE]
      ids <- c(ids, switch(as.character(p),
        '0' =,
        '1' =,
        '2' =, 
        '3' =,
        '4' =,
        '5' =,
        '6' = draw(basic(p), color = cl),
        '7' = draw(join(basic(0), basic(4)), color = cl),
        '8' = draw(join(basic(3), basic(4)), color = cl),
        '9' = draw(join(basic(3), basic(5)), color = cl),
        '10' = draw(join(basic(1), basic(3)*sqrt(0.75)), color = cl),
        '11' = draw(join(basic(2), basic(6)), color = cl),
        '12' = draw(join(basic(0), basic(3)*sqrt(0.5)), color = cl),
        '13' = draw(join(basic(1), basic(4)), color = cl),
        '14' = draw(join(basic(0), basic(-2)), color = cl),
        '15' = fill(basic(0), color = cl),
        '16' = fill(basic(1), color = cl),
        '17' = fill(basic(2), color = cl),
        '18' = fill(basic(5)/sqrt(2), color = cl),
        '19' = fill(basic(1), color = cl),
        '20' = fill(basic(1)*(2/3), color = cl),
        '21' = outline(basic(1), color = cl, bg = b),
        '22' = outline(basic(0), color = cl, bg = b),
        '23' = outline(basic(5), color = cl, bg = b),
        '24' = outline(basic(2), color = cl, bg = b),
        '25' = outline(basic(6), color = cl, bg = b)))
    }
    letters <- 32 <= pch & pch <= 255
    xyz <- xyz[letters,, drop = FALSE]
    if (nrow(xyz)) {
      pch <- rawToChar(as.raw(pch[letters]), multiple = TRUE)
      color <- color[letters]
    }
  }
  if (nrow(xyz)) {
    pch <- substr(pch, start = 1, stop = 1)
    ids <- c(ids, text3d(xyz, texts = pch, cex = cex, color = color, ...))
  }
  lowlevel(ids)
}
