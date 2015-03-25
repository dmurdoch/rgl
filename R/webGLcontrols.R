
# This displays an HTML5 input widget to show a subset of objects.  It assigns a random id
# and returns that invisibly.

subsetSlider <- function(subsets, labels = names(subsets), 
			    prefix = "", subscene = currentSubscene3d(), 
			    init = 1,
			    id = paste0(basename(tempfile("input"))), name = id,
			    fullset = Reduce(union, subsets)
			 ) {
	if (is.null(labels)) labels <- seq_along(subsets)
	cat(subst(
'<input type="range" min="0" max="%max%" step="1" value="%init%" id="%id%" name="%name%"
oninput = "(function(value) {
  var ids = [%vals%]; 
  var labels = [%labels%];
  var fullset = [%fullset%];
  var entries = %prefix%rgl.getSubsceneEntries(%subscene%);
  entries = entries.filter(function(x) { return fullset.indexOf(x) < 0 });
  entries = entries.concat(ids[value]);
  %prefix%rgl.setSubsceneEntries(entries, %subscene%); 
  document.getElementById(\'%id%text\').value = labels[value];
  %prefix%rgl.drawScene();
})(this.valueAsNumber)"></input><output id="%id%text">%label%</output>', 
    max = length(subsets)-1, init = init-1, name, id,
    vals = paste(paste0("[", sapply(subsets, 
    				function(i) paste(i, collapse=",")), 
    				"]"), collapse=","), prefix, subscene,
    labels = paste0("'", labels, "'", collapse=","),
    label = labels[init], fullset = paste(fullset, collapse=",")
	))
	invisible(id)
}

toggleButton <- function(subset, label = deparse(substitute(subset)), 
			 prefix = "", subscene = currentSubscene3d(), 
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

clipplaneSlider <- function(a=NULL, b=NULL, c=NULL, d=NULL, labels = signif(values[,1],3), 
			      clipplaneid, plane = 1, ...) {
  values <- cbind(a = a, b = b, c = c, d = d)
  col <- which(colnames(values) == letters[1:4]) - 1
  propertySlider(values, properties = "vClipplane",
  	         entries = 4*(plane-1) + col,
  	         labels = labels, objids = clipplaneid, ...)
}

propertySlider <- function(values, entries, properties, objids, prefixes = "",
                           slider = seq_len(NROW(values)),
                           minS = min(slider), maxS = max(slider), step = 1, init = minS, 
                           labels = signif(seq(minS, maxS, by = step), 2), 
                           id = paste0(basename(tempfile("input"))), name = id)  {
  values <- matrix(values, NROW(values))
  ncol <- ncol(values)
  stopifnot(length(entries) == ncol,
            all(diff(slider) > 0))
  prefixes <- rep(prefixes, length.out = ncol)
  properties <- rep(properties, length.out = ncol)
  objids <- rep(objids, length.out = ncol)
  prefix <- prefixes[1]
  property <- properties[1]
  objid <- objids[1]
  sliderVals <- seq(minS, maxS, by = step)
  interp <- length(slider) != length(sliderVals) || 
            any(slider != sliderVals)
  if (interp) values <- rbind(values[1,], values, values[nrow(values),])
  result <- c(subst(
'<script>%prefix%rgl.%id% = function(value){
   var values = [%vals%];', 
     prefix, id, vals = paste(as.vector(t(values)), collapse = ",")),
     
   if (interp) subst(
'   var svals = [-Infinity, %svals%, Infinity];',
     svals = paste(slider, collapse = ",")),
   
   subst(
'   var propvals = %prefix%rgl.%property%[%objid%];', 
     prefix, property, objid))
     
  for (j in seq_along(entries)) {
    newprefix <- prefixes[j]
    newprop <- properties[j]
    newid <- objids[j]
    multiplier <- ifelse(ncol>1, paste0(ncol, "*"), "")
    offset <-     ifelse(j>1,  paste0("+", j-1), "")
    result <- c(result,
    
    if (newprefix != prefix || newprop != property || newid != objid) subst(
'   %prefix%rgl.%property%[%objid%] = propvals;
    propvals = %newprefix%rgl.%newprop%[%newid%];', 
      prefix, property, objid, newprefix, newprop, newid),
    
    if (interp) subst(
'   for (var i = 1; i < svals.length; i++) 
     if (value <= svals[i]) {
       var v1 = values[%multiplier%(i-1)%offset%];
       var v2 = values[%multiplier%i%offset%];
       var p = (svals[i] - value)/(svals[i] - svals[i-1]);
       propvals[%entry%] = p*v1 + (1-p)*v2;
       break;
     }', entry=entries[j], multiplier, offset)
     else subst(
'   propvals[%entry%] = values[%multiplier%value%offset%];', 
      entry=entries[j], multiplier, offset))
      
    prefix <- newprefix  
    property <- newprop
    objid <- newid
  }  
  result <- c(result, subst(
'   %prefix%rgl.%property%[%objid%] = propvals;', prefix, property, objid))

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
'   var labels = [%labels%];
   document.getElementById(\'%id%text\').value = labels[value];
   %prefix%rgl.drawScene();
}</script><input type="range" min="%minS%" max="%maxS%" step="%step%" value="%init%" id="%id%" name="%name%"
oninput = "%prefix%rgl.%id%(this.valueAsNumber)"></input><output id="%id%text">%label%</output>', 
    minS, maxS, step, init, id, name,
    labels = paste0("'", labels, "'", collapse=","), prefix, property, objid,
    label = labels[init]))
  cat(result, sep="\n")
  invisible(id)
}
