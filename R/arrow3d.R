## Original by Barry Rowlingson, R-help, 1/10/2010
## Modified by Michael Friendly: added barblen (to specify absolute barb length)
## Modified by DJM: multiple changes

arrow3d <- function(p0=c(1,1,1), p1=c(0,0,0), barblen, s=1/3, theta=pi/12, 
		     type = c("extrusion", "lines", "flat", "rotation"), 
		     n = 3, 
		     width = 1/3, 
		     thickness = 0.618*width,
		     smooth = FALSE, 
		     spriteOrigin = NULL, ...){
 ##      p0: start point
 ##      p1: end point
 ## barblen: length of barb
 ##       s: length of barb as fraction of line length (unless barblen is specified)
 ##   theta: opening angle of barbs
 ##    type: type of arrow to draw 
 ##       n: number of barbs
 ##   width: width of shaft as fraction of barb width
 ##   thickness: thickness of shaft as fraction of barb width	
 ##  smooth: should arrows be smooth?
 ##  spriteOrigin: origin if drawn as sprite
 ##     ...: args passed to lines3d for line styling
 ##
 ## Returns (invisibly): integer ID(s) of the shape added to the scene

 type <- match.arg(type)
 
 nbarbs <- if (type == "lines") n else 2
 
 ## Work in isometric display coordinates
 
 save <- par3d(FOV = 0)
 
 # Compute the center line in window
 # coordinates
 xyz <- rgl.user2window(rbind(p0, p1))
 p0 <- xyz[1,]
 p1 <- xyz[2,]
 
 ## rotational angles of barbs
 phi <- seq(pi/nbarbs, 2*pi-pi/nbarbs, len = nbarbs)

 ## length of line
 lp <- sqrt(sum((p1-p0)^2))

 if (missing(barblen))
   barblen <- s*lp
 else
   s <- barblen/lp
 
 ## point down the line where the barb ends line up
 cpt <- p1 + s*cos(theta)*(p0-p1)

 ## need to find a right-angle to the line. 
 gs <- GramSchmidt(p1-p0, c(0,0,-1), c(1,0,0))
 r <- gs[2,]

 ## now compute the barb end points and draw:
 pts = list()
 for(i in 1:length(phi)){
   ptb <- rotate3d(r,phi[i],(p1-p0)[1],(p1-p0)[2],(p1-p0)[3])
   xyz <- rbind(xyz, p1, cpt + barblen*sin(theta)*ptb)
 }
 if (type != "lines") {
   xyz <- xyz[c(3, # 1 head
   	        6, # 2 end of barb 1
   	        6, # 3 end of barb 1 again (to be shrunk)
   	        1, # 4 end of line (to be pushed out)
   	        1, # 5 end of line
   	        1, # 6 end of line (to be pushed the other way)
   	        4, # 7 end of barb 2 (to be shrunk)
   	        4, # 8 end of barb 2
   	        3),] # 9 head
   mid <- (xyz[2,] + xyz[8,])/2
   xyz[3,] <- mid + width*(xyz[2,] - mid)
   xyz[7,] <- mid + width*(xyz[8,] - mid)
   xyz[4,] <- xyz[4,] + xyz[3,] - mid
   xyz[6,] <- xyz[6,] + xyz[7,] - mid
 }
 
 if (type %in% c("extrusion", "rotation")) {
   xyz <- xyz %*% t(gs)
   if (type == "extrusion") {
     thickness <- thickness*sqrt(sum((xyz[2,]-xyz[8,])^2))
     ext <- extrude3d(xyz[,c(1,3)], thickness = thickness, smooth = smooth)
   } else {
     mid <- xyz[1,3]
     xyz[,3] <- xyz[,3] - mid
     xyz <- xyz[xyz[,3] >= 0,]
     xyz <- xyz[-nrow(xyz),]
     ext <- turn3d(xyz[,c(1,3)], n = n, smooth = smooth)
     ext$vb[2,] <- ext$vb[2,] + mid
     thickness <- 0
   }
   ext$vb <- ext$vb[c(1,3,2,4),]
   ext$vb[2,] <- ext$vb[2,] + xyz[1,2] - thickness/2
   ext$vb[1:3,] <- t(gs) %*% ext$vb[1:3,]
   ext$vb[1:3,] <- t(rgl.window2user(t(ext$vb[1:3,])))
 } else
   xyz <- rgl.window2user(xyz)
 par3d(save)
 if (type == "flat")
   id <- polygon3d(xyz, ...)
 else if (type %in% c("extrusion", "rotation"))
   id <- shade3d(ext, ...)
 else
   id <- segments3d(xyz, ...)
 
 if (is.null(spriteOrigin))
   invisible(id)
 else
   invisible(sprites3d(spriteOrigin, shapes=id))
}
