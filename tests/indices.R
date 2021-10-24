library(rgl)
tet <- tetrahedron3d()

open3d()
segments3d(t(tet$vb[1:3,]), indices = c(1,2,1,3,1,4,2,3,2,4,3,4))

open3d()
text3d(t(tet$vb[1:3,]), text=1:4)
triangles3d(t(tet$vb[1:3,]), indices = c(1,2,3,1,4,2,1,3,4,2,4,3),
            col = "red")