\name{rgl.Sweave}
\alias{rgl.Sweave}
\alias{rgl.Sweave.off}
\alias{Sweave.snapshot}
\title{
Integrating \code{rgl} with \code{Sweave}
}
\description{
As of \R 2.13.0, it is possible to include \code{rgl} graphics into
a \link{Sweave} document.  These functions support that
integration.
}
\usage{
Sweave.snapshot()
rgl.Sweave(name, width, height, options, ...)
rgl.Sweave.off()
}
\arguments{
  \item{name, width, height, options, ...}{
These arguments are passed by \code{\link{Sweave}} to \code{rgl.Sweave}
when it opens the device.
}
}
\details{
The \code{rgl.Sweave} function is not normally called by the user.  The user
specifies it as the graphics driver when opening the code chunk, e.g. by
using

\preformatted{<<fig=TRUE, pdf=FALSE, grdevice=rgl.Sweave, resolution=100>>=}

When the \code{rgl} device is closed at the end of the code chunk,
\code{rgl.Sweave.off()} will be called automatically.  It
will save a snapshot
of the last image (by default in \file{.png} format) for inclusion in the 
Sweave document and (by default) close the device.  
Alternatively, the \code{Sweave.snapshot()} function
can be called to save the image before the end of the chunk.  Only one
snapshot will be taken per chunk.

Several chunk options are used by the \code{rgl.Sweave} device:
\describe{
\item{stayopen}{(default \code{FALSE}).  If \code{TRUE} then the \code{rgl}
device will \emph{not} be closed at the end of the chunk,
instead a call to \code{Sweave.snapshot()}
will be used if it has not been called explicitly.  Subsequent chunks can add
to the scene.}
\item{outputtype}{(default \code{png}).  The output may be specified 
as \code{outputtype=pdf} or \code{outputtype=eps} instead, in which case
the \code{\link{rgl.postscript}} function will be used to write output in the
specified format.  Note that  \code{\link{rgl.postscript}} has limitations
and does not always render scenes correctly.}
\item{delay}{(default 0.1).  After creating the display window, \code{\link{Sys.sleep}}
will be called to delay this many seconds, to allow the display system to 
initialize.  This is needed in X11 systems which open the display
asynchronously.  If the default time is too short, \code{rgl.Sweave} may
falsely report that the window is too large to open.}
}
}

\note{
We recommend turning off all other graphics drivers in a chunk that uses
\code{grdevice=rgl.Sweave}.  The \code{rgl} functions do not write to
a standard graphics device.
}

\note{
The \code{rgl} package relies on your graphics hardware to render OpenGL scenes,
and the default \file{.png} output copies a bitmap from the hardware device.  All 
such devices have limitations on the size of the bitmap, but they do not 
always signal these limitations in a way that \code{rgl} will detect.  If you find
that images are not being produced properly, try reducing the size using 
the \code{resolution}, \code{width} or \code{height} chunk options.
}

\value{
These functions are called for their side effects.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{RweaveLatex}} for a description of alternate graphics drivers
in Sweave, and standard options that can be used in code chunks.
}
\keyword{ utilities }
