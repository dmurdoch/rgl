
# This displays an HTML5 input widget to show a subset of objects.  It assigns a random id
# and returns that invisibly.

subsetSlider <- function(subsets, labels = names(subsets),
                         fullset = Reduce(union, subsets), 
                         subscenes = currentSubscene3d(), prefixes = "", 
                         accumulate = FALSE, ...) {
  .Defunct("subsetControl")
}

subsetSetter <- function(subsets, subscenes = currentSubscene3d(), prefixes = "",
			 fullset = Reduce(union, subsets),
			 accumulate = FALSE) {
  .Defunct("subsetControl")
}

toggleButton <- function(subset, subscenes = currentSubscene3d(), prefixes = "",
			 label = deparse(substitute(subset)),
			 id = paste0(basename(tempfile("input"))), name = id) {
  .Defunct("toggleWidget")
}

clipplaneSlider <- function(a=NULL, b=NULL, c=NULL, d=NULL,
			    plane = 1, clipplaneids, prefixes = "",
			    labels,
			      ...) {
  .Defunct("clipplaneControl")
}

propertySlider <- function(setter = propertySetter,
                           minS = NULL, maxS = NULL, step = 1, init = NULL,
                           labels,
                           id = basename(tempfile("input")), name = id,
			   outputid = paste0(id, "text"),
			   index = NULL,
                           ...)  {
  .Defunct("propertyControl")
}

propertySetter <- function(values = NULL, entries, properties, objids, prefixes = "",
                           param = seq_len(NROW(values)), interp = TRUE,
			   digits = 7)  {
  .Defunct("propertyControl")
}

vertexSetter <- function(values = NULL, vertices = 1, attributes, objid, prefix = "",
			 param = seq_len(NROW(values)), interp = TRUE,
			 digits = 7)  {
  .Defunct("vertexControl")
}


par3dinterpSetter <- function(fn, from, to, steps, subscene = NULL,
			      omitConstant = TRUE, rename = character(), ...) {
  .Defunct("par3dinterpControl")
}

matrixSetter <- function(fns, from, to, steps, subscene = currentSubscene3d(), matrix = "userMatrix",
			omitConstant = TRUE, prefix = "", ...) {
  .Defunct("par3dinterpControl")
}

ageSetter <- function(births, ages, colors = NULL, alpha = NULL,
		      radii = NULL, vertices = NULL, normals = NULL,
		      origins = NULL, texcoords = NULL, objids, prefixes = "",
		      digits = 7, param = seq(floor(min(births)), ceiling(max(births))))  {
  .Defunct("ageControl")
}
