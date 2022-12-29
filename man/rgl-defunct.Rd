\name{rgl-defunct}
\alias{rgl-defunct}
\alias{subsetSlider}
\alias{subsetSetter}
\alias{clipplaneSlider}
\alias{toggleButton}
\alias{propertySlider}
\alias{propertySetter}
\alias{par3dinterpSetter}
\alias{matrixSetter}
\alias{vertexSetter}
\title{
Defunct functions in \pkg{rgl}
}
\description{
These functions have been removed from \pkg{rgl}.
}
\usage{
# Removed in version 1.0.0:

subsetSlider(subsets, labels = names(subsets), 
             fullset = Reduce(union, subsets),
             subscenes = currentSubscene3d(), prefixes = "",
             accumulate = FALSE, ...)
             
subsetSetter(subsets, subscenes = currentSubscene3d(), prefixes = "", 
			 fullset = Reduce(union, subsets),
                         accumulate = FALSE)
             
clipplaneSlider(a=NULL, b=NULL, c=NULL, d=NULL, 
                plane = 1, clipplaneids, prefixes = "", 
                labels = signif(values[,1],3), ...)
             
toggleButton(subset, subscenes = currentSubscene3d(), prefixes = "", 
             label = deparse(substitute(subset)), 
             id = paste0(basename(tempfile("input"))), name = id) 
propertySlider(setter = propertySetter,
             minS = NULL, maxS = NULL, step = 1, init = NULL, 
	     labels, 
	     id = basename(tempfile("input")), name = id,
	     outputid = paste0(id, "text"),
	     index = NULL,
	     ...) 
	     
propertySetter(values = NULL, entries, properties, objids, prefixes = "",
               param = seq_len(NROW(values)), interp = TRUE, digits = 7) 
               
par3dinterpSetter(fn, from, to, steps, subscene, omitConstant = TRUE, 
                  rename = character(), ...)

matrixSetter(fns, from, to, steps, subscene = currentSubscene3d(), 
             matrix = "userMatrix", omitConstant = TRUE, prefix = "", ...) 
             
vertexSetter(values, vertices = 1, attributes, objid, prefix = "",
	     param = seq_len(NROW(values)), interp = TRUE,
	     digits = 7)             
}
\seealso{
  \code{\link{Defunct}}
}
\keyword{internal}
\keyword{misc}