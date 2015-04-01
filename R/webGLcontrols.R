
# This displays an HTML5 input widget to show a subset of objects.  It assigns a random id
# and returns that invisibly.

subsetSlider <- function(setter = subsetSetter, init = 1,labels = names(subsets), 
			    id = paste0(basename(tempfile("input"))), name = id,
			    ...) {
  if (is.function(setter))
    setter <- setter(...)
  if (!inherits(setter, "subsetSetter"))
    stop(dQuote(setter), " must be a subsetSetter object.")

  env <- attr(setter, "env")
  subsets <- env$subsets
  if (is.null(labels)) labels <- seq_along(subsets)
  cat(subst(
'<input type="range" min="0" max="%max%" step="1" value="%init%" id="%id%" name="%name%"
oninput = "(%setter%)(this.valueAsNumber); 
  document.getElementById(\'%id%text\').value = labels[value];"></input><output id="%id%text">%label%</output>', 
    max = length(subsets)-1, init = init-1, name, id,
    setter, labels = paste0("'", labels, "'", collapse=","),
    label = labels[init]))
  invisible(id)
}

subsetSetter <- function(subsets, subscene = currentSubscene3d(), prefix = "", 
			 fullset = Reduce(union, subsets)) {
  result <- subst(
'function(value) {
  var ids = [%vals%]; 
  var labels = [%labels%];
  var fullset = [%fullset%];
  var entries = %prefix%rgl.getSubsceneEntries(%subscene%);
  entries = entries.filter(function(x) { return fullset.indexOf(x) < 0 });
  entries = entries.concat(ids[value]);
  %prefix%rgl.setSubsceneEntries(entries, %subscene%); 
  %prefix%rgl.drawScene();
}', vals = paste(paste0("[", sapply(subsets, 
    				function(i) paste(i, collapse=",")), 
    				"]"), collapse=","), prefix, subscene,
    fullset = paste(fullset, collapse=","))
  structure(result,
    env = environment(), class = "subsetSetter")    
  
}

toggleButton <- function(subset, subscene = currentSubscene3d(), prefix = "", 
			 label = deparse(substitute(subset)), 
			 id = paste0(basename(tempfile("input"))), name = id) {
  cat(subst(
'<button type="button" id="%id%" name="%name%" onclick = "(function(){
  var subset = [%subset%];
  if (%prefix%rgl.inSubscene(subset[0], %subscene%)) {
    for (var i=0; i<subset.length; i++)
      %prefix%rgl.delFromSubscene(subset[i], %subscene%);
  } else {
    for (var i=0; i<subset.length; i++)
      %prefix%rgl.addToSubscene(subset[i], %subscene%);
  }
  %prefix%rgl.drawScene();
})()">%label%</button>', 
  name, id, subset = paste(subset, collapse=","),
  prefix, subscene, label))
  invisible(id)
}

clipplaneSlider <- function(a=NULL, b=NULL, c=NULL, d=NULL, 
			    plane = 1, clipplaneid, prefix = "", 
			    labels = signif(values[,1],3), 
			      ...) {
  values <- cbind(a = a, b = b, c = c, d = d)
  col <- which(colnames(values) == letters[1:4]) - 1
  propertySlider(values = values, entries = 4*(plane-1) + col,
  	         properties = "vClipplane", objids = clipplaneid, 
  	         prefixes = prefix, labels = labels, ...)
}

propertySlider <- function(setter = propertySetter,
                           minS = min(param), maxS = max(param), step = 1, init = minS, 
                           labels = signif(seq(minS, maxS, by = step), 2), 
                           id = paste0(basename(tempfile("input"))), name = id,
                           ...)  {
  if (is.function(setter))
    setter <- setter(...)
  if (!inherits(setter, "propertySetter"))
    stop(dQuote(setter), " must be a propertySetter object.")
    
  env <- attr(setter, "env")
  param <- env$param
  prefixes <- env$prefixes
  
  sliderVals <- seq(minS, maxS, by = step)
  prefix <- prefixes[1]
  result <- subst(
'<script>%prefix%rgl.%id% = function(value){
   (%setter%)(value);
   var lvalue = Math.round((value - %minS%)/%step%);
   var labels = [%labels%];
   document.getElementById(\'%id%text\').value = labels[lvalue];
}</script><input type="range" min="%minS%" max="%maxS%" step="%step%" value="%init%" id="%id%" name="%name%"
oninput = "%prefix%rgl.%id%(this.valueAsNumber)"></input><output id="%id%text">%label%</output>', 
    prefix, id, 
    setter = setter,
    minS, maxS, step, init, name,
    labels = paste0("'", labels, "'", collapse=","), 
    label = labels[round(init-minS)/step + 1])
  cat(result, sep="\n")
  invisible(id)
}

