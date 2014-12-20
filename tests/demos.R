library(rgl)

# regression :  this failed for headless tests
par3d(userMatrix = diag(4))

for(demo in demo(package="rgl")$results[,"Item"]) 
  if (!(demo %in% c("rgl", "lsystem")))
    demo(demo, package="rgl", character.only=TRUE)
