# rgl demo: rgl-bivar.r
# author: Daniel Adler
# $Id: bivar.r,v 1.1 2004/02/29 12:00:48 dadler Exp $

require(sm)

# parameters:
n<-50; ngrid<-40

# generate samples:
set.seed(31415)
x<-rnorm(n); z<-rnorm(n)

# estimate non-parameteric density surface via kernel smoothing
smobj<-sm.density(cbind(x,z), display="none", ngrid=ngrid)
sm.y <-smobj$estimate

# generate parameteric density surface of a bivariate normal distribution
xgrid <- seq(min(x),max(x),len=ngrid)
zgrid <- seq(min(z),max(z),len=ngrid)
bi.y <- dnorm(xgrid)%*%t(dnorm(zgrid))

# visualize:
yscale<-20

# clear scene:
rgl.clear()
rgl.clear(type="bbox")
rgl.clear(type="lights")

# setup env:
rgl.bg(color="#887777")
rgl.light()

# Draws the simulated data as spheres on the baseline
rgl.spheres(x,rep(0,n),z,radius=0.1,color="#CCCCFF")

# Draws non-parametric density
rgl.surface(xgrid,zgrid,sm.y*yscale,color="#FF2222",alpha=0.5)

# Draws parameteric density
rgl.surface(xgrid,zgrid,bi.y*yscale,color="#CCCCFF",front="lines")

