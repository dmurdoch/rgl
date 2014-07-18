\name{rgl.open}
\title{3D visualization device system}
\alias{rgl.open}
\alias{rgl.close}
\alias{rgl.cur}
\alias{rgl.set}
\alias{rgl.quit}
\alias{rgl.init}
\alias{rgl.antialias}
\alias{rgl.dev.list}
\description{
  3D real-time rendering system.
}
\usage{
# Low level rgl.* interface
rgl.open(useNULL = rgl.useNULL())     # open new device
rgl.close()    # close current device
rgl.cur()      # returns active device ID
rgl.dev.list() # returns all device IDs
rgl.set(which, silent=FALSE) # set device as active
rgl.quit()     # shutdown rgl device system
rgl.init(initValue=0, onlyNULL=FALSE)     # re-initialize rgl
}
\arguments{
  \item{useNULL}{whether to open the \dQuote{null} device}
  \item{which}{device ID}
  \item{silent}{whether to suppress update of window titles}
  \item{initValue}{value for internal use only}
  \item{onlyNULL}{only initialize the null (no display) device}
}
\details{
  The \pkg{rgl} device design is oriented towards the R device metaphor. If you send
  scene management instructions, and there's no device open, it will be opened
  automatically.
  Opened devices automatically get the current device focus. The focus may be
  changed by using \code{rgl.set()}.
  \code{rgl.quit()} shuts down the rgl subsystem and all open devices, 
  detaches the package including the shared library and additional system libraries.
  
  The \code{rgl.open()} function attempts to open a new RGL window.
  If the \code{"rgl.antialias"} option is set, it will be used to
  select the requested antialiasing.  (See \code{\link{open3d}} for
  more description of antialiasing and an alternative way to set the
  value.)
  
  If \code{useNULL} is \code{TRUE}, \pkg{rgl} will use a \dQuote{null}
  device.  This device records objects as they are plotted, but 
  displays nothing. It is intended for use with \code{\link{writeWebGL}}
  and similar functions.
  
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
\value{
  \code{rgl.open}, \code{rgl.close} and \code{rgl.set} are called for their side effects
  and return no useful value.  Similarly \code{rgl.init} and \code{rgl.quit} are not designed
  to return useful values; in fact, users shouldn't call them at all!
  
  \code{rgl.cur} returns the currently active devices, or \code{0} if none is
  active; \code{rgl.dev.list} returns a vector of all open devices.  Both functions name
  the items according to the type of device:  \code{null} for a hidden null device, 
  \code{wgl} for a Windows device, \code{glX} for an X windows device, and
  \code{NSopenGL} for a Cocoa device on OSX.
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
\code{\link{rgl.snapshot}},
\code{\link{rgl.useNULL}}
}
\keyword{dynamic}
