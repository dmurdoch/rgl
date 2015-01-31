rgl.setMouseCallbacks <- function(button, begin=NULL, update=NULL, end=NULL) {
    invisible(.Call(rgl_setMouseCallbacks, as.integer(button), begin, update, end))
}

rgl.getMouseCallbacks <- function(button) 
    .Call(rgl_getMouseCallbacks, as.integer(button))

rgl.setWheelCallback <- function(rotate=NULL) {
    invisible(.Call(rgl_setWheelCallback, rotate))
}

rgl.getWheelCallback <- function() 
    .Call(rgl_getWheelCallback)
