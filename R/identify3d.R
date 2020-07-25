identify3d <- function(x, y = NULL, z = NULL, labels = seq_along(x),
              n = length(x), plot = TRUE, adj = c(-0.1, 0.5),
              tolerance = 20, buttons = c("right", "middle")) {
              
    cat <- function(...) {
      base::cat(...)
      flush.console()
    }
    
    opar <- par3d("mouseMode")
    odisp <- cur3d()
    
    on.exit( {
      disp <- cur3d()
      if (odisp != disp) 
        try(set3d(odisp), silent=TRUE)
      if (cur3d() == odisp) 
        par3d(mouseMode = opar) 
      try(set3d(disp), silent=TRUE)
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
    
    if (length(buttons > 1))
      cat(gettextf("Use the %s button to select, the %s button to quit\n", 
      	           buttons[1], buttons[2]))
    else
      cat(gettextf("Use the %s button to select\n"), buttons[1])

    buttons <- c(left=1, right=2, middle=3)[buttons]
    
    selected <- c()
    
    select <- function(mousex, mousey) {
       disp <- cur3d()
       if (disp != odisp) {
         set3d(odisp)
         on.exit(set3d(disp))
       }
       viewport <- par3d("viewport")
       winxyz <- rgl.user2window(xyz)
       winxyz[,1] <- winxyz[,1]*viewport[3]
       winxyz[,2] <- (1-winxyz[,2])*viewport[4]
      
       dist <- sqrt( (mousex-winxyz[,1])^2 + (mousey - winxyz[,2])^2 )
       dist[winxyz[,3] < 0 | winxyz[,3] > 1] <- Inf
       sel <- which.min(dist)
       if (dist[sel] > tolerance)
       	  cat(gettext("Warning:  no point within tolerance\n"))
       else if (sel %in% selected)
          cat(gettext("Warning:  nearest point already identified\n"))
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

    
    
    
