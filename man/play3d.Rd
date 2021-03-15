\name{play3d}
\alias{play3d}
\alias{movie3d}
\title{ Play animation of RGL scene }
\description{
\code{play3d} calls a function repeatedly, passing it the elapsed
time in seconds, and using the result of the function to
reset the viewpoint.  \code{movie3d} does the same, but
records each frame to a file to make a movie.
}
\usage{
play3d(f, duration = Inf, dev = cur3d(), ..., startTime = 0)
movie3d(f, duration, dev = cur3d(), ..., fps = 10, 
                    movie = "movie", frames = movie, dir = tempdir(), 
                    convert = NULL, clean = TRUE, verbose = TRUE,
                    top = !rgl.useNULL(), type = "gif", startTime = 0) 

}
\arguments{
  \item{f}{ A function returning a list that may be passed to \code{\link{par3d}} }
  \item{duration}{ The duration of the animation }    
  \item{dev}{ Which RGL device to select }
  \item{\dots}{ Additional parameters to pass to \code{f}. }
  \item{startTime}{ Initial time at which to start the animation }
  \item{fps}{ Number of frames per second }
  \item{movie}{ The base of the output filename, not including .gif }
  \item{frames}{ The base of the name for each frame }
  \item{dir}{ A directory in which to create temporary files for each frame of the movie }  
  \item{convert}{ How to convert to a GIF movie; see Details }
  \item{clean}{ If \code{convert} is \code{NULL} or \code{TRUE}, whether to delete the individual frames }
  \item{verbose}{ Whether to report the \code{convert} command and the output filename }
  \item{top}{ Whether to call \code{\link{rgl.bringtotop}} before each frame }
  \item{type}{ What type of movie to create.  See Details. }
}
\details{
The function \code{f} will be called in a loop with the first argument
being the \code{startTime} plus the time in seconds since the start 
(where the start is measured after all arguments have been evaluated).

\code{play3d} is likely to place a high load
on the CPU; if this is a problem, calls to \code{\link{Sys.sleep}}
should be made within the function to release time to other processes.

\code{play3d} will run for the specified \code{duration} (in seconds), but
can be interrupted by pressing \code{ESC} while the RGL window has the focus.

\code{movie3d} saves each frame to disk in a filename of the form \file{framesXXX.png}, where
XXX is the frame number, starting from 0.  
If \code{convert} is \code{NULL} (the default) and the
\pkg{\link[magick]{magick}} package is installed, it will be used
to convert the frames to a GIF movie (or other format if supported).  If 
\pkg{\link[magick]{magick}} is not installed or 
\code{convert} is \code{TRUE}, \code{movie3d} will attempt
to use the external \command{ImageMagick} program to convert the
frames to a movie.  
The newer \command{magick} executable is tried
first, then \command{convert} if that fails.
The \code{type} argument will be passed to \command{ImageMagick} to use as a file extension
to choose the file type.

Finally, \code{convert} can be a template for a command to
execute in the standard shell (wildcards are allowed). The template is
converted to a command using \cr
\code{\link{sprintf}(convert, fps, frames, movie, type, duration, dir)} \cr
For example, \code{convert = TRUE}
uses the template \code{"magick -delay 1x\%d \%s*.png \%s.\%s"}. All work
is done in the directory \code{dir}, so paths should not be needed in
the command.  (Note that \code{\link{sprintf}} does not require all
arguments to be used, and supports formats that use them in an
arbitrary order.)

The \code{top = TRUE} default is designed to work around an OpenGL limitation:
in some implementations, \code{\link{rgl.snapshot}} will fail if the window
is not topmost.

As of \pkg{rgl} version 0.94, the \code{dev} argument is not needed:  the
function \code{f} can specify its device, as \code{\link{spin3d}} does, 
for example.  However, if \code{dev} is specified, it will be selected
as the current device as each update is played.

As of \pkg{rgl} version 0.95.1476, \code{f} can 
include multiple values in a \code{"subscene"}
component, and \code{par3d()} will be called
for each of them.
}
\value{
\code{play3d} is called for the side effect of its repeated calls to \code{f}.
It returns \code{NULL} invisibly.

\code{movie3d} is also normally called for the side effect
of producing the output movie.  It invisibly returns

}
\author{ Duncan Murdoch, based on code by Michael Friendly }
\seealso{ \code{\link{spin3d}} and \code{\link{par3dinterp}} return functions suitable 
          to use as \code{f}. See \code{demo(flag)} for an example that modifies the
          scene in \code{f}.}
\examples{
open3d()
plot3d( cube3d(col = "green") )
M <- par3d("userMatrix")
if (!rgl.useNULL())
  play3d( par3dinterp(time = (0:2)*0.75, userMatrix = list(M,
                                     rotate3d(M, pi/2, 1, 0, 0),
                                     rotate3d(M, pi/2, 0, 1, 0) ) ), 
        duration = 3 )
\dontrun{
movie3d( spin3d(), duration = 5 )
}

}
\keyword{ dplot }
