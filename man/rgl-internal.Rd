\name{rgl-internal}
\title{Internal rgl functions and data}
\alias{rgl.bool}
\alias{rgl.numeric}
\alias{rgl.vertex}
\alias{rgl.nvertex}
\alias{rgl.color}
\alias{rgl.mcolor}
\alias{rgl.clamp}
\alias{rgl.attr}
\alias{rgl.enum}
\alias{rgl.enum.gl2ps}
\alias{rgl.enum.nodetype}
\alias{rgl.enum.pixfmt}
\alias{rgl.enum.polymode}
\alias{rgl.enum.textype}
\alias{rgl.enum.fogtype}
\alias{rgl.enum.primtype}
\alias{rgl.enum.texmagfilter}
\alias{rgl.enum.texminfilter}
\alias{rgl.selectstate}
\alias{rgl.setselectstate}
\alias{edgemap}
\alias{edgeindex}
\alias{cube3d.ib}
\alias{cube3d.vb}
\alias{oh3d.ib}
\alias{oh3d.vb}
\alias{dev3d}
\description{
  internal rgl functions
}
\usage{
rgl.bool(x)
rgl.numeric(x)
rgl.vertex(x, y = NULL, z = NULL)
rgl.nvertex(vertex)
rgl.color(color)
rgl.mcolor(colors)
rgl.clamp(value, low, high)
rgl.attr(vattr, nvertex) 
rgl.enum(name, ..., multi = FALSE)
rgl.enum.gl2ps(postscripttype) 
rgl.enum.nodetype(type)
rgl.enum.pixfmt(fmt)
rgl.enum.polymode(mode)
rgl.enum.textype(textype)
rgl.enum.fogtype(fogtype)
rgl.enum.primtype(primtype)
rgl.enum.texmagfilter(magfiltertype)
rgl.enum.texminfilter(minfiltertype)
rgl.selectstate(dev, subscene)
rgl.setselectstate(state, dev, subscene)
edgemap(size)
edgeindex(from, to, size, row, col)
}
\details{
  These are not to be called by the user.
}
\keyword{internal}

