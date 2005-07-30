data(volcano)
surface3d( 10*1:nrow(volcano),10*1:ncol(volcano),5*volcano
 , texture=system.file("textures/refmap.png",package="rgl")
 , texenvmap=TRUE
)

