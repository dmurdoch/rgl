\name{rgl}
\title{3D visualization device system}
\alias{rgl}
\alias{rgl.open}
\alias{rgl.close}
\alias{rgl.cur}
\alias{rgl.set}
\alias{rgl.quit}
\description{
  3D real-time rendering device-driver system
}
\usage{
rgl.open()     # open new device
rgl.close()    # close current device
rgl.cur()      # returns active device id
rgl.set(which) # set device as active
rgl.quit()     # shutdown rgl device system
}
\arguments{
  \item{which}{device id}
}
\details{
  RGL is a 3D real-time rendering device driver system for R.
  Multiple devices are managed at a time, where one has the current focus
  that receives instructions from the R command-line.
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
\code{\link{rgl.snapshot}}
}
\keyword{dynamic}
