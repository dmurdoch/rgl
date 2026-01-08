rgl.setMouseCallbacks <- function(button, begin=NULL, update=NULL, end=NULL, dev = cur3d(), subscene = currentSubscene3d(dev)) {
    invisible(.Call(rgl_setMouseCallbacks, as.integer(button), begin, update, end, 
                    as.integer(dev), as.integer(subscene)))
}

rgl.getMouseCallbacks <- function(button, dev = cur3d(), subscene = currentSubscene3d(dev)) 
    .Call(rgl_getMouseCallbacks, as.integer(button), as.integer(dev), as.integer(subscene))

rgl.setWheelCallback <- function(rotate=NULL, dev = cur3d(), subscene = currentSubscene3d(dev)) {
    invisible(.Call(rgl_setWheelCallback, rotate, as.integer(dev), as.integer(subscene)))
}

rgl.getWheelCallback <- function(dev = cur3d(), subscene = currentSubscene3d(dev)) 
    .Call(rgl_getWheelCallback, as.integer(dev), as.integer(subscene))

rgl.setAxisCallback <- function(axis, draw = NULL, dev = cur3d(), subscene = currentSubscene3d(dev)) {
  
  .Defunct("setAxisCallbacks")
  
}

rgl.getAxisCallback <- function(axis, dev = cur3d(), subscene = currentSubscene3d(dev)) {
  .Call(rgl_getAxisCallback, as.integer(dev), as.integer(subscene), as.integer(axis - 1))
}
