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

# 
# tetrahedron
#

tetra3d.vb <- c(
  -1.0, -1.0, -1.0, 1.0,
   1.0,  1.0, -1.0, 1.0,
   1.0, -1.0,  1.0, 1.0,
  -1.0,  1.0,  1.0, 1.0
)

tetra3d.ib <- c(
  1, 2, 3,
  3, 2, 4,
  4, 2, 1,
  1, 3, 4
)

tetrahedron3d <- function( trans = identityMatrix(), ... ) {
  return( rotate3d( tmesh3d( tetra3d.vb, tetra3d.ib, material=list(...) ), matrix = trans) )
}

# 
# octahedron
#

octa3d.vb <- c(
  -1.0,  0.0,  0.0, 1.0,
   1.0,  0.0,  0.0, 1.0,
   0.0, -1.0,  0.0, 1.0,
   0.0,  1.0,  0.0, 1.0,
   0.0,  0.0, -1.0, 1.0,
   0.0,  0.0,  1.0, 1.0
)

octa3d.ib <- c(
  1,5,3, 
  1,3,6, 
  1,4,5, 
  1,6,4, 
  2,3,5, 
  2,6,3, 
  2,5,4, 
  2,4,6
)

octahedron3d <- function( trans = identityMatrix(), ... ) {
  return( rotate3d( tmesh3d( octa3d.vb, octa3d.ib, material=list(...) ), matrix = trans) )
}

#
# icosahedron
#

phi <- (1+sqrt(5))/2
ico3d.vb <- c(
  0, 1/phi,  1, 1,        
  0, 1/phi, -1,	1,	
  0, -1/phi, 1,	1,	
  0, -1/phi,-1,	1,	
  1/phi,  1, 0,	1,	
  1/phi, -1, 0,	1,	
 -1/phi,  1, 0,	1,	
 -1/phi, -1, 0,	1,	
  1, 0,  1/phi,	1,	
 -1, 0,  1/phi,	1,	
  1, 0, -1/phi,	1,	
 -1, 0, -1/phi, 1   )		
 
 
 ico3d.ib <- c(
  1, 3, 9, 
  1, 9, 5,
  1, 5, 7,
  1, 7, 10,
  1, 10, 3,
  4, 12, 2,
  4, 2, 11,
  4, 11, 6,
  4, 6,  8,
  4, 8, 12,
  9, 3, 6,
  5, 9, 11,
  7, 5, 2,
  10, 7, 12,
  3, 10, 8,
  2, 12, 7,
  11, 2, 5,
  6, 11, 9,
  8, 6, 3,
  12, 8, 10)
  
icosahedron3d <- function( trans = identityMatrix(), ... ) {
    return( rotate3d( tmesh3d( ico3d.vb, ico3d.ib, material=list(...) ), matrix = trans) )
}

dodec3d.vb <- c(
  -1/phi, -1/phi, -1/phi, 1, 
   1/phi, -1/phi, -1/phi, 1, 
  -1/phi,  1/phi, -1/phi, 1, 
   1/phi,  1/phi, -1/phi, 1, 
  -1/phi, -1/phi,  1/phi, 1, 
   1/phi, -1/phi,  1/phi, 1, 
  -1/phi,  1/phi,  1/phi, 1, 
   1/phi,  1/phi,  1/phi, 1, 
   0, -1/phi^2, 1, 1,	     
   0,  1/phi^2, 1, 1,	     
   0, -1/phi^2,-1, 1,	     
   0,  1/phi^2,-1, 1,	     
   -1/phi^2, 1,	0, 1,	     
    1/phi^2, 1,	0, 1,	     
   -1/phi^2,-1,	0, 1,	     
    1/phi^2,-1,	0, 1,	     
    1, 0,-1/phi^2, 1,	     
    1, 0, 1/phi^2, 1,	     
   -1, 0,-1/phi^2, 1,	     
   -1, 0, 1/phi^2, 1	     
)		   

dodec3d.ib <- c(
  1, 11, 2, 16, 15, 
  1, 15, 5, 20, 19,
  1, 19, 3, 12, 11,
  2, 11, 12, 4, 17,
  2, 17, 18, 6, 16,
  3, 13, 14, 4, 12,
  3, 19, 20, 7, 13,
  4, 14, 8, 18, 17,
  5,  9, 10, 7, 20,
  5, 15, 16, 6,  9,
  6, 18,  8,10,  9,
  7, 10,  8,14, 13)
  
dodecahedron3d <- function( trans = identityMatrix(), ...) {
  m <- matrix(dodec3d.ib, 5, 12)
  return( rotate3d( tmesh3d( dodec3d.vb, c(m[c(1,2,3, 1,3,4, 1,4,5),]), material=list(...) ), matrix=trans) )
}
