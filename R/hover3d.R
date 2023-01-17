hover3d <- function(x, y = NULL, z = NULL, 
                    labeller = NULL,
                    tolerance = 20, 
                    persist = c("no", "one", "yes"),
                    labels = seq_along(x),
                    adj = c(-0.2, 0.5),
                    ...) {
  
  labelIndex <- function(sel, ...)
    text3d(x[sel], y[sel], z[sel], texts=labels[sel], adj=adj,
           ...)

  if (is.null(labeller))
    labeller <- labelIndex
  
  stopifnot(is.function(labeller))
  
  persist <- match.arg(persist)
  
  opar <- par3d("mouseMode")
  odev <- cur3d()
  
  xyz <- xyz.coords(x, y, z)
  x <- xyz$x
  y <- xyz$y
  z <- xyz$z
  if (length(x)==0) 
    stop("No points to identify.")
  
  force(labels)
  force(adj)
  
  selected <- list()
  
  select <- function(mousex, mousey) {
    disp <- cur3d()
    if (disp != odev) {
      set3d(odev)
      on.exit(set3d(disp))
    }
    viewport <- par3d("viewport")
    winxyz <- rgl.user2window(xyz)
    winxyz[,1] <- winxyz[,1]*viewport[3]
    winxyz[,2] <- (1-winxyz[,2])*viewport[4]
    
    dist <- sqrt( (mousex-winxyz[,1])^2 + (mousey - winxyz[,2])^2 )
    dist[winxyz[,3] < 0 | winxyz[,3] > 1] <- Inf
    sel <- which.min(dist)
    if (dist[sel] < tolerance) {
      save <- par3d(skipRedraw = TRUE)
      on.exit(par3d(save), add = TRUE)
      if (persist != "yes")
        selected <<- Filter(function(s) 
                             if (s$sel != sel) {
                               pop3d(id = s$ids)
                               FALSE
                             } else TRUE, selected)
      prev <- Find(function(s) 
                     s$sel == sel, selected)
      if (is.null(prev)) {
        this <- list(sel = sel, ids = labeller(sel, ...))
        selected <<- c(selected, list(this))
      }
    } else if (persist == "no" && length(selected)) {
      lapply(selected, function(s) pop3d(id = s$ids))
      selected <<- list()
    }
  }
  
  rgl.setMouseCallbacks(0, update=select)
  invisible(list(oldPar = opar, oldDev = odev))
}
