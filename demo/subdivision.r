# RGL-demo: subdivision surfaces
# author: Daniel Adler
# $Id$

rgl.demo.subdivision <- function()
{
  # setup environment
  clear3d()
  clear3d(type="bbox")
  clear3d(type="lights")
  bg3d(color="gray")
  light3d()

  # generate basic mesh
  obj <- oh3d()

  part <- function( level, tx, ... )
  {
    shade3d( translate3d( obj, tx, 0, 0 )
    , color="gray30", front="lines",alpha=0.5,back="lines"
    )
    shade3d( translate3d( subdivision3d( obj, depth=level ), tx, 0, 0 )
    , ... )
  }
  
  common <- c(alpha=0.5)
  
  part(0, -5.50, color="blue"   , common )
  part(1, -1.75, color="yellow" , common )
  part(2,  1.75, color="red"    , common )
  part(3,  5.50, color="green"  , common )

}

rgl.demo.subdivision()