propertySetter <- function(values, entries, properties, objids, prefixes = "",
                           param = seq_len(NROW(values)), interp = TRUE,
			   digits = 7)  {
  values <- matrix(values, NROW(values))
  ncol <- ncol(values)
  stopifnot(length(entries) == ncol,
            all(diff(param) > 0))
  prefixes <- rep(prefixes, length.out = ncol)
  properties <- rep(properties, length.out = ncol)
  objids <- rep(objids, length.out = ncol)
  prefix <- prefixes[1]
  property <- properties[1]
  objid <- objids[1]
  if (interp) values <- rbind(values[1,], values, values[nrow(values),])
  get <- if (property == "userMatrix") ".getAsArray()" else ""
  load <- if (property == "userMatrix") ".load(propvals)" else "= propvals"
  result <- c(subst(
'function(value){
   var values = [%vals%];', 
     vals = paste(formatC(as.vector(t(values)), digits = digits, width = 1), 
     	          collapse = ",")),
     
   subst(
'   var propvals = %prefix%rgl.%property%[%objid%]%get%;',
     prefix, property, objid, get),   

   if (interp) subst(
'   var svals = [-Infinity, %svals%, Infinity];
   for (var i = 1; i < svals.length; i++) 
     if (value <= svals[i]) {
       var p = (svals[i] - value)/(svals[i] - svals[i-1]);',
     svals = paste(formatC(param, digits = digits, width = 1), collapse = ","))
   else
'   value = Math.round(value);')
     
  for (j in seq_along(entries)) {
    newprefix <- prefixes[j]
    newprop <- properties[j]
    newget <- if (newprop == "userMatrix") ".getAsArray()" else ""
    newload <- if (newprop == "userMatrix") ".load(propvals)" else "= propvals"
    newid <- objids[j]
    multiplier <- ifelse(ncol>1, paste0(ncol, "*"), "")
    offset <-     ifelse(j>1,  paste0("+", j-1), "")
    result <- c(result,
    
    if (newprefix != prefix || newprop != property || newid != objid) subst(
'   %prefix%rgl.%property%[%objid%]%load%;
    propvals = %newprefix%rgl.%newprop%[%newid%]%newget%;', 
      prefix, property, objid, load, newget, newprefix, newprop, newid),
    
    if (interp) subst(
'       var v1 = values[%multiplier%(i-1)%offset%];
       var v2 = values[%multiplier%i%offset%];
       propvals[%entry%] = p*v1 + (1-p)*v2;', entry=entries[j], multiplier, offset)
     else subst(
'   propvals[%entry%] = values[%multiplier%value%offset%];', 
      entry=entries[j], multiplier, offset))
      
    prefix <- newprefix  
    property <- newprop
    objid <- newid
    get <- newget
    load <- newload
  }  
  result <- c(result, 
    if (interp)
'       break;
     }',
    subst(
'   %prefix%rgl.%property%[%objid%]%load%;', 
      prefix, property, objid, load))

  needsBinding <- unique(data.frame(prefixes, objids)[properties == "values",])
  for (i in seq_len(nrow(needsBinding))) {
    prefix <- needsBinding[i, 1]
    objid <- needsBinding[i, 2]
    result <- c(result, subst(
'   var gl = %prefix%rgl.gl; 
   gl.bindBuffer(gl.ARRAY_BUFFER, %prefix%rgl.buf[%objid%]);
   gl.bufferData(gl.ARRAY_BUFFER, %prefix%rgl.values[%objid%], gl.STATIC_DRAW);',
   	prefix, objid))
   }
   result <- c(result, subst(
'   %prefix%rgl.drawScene();
}', prefix))
  structure(paste(result, collapse = "\n"),
    env = environment(), class = "propertySetter")
}

par3dinterpSetter <- function(fn, from, to, steps, subscene = f0$subscene,
			      omitConstant = TRUE, ...) {
  times <- seq(from, to, length.out = steps+1)
  fvals <- lapply(times, fn)
  f0 <- fvals[[1]]
  entries <- numeric(0)
  properties <- character(0)
  values <- NULL
	
  props <- c("FOV", "userMatrix", "scale", "zoom")
  for(i in seq_along(props)) {
    prop <- props[i]
    if (!is.null(value <- f0[[prop]])) {
      newvals <- sapply(fvals, function(e) as.numeric(e[[prop]]))
      if (is.matrix(newvals)) newvals <- t(newvals)
      rows <- NROW(newvals)
      cols <- NCOL(newvals)
      stopifnot(rows == length(fvals))
      entries <- c(entries, seq_len(cols)-1)
      properties <- c(properties, rep(prop, cols))
      values <- cbind(values, newvals)
    }
  }
  if (omitConstant) keep <- apply(values, 2, var) > 0
  else keep <- TRUE 
	
  propertySetter(values = values[,keep], entries = entries[keep], 
		 properties = properties[keep], 
		 objids = subscene, param = times, ...)
}