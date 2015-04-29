
# This displays an HTML5 input widget to show a subset of objects.  It assigns a random id
# and returns that invisibly.

subsetSlider <- function(subsets, labels = names(subsets),
                         fullset = Reduce(union, subsets), 
                         subscenes = currentSubscene3d(), prefixes = "", ...) {
  propertySlider(subsetSetter(subsets, fullset = fullset,
                              subscenes = subscenes, prefixes = prefixes),
                 labels = labels, ...)
}

subsetSetter <- function(subsets, subscenes = currentSubscene3d(), prefixes = "",  
			 fullset = Reduce(union, subsets)) {
  nsubs <- max(length(subscenes), length(prefixes))
  subscenes <- rep(subscenes, length.out = nsubs)
  prefixes <- rep(prefixes, length.out = nsubs)
  result <- subst(
'function(value) {
  var ids = [%vals%]; 
  var fullset = [%fullset%];
  var f = function(x) { return fullset.indexOf(x) < 0 };
  value = Math.round(value);', 
    vals = paste(paste0("[", sapply(subsets, 
        				function(i) paste(i, collapse=",")), 
        				"]"), collapse=","), 
    fullset = paste(fullset, collapse=","))
  for (i in seq_len(nsubs)) 
    result <- c(result, subst(
'  var entries = %prefix%rgl.getSubsceneEntries(%subscene%);
  entries = entries.filter(f);
  entries = entries.concat(ids[value]);
  %prefix%rgl.setSubsceneEntries(entries, %subscene%);',
      prefix = prefixes[i], subscene = subscenes[i]))
  result <- c(result, '}')
    
  structure(paste(result, collapse = "\n"),
    param = seq_along(subsets) - 1, 
    prefixes = prefixes, class = "propertySetter")     
}

