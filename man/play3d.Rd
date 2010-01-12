\name{play3d}
\alias{play3d}
\alias{movie3d}
\title{ Play animation of rgl scene }
\description{
\code{play3d} calls a function repeatedly, passing it the elapsed
time in seconds, and using the result of the function to
reset the viewpoint.  \code{movie3d} does the same, but
records each frame to a file to make a movie.
}
\usage{
play3d(f, duration = Inf, dev = rgl.cur(), ..., startTime = 0)
movie3d(f, duration, dev = rgl.cur(), ..., fps = 10, 
                    movie = "movie", frames = movie, dir = tempdir(), 
                    convert = TRUE, clean = TRUE, verbose=TRUE,
                    top = TRUE, type = "gif", startTime = 0) 

}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{f}{ A function returning a list that may be passed to \code{\link{par3d}} }
  \item{duration}{ The duration of the animation }    
  \item{dev}{ Which rgl device to select }
  \item{\dots}{ Additional parameters to pass to \code{f}. }
  \item{startTime}{ Initial time at which to start the animation }
  \item{fps}{ Number of frames per second }
  \item{movie}{ The base of the output filename, not including .gif }
  \item{frames}{ The base of the name for each frame }
  \item{dir}{ A directory in which to create temporary files for each frame of the movie }  
  \item{convert}{ Whether to try to convert the frames to a single GIF movie, or a command to do so }
  \item{clean}{ If \code{convert} is \code{TRUE}, whether to delete the individual frames }
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

\code{movie3d} saves each frame to disk in a filename of the form "framesXXX.png", where
XXX is the frame number, starting from 0.  If \code{convert} is \code{TRUE}, it
uses ImageMagick to convert them to a single file, by default an animated GIF.  
The \code{type} argument will be passed to ImageMagick to use as a file extension
to choose the file type.

Alternatively, \code{convert} can be a template for a command to
execute in the standard shell (wildcards are allowed). The template is
converted to a command using \code{\link{sprintf}(convert, fps,
frames, movie, type, dir, duration)}.  For example, \code{code=TRUE}
uses the template \code{"convert -delay 1x\%d \%s*.png \%s.\%s"}. All work
is done in the directory \code{dir}, so paths should not be needed in
the command.  (Note that \code{\link{sprintf}} does not require all
arguments to be used, and supports formats that use them in an
arbitrary order.)

The \code{top=TRUE} default is designed to work around an OpenGL limitation:
in some implementations, \code{\link{rgl.snapshot}} will fail if the window
is not topmost.
}
\value{
This function is called for the side effect of its repeated calls to \code{f}.
It returns \code{NULL} invisibly.
}
\author{ Duncan Murdoch, based on code by Michael Friendly }
\seealso{ \code{\link{spin3d}} and \code{\link{par3dinterp}} return functions suitable 
          to use as \code{f}. See \code{demo(flag)} for an example that modifies the
          scene in \code{f}.}
\examples{
open3d()
plot3d( cube3d(col="green") )
M <- par3d("userMatrix")
play3d( par3dinterp( userMatrix=list(M,
                                     rotate3d(M, pi/2, 1, 0, 0),
                                     rotate3d(M, pi/2, 0, 1, 0) ) ), 
        duration=4 )
\dontrun{
movie3d( spin3d(), duration=5 )
}

}
\keyword{ dplot }
