identify3d <- function(x, y = NULL, z = NULL, labels = seq_along(x),
              n = length(x), plot = TRUE, adj = c(-0.1, 0.5),
              tolerance = 20, buttons = c("right", "middle")) {
              
    cat <- function(...) {
      base::cat(...)
      flush.console()
    }
    
    opar <- par3d("mouseMode")
    odisp <- rgl.cur()
    
    on.exit( {
      disp <- rgl.cur()
      if (odisp != disp) 
        try(rgl.set(odisp), silent=TRUE)
      if (rgl.cur() == odisp) 
        par3d(mouseMode = opar) 
      try(rgl.set(disp), silent=TRUE)
    } )     
    
    xyz <- xyz.coords(x, y, z)
    x <- xyz$x
    y <- xyz$y
    z <- xyz$z
    if (length(x)==0) 
        return(numeric())
        
    force(labels)
    force(adj)
        
    buttons <- match.arg(buttons, c("left", "right", "middle"), several.ok = TRUE)
    
    cat("Use the", buttons[1], "button to select")
    if (length(buttons) > 1)
      cat(", the", buttons[2], "button to quit")
    cat(".\n")
    
    buttons <- c(left=1, right=2, middle=3)[buttons]
    
    selected <- c()
    
    select <- function(mousex, mousey) {
       disp <- rgl.cur()
       if (disp != odisp) {
         rgl.set(odisp)
         on.exit(rgl.set(disp))
       }
       viewport <- par3d("viewport")
       winxyz <- rgl.user2window(xyz)
       winxyz[,1] <- winxyz[,1]*viewport[3]
       winxyz[,2] <- (1-winxyz[,2])*viewport[4]
      
       dist <- sqrt( (mousex-winxyz[,1])^2 + (mousey - winxyz[,2])^2 )
       dist[winxyz[,3] < 0 | winxyz[,3] > 1] <- Inf
       sel <- which.min(dist)
       if (dist[sel] > tolerance)
       	  cat("warning:  no point within tolerance\n")
       else if (sel %in% selected)
          cat("warning:  nearest point already identified\n")
       else {
          selected <<- c(selected, sel)
          if (plot) 
              text3d(x[sel], y[sel], z[sel], texts=labels[sel], adj=adj)
       }
    }
    
    doquit <- FALSE
    
    quit <- function(mousex, mousey) {
       doquit <<- TRUE
    }
    
    rgl.setMouseCallbacks(buttons[1], begin=select)
    if (length(buttons) > 1)
    	rgl.setMouseCallbacks(buttons[2], begin=quit)
    
    while(!doquit && length(selected) < n) Sys.sleep(0.2)
    selected
}

    
    
    