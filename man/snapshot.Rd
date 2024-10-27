\name{snapshot3d}
\alias{rgl.snapshot}
\alias{snapshot3d}
\alias{RGL_USE_WEBSHOT}
\title{Export screenshot}
\description{
  Saves the screenshot to a file.
}
\usage{
rgl.snapshot( filename, fmt = "png", top = TRUE )
snapshot3d( filename = tempfile(fileext = ".png"), 
            fmt = "png", top = TRUE,
            ..., scene, width = NULL, height = NULL,
            webshot = as.logical(Sys.getenv("RGL_USE_WEBSHOT", "TRUE")) )
}
\arguments{
  \item{filename}{path to file to save.}
  \item{fmt}{image export format, currently supported: png.  Ignored if \code{webshot = TRUE}. }
  \item{top}{whether to call \code{\link{rgl.bringtotop}}.
Ignored if \code{webshot = TRUE}.}
  \item{...}{arguments to pass to \code{webshot2::webshot} }
  \item{scene}{an optional result of \code{\link{scene3d}} 
    or \code{\link{rglwidget}} to plot}
  \item{width, height}{optional specifications of output
    size in pixels}
  \item{webshot}{Use the \pkg{webshot2} package to take the 
  snapshot}  
}
\details{
\code{rgl.snapshot()} is a low-level function
that copies the current RGL window from the screen.  Users
should usually use \code{snapshot3d()} instead; it is more flexible,
and (if \pkg{webshot2} is installed) can take images even if
no window is showing, and they can be larger than the physical
screen.  On some systems \pkg{webshot2} doesn't work reliably; if
you find \code{snapshot3d()} failing or taking a very long time
I'd recommend using \code{snapshot3d(..., webshot = FALSE)}.  See
the note below about \code{RGL_USE_WEBSHOT} to make this the default.

Animations can be created in a loop modifying the scene and saving 
each screenshot to a file. Various graphics programs (e.g. ImageMagick)
can put these together into a single animation. (See \code{\link{movie3d}} or
the example below.)
}
\value{
These functions are mainly called for the side effects.  The
filename of the saved file is returned invisibly.
}
\note{
When \code{rgl.useNULL()} is \code{TRUE}, only \code{webshot = TRUE}
will produce a snapshot.  It requires the \pkg{webshot2}
package and a Chrome browser.  If no suitable browser is
found, \code{snapshot3d()} will revert to \code{rgl.snapshot()}.
To override the automatic search, set
environment variable \env{CHROMOTE_CHROME}
to the path to a suitable browser.

\code{rgl.snapshot} works by taking an image from the displayed
window on-screen.
On some systems, the snapshot
will include content from other windows if they cover the active RGL
window.  Setting \code{top = TRUE} (the default) will use 
\code{\link{rgl.bringtotop}} before the snapshot
to avoid this.  

There are likely limits to how large \code{width} and
\code{height} can be set based on the display hardware; if these
are exceeded the results are undefined.  A typical result
is that the snapshot will still be made but at a smaller
size.

There are slight differences between the displays with
\code{webshot = TRUE} and \code{webshot = FALSE}, as the 
former are rendered using WebGL while the latter are rendered
using OpenGL.  Often the \code{webshot = TRUE} displays
have better quality, but they are usually slower to
produce, sometimes drastically so.  

Set the environment
variable \env{RGL_USE_WEBSHOT} to \code{"FALSE"} if
you want \code{rgl.snapshot} to be used by default.
}
\seealso{\code{\link{movie3d}}, \code{\link{view3d}}}

\examples{
if (interactive() && !in_pkgdown_example()) {
  saveopts <- options(rgl.useNULL = TRUE)
  plot3d(matrix(rnorm(300), ncol = 3, dimnames = list(NULL, c("x", "y", "z"))), 
         col = "red")
  options(saveopts)
  browseURL(snapshot3d())
}

\dontrun{

#
# create animation
#

shade3d(oh3d(), color = "red")
rgl.bringtotop()
view3d(0, 20)

olddir <- setwd(tempdir())
for (i in 1:45) {
  view3d(i, 20)
  filename <- paste("pic", formatC(i, digits = 1, flag = "0"), ".png", sep = "")
  snapshot3d(filename)
}
## Now run ImageMagick in tempdir().  Use 'convert' instead of 'magick'
## if you have an older version of ImageMagick:
##    magick -delay 10 *.png -loop 0 pic.gif
setwd(olddir)
}

}

\keyword{dynamic}
