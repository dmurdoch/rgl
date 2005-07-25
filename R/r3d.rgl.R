#
# R3D rendering functions - rgl implementation
# $Id: r3d.rgl.R,v 1.3 2005/02/08 23:36:55 dadler Exp $
# 

dev3d <- "rgl"

# scene management - RGL implementation

clear3d.rgl <- function( type ) 
  rgl.clear( type )
pop3d.rgl <- function( type ) 
  rgl.pop( type )
bg3d.rgl <- function( color, ... ) 
  rgl.bg( color=color, ... )
light3d.rgl <- function( theta, phi, ... ) 
  rgl.light( theta=theta, phi=phi, ... )

# primitive shape implementation

points3d.rgl <- function ( x, y, z, ... ) 
  rgl.points( x, y, z, ... )
lines3d.rgl <- function ( x, y, z, ... ) 
  rgl.linestrips( x, y, z, ... )
segments3d.rgl <- function ( x, y, z, ... ) 
  rgl.lines( x, y, z, ... )
triangles3d.rgl <- function ( x, y, z, ... ) 
  rgl.triangles( x, y, z, ... )
quads3d.rgl <- function( x, y, z, ... ) 
  rgl.quads(x, y, z, ... )
text3d.rgl <- function( x, y, z, texts, adj, ... ) 
  rgl.texts( x, y, z, texts, adj, ... ) 

# high-level shape implementation

spheres3d.rgl <- function( x, y, z, radius, ...) 
  rgl.spheres( x, y, z, radius, ...)
sprites3d.rgl <- function ( x, y, z, radius, ...) 
  rgl.sprites( x, y, z, radius, ... )
terrain3d.rgl <- function ( x, y, z, ...) 
  rgl.surfaces( x, z, y, ... )  

# interaction implementation

select3d.rgl <- function() 
  rgl.select3d() 


