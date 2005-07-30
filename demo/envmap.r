# RGL-Demo: environment mapping
# Author: Daniel Adler
# $Id$

rgl.demo.envmap <- function()
{
  # Clear scene:
  clear3d()
  bg3d(sphere=T, color="white", back="filled"
  , texture=system.file("textures/refmap.png",package="rgl")
  )
  data(volcano)

  surface3d( 10*1:nrow(volcano),10*1:ncol(volcano),5*volcano
  , texture=system.file("textures/refmap.png",package="rgl")
  , texenvmap=TRUE
  )
}
rgl.demo.envmap()

