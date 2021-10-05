library(rgl)

# WORKING

x <- cube3d()
b <- getBoundary3d(x)
open3d(); shade3d(b)


x <- cube3d()
x$ib <- x$ib[,-(1:2)]
b <- getBoundary3d(x)
open3d(); shade3d(x, alpha=0.2, col = "blue"); shade3d(b) 

x <- cube3d()
x$ib <- x$ib[,-(1:2)]
b <- getBoundary3d(x, sorted = TRUE, simplify = FALSE)
open3d(); shade3d(x, alpha=0.2, col = "blue"); shade3d(b) 
