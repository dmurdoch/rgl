library(rgl)

material3d("tag")
material3d(tag = "hello")
material3d("tag")

material3d("texture")
material3d(texture = system.file("textures/worldsmall.png", package = "rgl"))
material3d("texture")
material3d("tag")

x <- points3d(1,2,3, tag = "hello2")

ids3d()