toggleButton <- function(subset, subscenes = currentSubscene3d(), prefixes = "", 
			 label = deparse(substitute(subset)), 
			 id = paste0(basename(tempfile("input"))), name = id) {
  nsubs <- max(length(subscenes), length(prefixes))
  subscenes <- rep(subscenes, length.out = nsubs)
  prefixes <- rep(prefixes, length.out = nsubs)
  result <- subst(
'<button type="button" id="%id%" name="%name%" onclick = "(function(){
  var subset = [%subset%];',
    name, id, subset = paste(subset, collapse=","))
  for (i in seq_len(nsubs)) 
    result <- c(result, subst(
'  if (%prefix%rgl.inSubscene(subset[0], %subscene%)) {
    for (var i=0; i<subset.length; i++)
      %prefix%rgl.delFromSubscene(subset[i], %subscene%);
  } else {
    for (var i=0; i<subset.length; i++)
      %prefix%rgl.addToSubscene(subset[i], %subscene%);
  }', prefix = prefixes[i], subscene = subscenes[i]))
  prefixes <- unique(prefixes)
  for (i in seq_along(prefixes))
    result <- c(result, subst(
'  %prefix%rgl.drawScene();', prefix = prefixes[i]))
  result <- c(result, subst(
'})()">%label%</button>', label)) 
  cat(result, sep = "\n")
  invisible(id)
}

clipplaneSlider <- function(a=NULL, b=NULL, c=NULL, d=NULL, 
			    plane = 1, clipplaneids, prefixes = "", 
			    labels = signif(values[,1],3), 
			      ...) {
  values <- cbind(a = a, b = b, c = c, d = d)
  col <- which(colnames(values) == letters[1:4]) - 1
  propertySlider(values = values, entries = 4*(plane-1) + col,
  	         properties = "vClipplane", objids = clipplaneids, 
  	         prefixes = prefixes, labels = labels, ...)
}

propertySlider <- function(setter = propertySetter,
                           minS = min(param), maxS = max(param), step = 1, init = minS, 
                           labels = displayVals(sliderVals), 
                           id = basename(tempfile("input")), name = id,
			   outputid = paste0(id, "text"),
                           ...)  {
  displayVals <- function(x) {
    base <- signif(mean(x), 2)
    base + signif(x - base, 2)
  }
  if (!is.list(setter)) setters <- list(setter)
  else setters <- setter
  param <- numeric()
  prefixes <- character()
  for (i in seq_along(setters)) {
    setter <- setters[[i]]
    if (is.function(setter))
      setters[i] <- setter <- setter(...)
    if (!inherits(setter, "propertySetter"))
    stop(dQuote(setter), " must be a propertySetter object.")
    
    param <- c(param, attr(setter, "param"))
    prefixes <- c(prefixes, attr(setter, "prefixes"))
  }
  prefix <- prefixes[1]
  
  sliderVals <- seq(minS, maxS, by = step)
  if (is.null(outputid)) outputfield <- setoutput <- "" 
  else {
    outputfield <- subst('<output id="%outputid%" for="%id%">%label%</output>', 
  			  outputid, id, label = labels[round(init-minS)/step + 1])
    setoutput <- subst('
  label = document.getElementById(\'%outputid%\');
  if (label !== null) label.value = labels[lvalue];', outputid)
  }
  result <- subst(
'<script>%prefix%rgl.%id% = function(value){', prefix, id)
  for (i in seq_along(setters))
    result <- c(result, subst(
'   (%setter%)(value);', setter = setters[i]))
  for (p in unique(prefixes))
    result <- c(result, subst(
'   %prefix%rgl.drawScene();', prefix = p))
  result <- c(result, subst(
'   var lvalue = Math.round((value - %minS%)/%step%);
   var labels = [%labels%]; %setoutput%
}
%prefix%rgl.%id%(%init%);</script>
<input type="range" min="%minS%" max="%maxS%" step="%step%" value="%init%" id="%id%" name="%name%"
oninput = "%prefix%rgl.%id%(this.valueAsNumber)">%outputfield%', 
    prefix, id, setoutput, outputfield,
    minS, maxS, step, init, name,
    labels = paste0("'", labels, "'", collapse=",")))
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
   result <- c(result, '}')
  structure(paste(result, collapse = "\n"),
    param = param, prefixes = prefixes,
    class = "propertySetter")
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

ageSetter <- function(births, ages, colors = NULL, alpha = NULL, 
		      radii = NULL, vertices = NULL, normals = NULL, 
		      origins = NULL, texcoords = NULL, objids, prefixes = "",
		      digits = 7, param = seq(floor(min(births)), ceiling(max(births))))  {
  formatVec <- function(vec) {
    vec <- t(vec)
    result <- formatC(vec, digits = digits, width = 1)
    result[vec == Inf] <- "Infinity"
    result[vec == -Inf] <- "-Infinity"
    paste(result, collapse = ",")
  }
  if (!is.null(colors)) colors <- t(col2rgb(colors))/255
  lengths <- c(colors = NROW(colors), alpha = length(alpha), 
  	       radii = length(radii), vertices = NROW(vertices),
  	       normals = NROW(normals), origins = NROW(origins),
  	       texcoords = NROW(texcoords))
  lengths <- lengths[lengths > 0]
  attribs <- names(lengths)
  n <- unique(lengths)
  stopifnot(length(n) == 1, n == length(ages), all(diff(ages) >= 0))
  nobjs <- max(length(objids), length(prefixes))
  prefixes <- rep(prefixes, length.out = nobjs)
  objids <- rep(objids, length.out = nobjs)
  result <- subst(
'  function(time){
    var ages = [-Infinity, %ages%, Infinity];
    var births = [%births%];
    var j = new Array(births.length);
    var p = new Array(births.length);',
    ages = formatVec(ages), births = formatVec(births))
  rows <- c(1,1:n, n)
  if ("colors" %in% attribs) 
    result <- c(result, subst(
'    var colors = [%values%];', values = formatVec(colors[rows,])))
  if ("alpha" %in% attribs)
    result <- c(result, subst(
'    var alpha = [%values%];', values = formatVec(alpha[rows])))
  if ("radii" %in% attribs)
    result <- c(result, subst(
'    var radii = [%values%];', values = formatVec(radii[rows])))
  if ("vertices" %in% attribs) {
    stopifnot(ncol(vertices) == 3)
    result <- c(result, subst(
'    var vertices = [%values%];', values = formatVec(vertices[rows,])))
  }
  if ("normals" %in% attribs) {
    stopifnot(ncol(normals) == 3)
    result <- c(result, subst(
'    var normals = [%values%];', values = formatVec(normals[rows,])))
  }
  if ("origins" %in% attribs) {
    stopifnot(ncol(origins) == 2)
    result <- c(result, subst(
'    var origins = [%values%];', values = formatVec(origins[rows,])))
  }  
  if ("texcoords" %in% attribs) {
    stopifnot(ncol(texcoords) == 2)
    result <- c(result, subst(
'    var texcoords = [%values%];', values = formatVec(texcoords[rows,])))
  }
  result <- c(result,
'    for (var i = 0; i < births.length; i++) {
      var age = time - births[i];
      for (var j0 = 1; age > ages[j0]; j0++);
      if (ages[j0] == Infinity)
        p[i] = 1;       
      else if (ages[j0] > ages[j0-1])
        p[i] = (ages[j0] - age)/(ages[j0] - ages[j0-1]);
      else
        p[i] = 0;
      j[i] = j0;
    }')
  for (j in seq_len(nobjs)) {
    prefix <- prefixes[j]
    objid <- objids[j]
    result <- c(result, subst(
'    var propvals = %prefix%rgl.values[%objid%];
    var stride = %prefix%rgl.offsets[%objid%]["stride"];',
      prefix, objid))
    for (a in attribs) {
      ofs <- c(colors = "cofs", alpha = "cofs", radii = "radofs",
      	       vertices = "vofs", normals = "nofs", origins = "oofs",
      	       texcoords = "tofs")[a]
      result <- c(result, subst(
'    var ofs = %prefix%rgl.offsets[%objid%]["%ofs%"];
    if (ofs >= 0) {
      for (var i = 0; i < births.length; i++) {', 
        prefix, objid, ofs))
      dim <- c(colors = 3, alpha = 1, radii = 1,
      	 vertices = 3, normals = 3, origins = 2,
      	 texcoords = 2)[a] 
      if (dim > 1)
        for (d in seq_len(dim) - 1)
      	  result <- c(result, subst(
'        propvals[i*stride + ofs + %d1%] = p[i]*%a%[%dim%*(j[i]-1) + %d2%] + (1-p[i])*%a%[%dim%*j[i] + %d2%];',
          dim, d1 = if (a == "alpha") 3 else d, d2 = d, a))
      else
      	result <- c(result, subst(
'        propvals[i*stride + ofs%alphaofs%] = p[i]*%a%[j[i]-1] + (1-p[i])*%a%[j[i]];',
      		a, alphaofs = if (a == "alpha") " + 3" else ""))
      result <- c(result, subst(
'      }
    } else 
        alert("\'%a%\' property not found in object %objid%");', a, objid))
    }
    result <- c(result, subst(
'    %prefix%rgl.values[%objid%] = propvals;
    if (typeof %prefix%rgl.buf[%objid%] !== "undefined") {
      var gl = %prefix%rgl.gl;
      gl.bindBuffer(gl.ARRAY_BUFFER, %prefix%rgl.buf[%objid%]);
      gl.bufferData(gl.ARRAY_BUFFER, %prefix%rgl.values[%objid%], gl.STATIC_DRAW);
    }',
      prefix, objid))
  }
  result <- c(result, '  }')
  structure(paste(result, collapse = "\n"),
            param = param, prefixes = prefixes,
  	    class = "propertySetter")
}
