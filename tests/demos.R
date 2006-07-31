library(rgl)

for(demo in demo(package="rgl")$results[,"Item"]) 
  demo(demo, package="rgl", character.only=TRUE)
