# tests of sprite and text code

library(rgl)

xyz <- cbind(1:2, 1:2, 1:2)

open3d()

text3d(xyz - 1, texts = c("A", "B"), col = "black")

sprites3d( xyz, color = "red" , lit=FALSE, 
           texture=system.file("textures/particle.png", 
                               package="rgl"),textype="alpha")
text3d(xyz + 1, texts = c("C", "D"), col = "blue")
