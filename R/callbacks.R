rgl.setMouseCallbacks <- function(button, begin=NULL, update=NULL, end=NULL) {
    invisible(.Call(rgl_setMouseCallbacks, as.integer(button), begin, update, end))
}

