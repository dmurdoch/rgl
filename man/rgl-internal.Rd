\name{rgl-internal}
\title{Internal rgl functions}
\alias{rgl.bool}
\alias{rgl.numeric}
\alias{rgl.range}
\alias{rgl.vertex}
\alias{rgl.nvertex}
\alias{rgl.color}
\alias{rgl.mcolor}
\alias{rgl.clamp}
\alias{rgl.attr}
\alias{rgl.enum}
\alias{rgl.enum.nodetype}
\alias{rgl.enum.pixfmt}
\alias{rgl.enum.polymode}
\alias{rgl.enum.textype}
\alias{rgl.enum.fogtype}
\alias{rgl.enum.primtype}
\alias{rgl.enum.halign}
\alias{rgl.enum.texmagfilter}
\alias{rgl.enum.texminfilter}
\alias{rgl.select}
\alias{rgl.selectstate}
\alias{rgl.setselectstate}
\description{
  internal rgl functions
}
\usage{
rgl.bool(x)
rgl.numeric(x)
rgl.range(x, low, high)
rgl.vertex(x,y,z)
rgl.nvertex(vertex)
rgl.color(color)
rgl.mcolor(colors)
rgl.clamp(value, low, high)
rgl.attr(vattr, nvertex) 
rgl.enum(name, ...)
rgl.enum.nodetype(type)
rgl.enum.pixfmt(fmt)
rgl.enum.polymode(mode)
rgl.enum.textype(textype)
rgl.enum.fogtype(fogtype)
rgl.enum.primtype(primtype)
rgl.enum.halign(halign)
rgl.enum.texmagfilter(magfiltertype)
rgl.enum.texminfilter(minfiltertype)
rgl.selectstate()
rgl.select()
rgl.setselectstate(state)
edgemap(size)
edgeindex(from,to,size,row,col)
}
\details{
  These are not to be called by the user.
}
\keyword{internal}

