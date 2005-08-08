#
# R 3d object : cube3d
#

cube3d.vb <- c(
  -1.0, -1.0, -1.0, 1.0,
   1.0, -1.0, -1.0, 1.0,
  -1.0,  1.0, -1.0, 1.0,
   1.0,  1.0, -1.0, 1.0,
  -1.0, -1.0,  1.0, 1.0,
   1.0, -1.0,  1.0, 1.0,
  -1.0,  1.0,  1.0, 1.0,
   1.0,  1.0,  1.0, 1.0
)

cube3d.ib <- c(
  1, 3, 4, 2,
  3, 7, 8, 4,
  2, 4, 8, 6,
  1, 5, 7, 3,
  1, 2, 6, 5,
  5, 6, 8, 7      
)
  
cube3d <- function( trans = identityMatrix(), ... ) {
  return( rotate3d( qmesh3d( cube3d.vb, cube3d.ib, material=list(...) ), matrix = trans) )
}  
