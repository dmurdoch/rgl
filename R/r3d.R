#
# Generic 3D interface for R
# $Id: r3d.R,v 1.3 2004/09/06 21:08:34 murdoch Exp $
#

# ===[ GENERIC RENDERING FUNCTIONS ]==========================================

# scene management

clear3d <- function ( type="shapes" ) 
  do.call(paste("clear3d", dev3d, sep="."),list(type=type) )
pop3d <- function ( type="shapes" ) 
  do.call(paste("pop3d", dev3d, sep="."), list(type=type) )
bg3d <- function ( color, ... ) 
  do.call(paste("bg3d",dev3d, sep="."), list(color=color, ...) )
light3d <- function ( x, ... ) 
  do.call(paste("light3d",dev3d, sep="."), list(x,...) )

# primitive shapes
  
points3d <- function ( x, y, z, ... ) 
  do.call(paste("points3d", dev3d, sep="."),list(x,y,z,...) )
lines3d <- function ( x, y, z, ... ) 
  do.call( paste("lines3d", dev3d, sep="."),list(x,y,z,...) )
segments3d <- function( x, y, z, ... ) 
  do.call( paste("segments3d", dev3d, sep="."),list(x,y,z,...) )
triangles3d <- function( x, y, z, ... ) 
  do.call( paste("triangles3d", dev3d, sep="."),list(x,y,z,...) ) 
quads3d <- function( x, y, z, ... ) 
  do.call( paste("quads3d", dev3d, sep="."),list(x,y,z,...) )  
text3d <- function( x, y, z, text, adj=0.5, ... ) 
  do.call( paste("text3d", dev3d, sep="."),list(x,y,z,text,adj=adj,...) )  

# high-level shapes

spheres3d <- function ( x, y, z, radius, ... ) 
  do.call( paste("spheres3d",dev3d, sep="."),list(x,y,z,radius,...) )
sprites3d <- function ( x, y, z, radius, ... ) 
  do.call( paste("sprites3d",dev3d, sep="."),list(x,y,z,radius,...) )
terrain3d <- function ( x, y, z, ... ) 
  do.call( paste("terrain3d",dev3d, sep="."),list(x,y,z,...) )

# interaction

select3d <- function() 
  do.call( paste("select3d", dev3d, sep="."),list() ) 

# ===[ GENERIC GEOMETRY METHODS ]=============================================

# generic object rendering

dot3d <- function( x, ... ) 
  UseMethod("dot3d")
wire3d <- function( x, ... ) 
  UseMethod("wire3d")
shade3d <- function( x , ... ) 
  UseMethod("shade3d")

# generic transformation

transform3d <- function ( x, tm ) 
  UseMethod("transform3d")
translate3d <- function ( x, tx, ty, tz ) 
  UseMethod("translate3d")
subdivision3d <- function ( x , ... ) 
  UseMethod("subdivision3d")

