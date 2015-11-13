
# This displays an HTML5 input widget to show a subset of objects.  It assigns a random id
# and returns that invisibly.

subsetSlider <- function(subsets, labels = names(subsets),
                         fullset = Reduce(union, subsets), 
                         subscenes = currentSubscene3d(), prefixes = "", 
                         accumulate = FALSE, ...) {
  propertySlider(subsetSetter(subsets, fullset = fullset,
                              subscenes = subscenes, prefixes = prefixes,
                              accumulate = accumulate),
                 labels = labels, ...)
}

subsetSetter <- function(subsets, subscenes = currentSubscene3d(), prefixes = "",  
			 fullset = Reduce(union, subsets),
			 accumulate = FALSE) {
  rglwidgetCheck()
  rglwidget::.subsetSetter(subsets, subscenes, prefixes, fullset, accumulate)
}

toggleButton <- function(subset, subscenes = currentSubscene3d(), prefixes = "", 
			 label = deparse(substitute(subset)), 
			 id = paste0(basename(tempfile("input"))), name = id) {
  rglwidgetCheck()
  nsubs <- max(length(subscenes), length(prefixes))
  subscenes <- rep(subscenes, length.out = nsubs)
  prefixes <- rep(prefixes, length.out = nsubs)
  result <- subst(
'<button type="button" id="%id%" name="%name%" onclick = "(function(){
  var subset = [%subset%], i;',
    name, id, subset = paste(subset, collapse=","))
  for (i in seq_len(nsubs)) 
    result <- c(result, subst(
'  if (%prefix%rgl.inSubscene(subset[0], %subscene%)) {
    for (i=0; i<subset.length; i++)
      %prefix%rgl.delFromSubscene(subset[i], %subscene%);
  } else {
    for (i=0; i<subset.length; i++)
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
                           minS = NULL, maxS = NULL, step = 1, init = minS, 
                           labels, 
                           id = basename(tempfile("input")), name = id,
			   outputid = paste0(id, "text"),
			   index = NULL,
                           ...)  {
  rglwidgetCheck()
  rglwidget::.propertySlider(setter, minS, maxS, step, init, labels, id, name, outputid,
  			     index, ...)
}

propertySetter <- function(values = NULL, entries, properties, objids, prefixes = "",
                           param = seq_len(NROW(values)), interp = TRUE,
			   digits = 7)  {
  rglwidgetCheck()
  rglwidget::.propertySetter(values, entries, properties, objids, prefixes,
  			     param, interp, digits)
}

vertexSetter <- function(values = NULL, vertices = 1, attributes, objid, prefix = "",
			 param = seq_len(NROW(values)), interp = TRUE,
			 digits = 7)  {
  rglwidgetCheck()
  rglwidget::.vertexSetter(values, vertices, attributes, objid, prefix, param, interp,
  			   digits)
}


par3dinterpSetter <- function(fn, from, to, steps, subscene = NULL,
			      omitConstant = TRUE, rename = character(), ...) {
  rglwidgetCheck()
  rglwidget::.par3dinterpSetter(fn, from, to, steps, subscene,
  			        omitConstant, rename, ...)
}

matrixSetter <- function(fns, from, to, steps, subscene = currentSubscene3d(), matrix = "userMatrix",
			omitConstant = TRUE, prefix = "", ...) {
  n <- length(fns)
  from <- rep(from, length.out = n)
  to <- rep(to, length.out = n)
  steps <- rep(steps, length.out = n)
  settername <- basename(tempfile("fn", ""))
  propname <- paste0("userMatrix", settername) # Needs to match "^userMatrix" regexp
  param <- numeric()
  prefixes <- character()
  result <- subst(
'%prefix%rgl.%settername% = function(value, index){
     var fns = new Array();', prefix, settername)
  product <- ''
  for (i in seq_len(n)) {
    setter <- par3dinterpSetter(fns[[i]], from[i], to[i], steps[i],
    			        omitConstant = TRUE, subscene = i-1, prefixes = prefix,
    			        rename = c(userMatrix = propname), ...)
    result <- c(result, subst(
'     fns[%i%] = ', i=i-1), setter)
    param <- c(param, attr(setter, "param"))
  }
  result <- c(result, 
'   fns[index](value);
   var newmatrix = new CanvasMatrix4();',
    paste0(subst(
'   newmatrix.multLeft(%prefix%rgl.%propname%[', prefix, propname), 0:(n-1), ']);'),
    subst(
'   %prefix%rgl.%matrix%[%subscene%].load(newmatrix);
 }
 %prefix%rgl.%propname% = new Array();', prefix, subscene, propname, matrix),
    paste0(subst(
' %prefix%rgl.%propname%[', prefix, propname), 0:(n-1), '] = new CanvasMatrix4();'))
  structure(paste(result, collapse="\n"),
  	    param = sort(unique(param)),
  	    prefixes = prefix,
  	    name = subst('%prefix%rgl.%settername%', prefix, settername),
  	    class = c("matrixSetter", "indexedSetter", "propertySetter"))
}

print.indexedSetter <- function(x, inScript = FALSE, ...) {
  if (!inScript) cat("<script>\n")
  cat(x)
  if (!inScript) cat("\n</script>")
}

ageSetter <- function(births, ages, colors = NULL, alpha = NULL, 
		      radii = NULL, vertices = NULL, normals = NULL, 
		      origins = NULL, texcoords = NULL, objids, prefixes = "",
		      digits = 7, param = seq(floor(min(births)), ceiling(max(births))))  {
  rglwidgetCheck()
  rglwidget::.ageSetter(births, ages, colors, alpha, radii, vertices, normals, 
  		      origins, texcoords, objids, prefixes, digits, param)
}
