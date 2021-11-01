library(rgl)
tet <- tetrahedron3d()

open3d()
segments3d(t(tet$vb[1:3,]), indices = c(1,2,1,3,1,4,2,3,2,4,3,4))

open3d()
text3d(t(tet$vb[1:3,]), text=1:4)
triangles3d(t(tet$vb[1:3,]), indices = c(1,2,3,1,4,2,1,3,4,2,4,3),
            col = "red")

# This displayed a triangle for the red quad (issue #154)

quad <- cbind(x = c(-1, 1, 1, -1),
              y = c( 0, 0, 0, 0),
              z = c(-1, -1, 1, 1))/2
open3d()
triangles3d(quad, alpha = 0.5, col = "red", indices=c(1,2,3,1,3,4))
triangles3d(quad+1, col = "blue", indices=c(1,2,3,1,3,4))
