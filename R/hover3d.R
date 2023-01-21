hover3d <- function(x, y = NULL, z = NULL, 
                    labeller = NULL,
                    tolerance = 20, 
                    persist = c("no", "one", "yes"),
                    labels = seq_along(x),
                    adj = c(-0.2, 0.5),
                    applyToScene = TRUE,
                    applyToDev = TRUE,
                    ...) {
  
  labelIndex <- function(sel, ...)
    text3d(x[sel], y[sel], z[sel], texts=labels[sel], adj=adj,
           ...)

  if (is.null(labeller))
    labeller <- labelIndex
  else if (applyToScene) {
    warning("Use of labeller is not supported with applyToScene")
    applyToScene <- FALSE
  }
  
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
  
  hoverSelect <- function(mousex, mousey) {
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
    if (dist[sel] <= tolerance) {
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
  
  js <- NULL
  if (applyToScene) {
    # Define the Javascript functions with the same names to use in WebGL
    js <-
    ' var selected = [];
   
     window.hoverSelect = function(x, y) { 
       var   obj = this.getObj(%idverts%), i, newdist, dist = Infinity, pt, newclosest, text;
       for (i = 0; i < obj.vertices.length; i++) {
         pt = obj.vertices[i].concat(1);
         pt = this.user2window(pt, %subid%);
         pt[0] = x - pt[0]*this.canvas.width;
         pt[1] = y - pt[1]*this.canvas.height;
         pt[2] = 0;
         newdist = rglwidgetClass.vlen(pt);
         if (newdist < dist) {
           dist = newdist;
           newclosest = i;
         }
       }
       if (dist <= %tolerance%) {
         if ("%persist%" !== "yes" && 
             selected.length > 0 &&
             selected[0] !== newclosest) {
               text = this.getObj(%idtexts%);
               text.colors[selected[0]][3] = 0; // invisible!
               selected = [];
             }
         if (!selected.includes(newclosest)) {
           selected.push(newclosest);
           text = this.getObj(%idtexts%);
           text.colors[newclosest][3] = 1; // alpha is here!
         }
       } else if ("%persist%" === "no" && selected.length > 0) {
         text = this.getObj(%idtexts%);
         text.colors[selected[0]][3] = 0;
         selected = [];
       }
       if (typeof text !== "undefined") {  
         text.initialized = false;
         this.drawScene();
       }
     };'
    idverts <- points3d(xyz)
    delFromSubscene3d(idverts)
    idtexts <- text3d(xyz, texts = labels, adj = adj, 
                      alpha = rep(0, length(labels)), ...)

    js <- gsub("%idverts%", idverts, js)  
    js <- gsub("%subid%", subsceneInfo()$id, js)
    js <- gsub("%idtexts%", idtexts, js)
    js <- gsub("%tolerance%", tolerance, js)
    js <- gsub("%persist%", persist, js)
  }
  setUserCallbacks(0, update="hoverSelect", 
                   applyToScene = applyToScene,
                   applyToDev = applyToDev,
                   javascript = js)
  
  invisible(list(oldPar = opar, oldDev = odev))
}
