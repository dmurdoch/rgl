# rgl demo: rgl-bivar.r
# author: Daniel Adler
# $Id$

rgl.demo.bivar <- function()
{
  require(MASS);
  
  # parameters:
  n<-50; ngrid<-40
  
  # generate samples:
  set.seed(31415)
  x<-rnorm(n); y<-rnorm(n)
  
  # estimate non-parameteric density surface via kernel smoothing
  denobj<-kde2d(x, y, n=ngrid)
  den.z <-denobj$z
  
  # generate parameteric density surface of a bivariate normal distribution
  xgrid <- denobj$x
  ygrid <- denobj$y
  bi.z <- dnorm(xgrid)%*%t(dnorm(ygrid))
  
  # visualize:
  zscale<-20
  
  # clear scene:
  clear3d()
  clear3d(type="bbox")
  clear3d(type="lights")
  
  # setup env:
  bg3d(color="#887777")
  light3d()
  
  # Draws the simulated data as spheres on the baseline
  spheres3d(x,y,rep(0,n),radius=0.1,color="#CCCCFF")
  
  # Draws non-parametric density
  surface3d(xgrid,ygrid,den.z*zscale,color="#FF2222",alpha=0.5)
  
  # Draws parameteric density
  surface3d(xgrid,ygrid,bi.z*zscale,color="#CCCCFF",back="lines") 
}

rgl.demo.bivar()

