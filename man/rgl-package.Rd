\name{rgl-package}
\title{3D visualization device system}
\alias{rgl-package}
\alias{rgl}
\alias{rgl.open}
\alias{rgl.close}
\alias{rgl.cur}
\alias{rgl.set}
\alias{rgl.quit}
\alias{rgl.init}
\description{
  3D real-time rendering system.
}
\usage{
# Low level rgl.* interface
rgl.open()     # open new device
rgl.close()    # close current device
rgl.cur()      # returns active device ID
rgl.set(which) # set device as active
rgl.quit()     # shutdown rgl device system
rgl.init(initValue=0)     # re-initialize rgl
}
\arguments{
  \item{which}{device ID}
  \item{initValue}{value for internal use only}
}
\details{
  RGL is a 3D real-time rendering device driver system for R.
  Multiple devices are managed at a time, where one has the current focus
  that receives instructions from the R command-line.
  The device design is oriented towards the R device metaphor. If you send
  scene management instructions, and there's no device open, it will be opened
  automatically.
  Opened devices automatically get the current device focus. The focus may be
  changed by using \code{rgl.set()}.
  \code{rgl.quit()} shuts down the rgl subsystem and all open devices, 
  detaches the package including the shared library and additional system libraries.
  
  If \code{rgl.open()} fails (e.g. because X windows is not running, or its
  \code{DISPLAY} variable is not set properly), then you can retry the initialization
  by calling \code{rgl.init()}.  Do not do this when windows have 
  already been successfully opened:  they will be orphaned, with no way to 
  remove them other than closing R.  In fact, it's probably a good idea not to do this
  at all:  quitting R and restarting it is a better solution.

  This package also includes a higher level interface which is described
  in the \link{r3d} help topic.  That interface is designed to act more like
  classic 2D R graphics.  We recommend that you avoid mixing
  \code{rgl.*} and \code{*3d} calls.

  See the first example below to display the ChangeLog.
}
\examples{
file.show(system.file("ChangeLog", package="rgl"))
example(surface3d)
example(plot3d)
}
\seealso{
\link{r3d},
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
