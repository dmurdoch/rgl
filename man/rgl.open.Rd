\name{rgl.open}
\title{Deprecated window interface}
\alias{rgl.open}
\alias{rgl.close}
\alias{rgl.cur}
\alias{rgl.set}
\alias{rgl.antialias}
\description{
Deprecated functions which are supplied for 
back-compatibility only.  These may be removed as soon
as the next release.
}
\usage{
rgl.open(useNULL = rgl.useNULL())     # open new device
rgl.close()    # close current device
rgl.cur()      # returns active device ID
rgl.set(which, silent = FALSE) # set device as active
}
\arguments{
  \item{useNULL}{whether to open the \dQuote{null} device}
  \item{which}{device ID}
  \item{silent}{whether to suppress update of window titles}
}
\details{
  The RGL device design is oriented towards the R device metaphor. If you send
  scene management instructions, and there's no device open, it will be opened
  automatically.
  Opened devices automatically get the current device focus. The focus may be
  changed by using \code{rgl.set()}.
  
  The \code{rgl.open()} function attempts to open a new RGL window.
  If the \code{"rgl.antialias"} option is set, it will be used to
  select the requested antialiasing.  (See \code{\link{open3d}} for
  more description of antialiasing and an alternative way to set the
  value.)
  
  If \code{useNULL} is \code{TRUE}, RGL will use a \dQuote{null}
  device.  This device records objects as they are plotted, but 
  displays nothing. It is intended for use with \code{\link{rglwidget}}
  and similar functions.
  
  If \code{rgl.open()} fails (e.g. because X windows is not running, or its
  \code{DISPLAY} variable is not set properly), then you can retry the initialization
  by calling \code{\link{rgl.init}()}.  Do not do this when windows have 
  already been successfully opened:  they will be orphaned, with no way to 
  remove them other than closing R.  In fact, it's probably a good idea not to do this
  at all:  quitting R and restarting it is a better solution.

  This package also includes a higher level interface which is described
  in the \link{r3d} help topic.  That interface is designed to act more like
  classic 2D R graphics.  We recommend that you avoid mixing
  \code{rgl.*} and \code{*3d} calls.
}
\value{
  \code{rgl.open}, \code{rgl.close} and \code{rgl.set} are called for their side effects
  and return no useful value.  
  
  \code{rgl.cur} returns the currently active device, or \code{0} if none is
  active.  It is named according to the type of device:  \code{null} for a hidden null device, 
  \code{wgl} for a Windows device, and \code{glX} for an X windows device.
}

\keyword{internal}
