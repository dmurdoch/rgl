#
# R 3d object : cube3d
#

cube3d.vb <- c(
  -1.0, -1.0, -1.0,
   1.0, -1.0, -1.0,
  -1.0,  1.0, -1.0,
   1.0,  1.0, -1.0,
  -1.0, -1.0,  1.0,
   1.0, -1.0,  1.0,
  -1.0,  1.0,  1.0,
   1.0,  1.0,  1.0
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
  rotate3d( mesh3d( vertices = cube3d.vb, quads = cube3d.ib, material=.fixMaterialArgs2(...) ), matrix = trans)
}  

# 
# tetrahedron
#

tetra3d.vb <- c(
  -1.0, -1.0, -1.0,
   1.0,  1.0, -1.0,
   1.0, -1.0,  1.0,
  -1.0,  1.0,  1.0
)

tetra3d.it <- c(
  1, 2, 3,
  3, 2, 4,
  4, 2, 1,
  1, 3, 4
)

tetrahedron3d <- function( trans = identityMatrix(), ... ) {
  rotate3d( mesh3d(vertices = tetra3d.vb, triangles = tetra3d.it, material=.fixMaterialArgs2(...) ), matrix = trans)
}

# 
# octahedron
#

octa3d.vb <- c(
  -1.0,  0.0,  0.0,
   1.0,  0.0,  0.0,
   0.0, -1.0,  0.0,
   0.0,  1.0,  0.0,
   0.0,  0.0, -1.0,
   0.0,  0.0,  1.0
)

octa3d.it <- c(
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
  rotate3d( mesh3d( vertices = octa3d.vb, triangles = octa3d.it, material=.fixMaterialArgs2(...) ), matrix = trans)
}

#
# icosahedron
#

phi <- (1+sqrt(5))/2
ico3d.vb <- c(
  0, 1/phi,  1,       
  0, 1/phi, -1,	
  0, -1/phi, 1,	
  0, -1/phi,-1,	
  1/phi,  1, 0,	
  1/phi, -1, 0,	
 -1/phi,  1, 0,
 -1/phi, -1, 0,	
  1, 0,  1/phi,	
 -1, 0,  1/phi,	
  1, 0, -1/phi,	
 -1, 0, -1/phi   
 )		

 ico3d.it <- c(
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
    rotate3d( mesh3d( vertices = ico3d.vb, triangles = ico3d.it, material=.fixMaterialArgs2(...) ), matrix = trans)
}

dodec3d.vb <- c(
  -1/phi, -1/phi, -1/phi, 
   1/phi, -1/phi, -1/phi, 
  -1/phi,  1/phi, -1/phi, 
   1/phi,  1/phi, -1/phi, 
  -1/phi, -1/phi,  1/phi, 
   1/phi, -1/phi,  1/phi, 
  -1/phi,  1/phi,  1/phi, 
   1/phi,  1/phi,  1/phi, 
   0, -1/phi^2, 1,     
   0,  1/phi^2, 1,	     
   0, -1/phi^2,-1,	     
   0,  1/phi^2,-1,	     
   -1/phi^2, 1,	0,     
    1/phi^2, 1,	0,   
   -1/phi^2,-1,	0,    
    1/phi^2,-1,	0,
    1, 0,-1/phi^2,    
    1, 0, 1/phi^2,	     
   -1, 0,-1/phi^2,     
   -1, 0, 1/phi^2     
)		   

dodec3d.if <- c(
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
  m <- matrix(dodec3d.if, 5, 12)
  rotate3d( mesh3d( vertices = dodec3d.vb, triangles = c(m[c(1,2,3, 1,3,4, 1,4,5),]), material=.fixMaterialArgs2(...) ), matrix=trans)
}

cuboct3d.vb <- c(
 -1, -1, 0,
 -1,  1, 0,
  1, -1, 0,
  1,  1, 0,
 -1,  0,-1,
 -1,  0, 1,
  1,  0,-1,
  1,  0, 1,
  0, -1,-1,
  0, -1, 1,
  0,  1,-1,
  0,  1, 1
)
  
cuboct3d.ib <- c(
  1, 6, 2, 5,
  1, 9, 3, 10,
  2, 12,4, 11,
  3, 7, 4, 8,
  5, 11, 7, 9,
  6, 10, 8, 12)
  
cuboct3d.it <- c(
  1, 5, 9,
  1, 10, 6,
  2, 11, 5,
  2, 6, 12,
  3, 9, 7,
  3, 8, 10,
  4, 7, 11,
  4, 12, 8)
  
cuboctahedron3d <- function( trans = identityMatrix(), ...) {
  rotate3d( mesh3d( vertices = cuboct3d.vb, triangles = cuboct3d.it, quads = cuboct3d.ib, material=.fixMaterialArgs2(...) ), matrix = trans)
}  
