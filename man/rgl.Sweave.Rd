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

\preformatted{<<fig=TRUE, pdf=FALSE, grdevice=rgl.Sweave>>=}

When the \code{rgl} device is closed at the end of the code chunk,
\code{rgl.Sweave.off()} will be called automatically.  It
will save a snapshot
of the last image (by default in \file{.png} format) for inclusion in the 
Sweave document and (by default) close the device.  
Alternatively, the \code{Sweave.snapshot()} function
can be called to save the image before the end of the chunk.  Only one
snapshot will be taken per chunk.

If the chunk option \code{stayopen=TRUE} is used, then the \code{rgl}
device will \emph{not} be closed, and a call to \code{Sweave.snapshot()}
will be used at the end of the chunk if it has not been called explicitly.

If the chunk option \code{outputtype=pdf} or \code{outputtype=eps} is used,
the \code{\link{rgl.postscript}} function will be used to write output in the
specified format.

}

\note{
We recommend turning off all other graphics drivers in a chunk that uses
\code{grdevice=rgl.Sweave}.  The \code{rgl} functions do not write to
a standard graphics device.
}

\note{
It is possible to use this driver in \R version 2.13.0, but there are problems
because there is no automatic call to \code{rgl.Sweave.off()} at the
end of a chunk, because the chunk is always run at least twice in that
version of \R, and because custom string options are not supported.
An explicit call to \code{rgl.Sweave.off()} as the last
line of the code chunk is recommended, though efforts are made to do the right thing
if this is omitted.  Some other notes that apply to \R version 2.13.0:
\itemize{
\item Calling \code{rgl.close()} within the chunk should work.
\item If neither \code{rgl.Sweave.off()} nor \code{rgl.close()} is called and
a new chunk with \code{grdevice=rgl.Sweave} is opened, a call to 
\code{rgl.Sweave.off()} will be inserted.  However, the last chunk with
\code{grdevice=rgl.Sweave} will not be automatically closed.
\item Running \code{Sweave()} within \R is likely to leave a number of
open \code{rgl} device windows.
\item It is not possible to specify the output type using the \code{outputtype}
chunk option.  Snapshots will always be saved in \file{.png} format.
}

Most of these problems are fixed in later versions of \R, including 2.13.0-patched.
Within the \R 2.13.x series, it is recommended to use the  
\code{figs.only=TRUE, pdf=FALSE} options (and leave the other
graphics drivers at their default \code{FALSE} settings), which cause 
the code in the chunk to be run only once.  

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
