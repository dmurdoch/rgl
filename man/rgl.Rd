\name{rgl}
\title{3D visualization device system}
\alias{rgl}
\alias{rgl.open}
\alias{rgl.close}
\alias{rgl.cur}
\alias{rgl.set}
\alias{rgl.quit}
\description{
  3D visualization device system using OpenGL.
}
\usage{
rgl.open()     # open new device
rgl.close()    # close 
rgl.cur()      # returns active device
rgl.set(which) # set device as active
rgl.quit()     # force rgl sub-system shutdown and detach package
}
\arguments{
  \item{which}{device id}
}
\details{
  The rgl R package allows for creating multiple rgl devices, 
  where one at a time has the current focus.

  The device design is oriented towards the R device metaphor. If you send
  scene management instructions, and there's no device open, it will be opened
  automatically.

  Opened devices automatically gain the current device focus. The focus may be
  changed by using rgl.set().

  rgl.quit() does shutdown the rgl subsystem and all open devices, 
  detaches the package inclusive the shared library and additional system libraries.
}
\examples{
example(rgl.surface)
}
\seealso{
\code{\link{rgl.clear}}, 
\code{\link{rgl.pop}},
\code{\link{rgl.viewpoint}},
\code{\link{rgl.light}},
\code{\link{rgl.bg}},
\code{\link{rgl.bbox}},
\code{\link{rgl.points}},
\code{\link{rgl.lines}},
\code{\link{rgl.triangles}},
\code{\link{rgl.quads}},
\code{\link{rgl.texts}},
\code{\link{rgl.surface}},
\code{\link{rgl.spheres}},
\code{\link{rgl.sprites}},
\code{\link{rgl.snapshot}},
\code{\link{rgl-maintainer}}
}
\keyword{dynamic}
