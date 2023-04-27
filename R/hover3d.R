hover3d <- function(x, y = NULL, z = NULL, 
                    labeller = NULL,
                    tolerance = 20, 
                    persist = c("no", "one", "yes"),
                    labels = seq_along(x),
                    adj = c(-0.2, 0.5),
                    scene = scene3d(minimal = FALSE),
                    applyToScene = TRUE,
                    ...) {
  
	save <- par3d(skipRedraw = TRUE)
	on.exit(par3d(save))
	
  labelIndex <- function(sel, ...)
    text3d(x[sel], y[sel], z[sel], texts=labels[sel], adj=adj,
           ...)

  custom_labeller <- FALSE
  if (is.null(labeller)) 
    labeller <- labelIndex
  else
    custom_labeller <- TRUE
  
  stopifnot(is.function(labeller))
  
  persist <- match.arg(persist)
  
  opar <- par3d("mouseMode")
  odev <- cur3d()
  
  if (inherits(x, "rglId") ||
      (length(x) == 1 && is.null(y) && is.null(z))) {
    if (length(x) != 1)
      stop("Exactly one object may be specified as x.")
    idverts <- x
    x <- expandVertices(idverts)
  } else
    idverts <- numeric()
  
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
    save2 <- par3d(skipRedraw = TRUE)
    on.exit({par3d(save2); set3d(disp)})
    
    set3d(odev)

    viewport <- par3d("viewport")
    winxyz <- rgl.user2window(xyz)
    winxyz[,1] <- winxyz[,1]*viewport[3]
    winxyz[,2] <- (1-winxyz[,2])*viewport[4]

    change <- FALSE
    
    dist <- sqrt( (mousex-winxyz[,1])^2 + (mousey - winxyz[,2])^2 )
    dist[winxyz[,3] < 0 | winxyz[,3] > 1] <- Inf
    sel <- which.min(dist)
    if (dist[sel] <= tolerance) {
      if (persist != "yes")
        selected <<- Filter(function(s) 
                             if (s$sel != sel) {
                               pop3d(id = s$ids)
                             	 change <- TRUE
                               FALSE
                             } else TRUE, selected)
      prev <- Find(function(s) 
                     s$sel == sel, selected)
      if (is.null(prev)) {
        this <- list(sel = sel, ids = labeller(sel, ...))
        change <- TRUE
        selected <<- c(selected, list(this))
      }
    } else if (persist == "no" && length(selected)) {
      lapply(selected, function(s) pop3d(id = s$ids))
    	change <- TRUE
      selected <<- list()
    }
    if (change) {
    	par3d(skipRedraw = FALSE)
    }
  }
  
  js <- NULL
  if (applyToScene) {
    # Define the Javascript functions with the same names to use in WebGL
    js <-
    'window.hoverSelect = function(x, y) { 
       var   obj = this.getObj(%idverts%), i, newdist, 
             dist = Infinity, pt, newclosest, text,
             customlabeller = %customlabeller%[0],
             idtexts = %idtexts%, change = false,
             selected = window.hoverSelect.selected;
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
               if (customlabeller) {
                 idtexts[selected[0]].forEach(id => this.delFromSubscene(id, %subid%));
               } else {
                 text = this.getObj(idtexts[0]);
                 text.colors[selected[0]][3] = 0; // invisible!
               }
               selected = [];
               change = true;
             }
         if (!selected.includes(newclosest)) {
           selected.push(newclosest);
           if (customlabeller) {
             idtexts[newclosest].forEach(id => this.addToSubscene(id, %subid%));
           } else {
             text = this.getObj(idtexts[0]);
             text.colors[newclosest][3] = 1; // alpha is here!
           }
           change = true;
         }
       } else if ("%persist%" === "no" && selected.length > 0) {
         if (customlabeller) {
           idtexts[selected[0]].forEach(id => this.delFromSubscene(id, %subid%));
         } else {
           text = this.getObj(%idtexts%);
           text.colors[selected[0]][3] = 0;
         }
         selected = [];
         change = true;
       }
       if (change) {
         if (!customlabeller)
           text.initialized = false;
         window.hoverSelect.selected = selected;
         this.drawScene();
       }
     };
     window.hoverSelect.selected = [];
    '
    if (!length(idverts)) {
      idverts <- points3d(xyz)
      delFromSubscene3d(idverts)
    }
    
    if (custom_labeller) {
      idtexts <- vector("list", length(x))
      for (i in seq_along(x)) {
        idtexts[[i]] <- labeller(i, ...)
      }
      delFromSubscene3d(unlist(idtexts))
    } else {
      idtexts <- text3d(xyz, texts = labels, adj = adj, 
                      alpha = rep(0, length(labels)), ...)
      delFromSubscene3d(idtexts)
    }
    js <- gsub("%idverts%", idverts, js)  
    js <- gsub("%subid%", subsceneInfo()$id, js)
    js <- gsub("%idtexts%", toJSON(idtexts), js)
    js <- gsub("%tolerance%", tolerance, js)
    js <- gsub("%persist%", persist, js)
    js <- gsub("%customlabeller%", toJSON(custom_labeller), js)
  } else
    idtexts <- numeric()
  
  setUserCallbacks(0, update="hoverSelect",
                   scene = scene,
                   applyToScene = applyToScene,
                   applyToDev = TRUE,
                   javascript = js)
  
  structure(lowlevel(c(idverts, unlist(idtexts))),                         oldPar = opar, oldDev = odev)
}
