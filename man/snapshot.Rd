\name{rgl.snapshot}
\alias{rgl.snapshot}
\alias{snapshot3d}
\title{export screenshot}
\description{
  Saves the screenshot as png file.
}
\usage{
rgl.snapshot( filename, fmt = "png", top = TRUE )
snapshot3d( ... )
}
\arguments{
  \item{filename}{full path to filename.}
  \item{fmt}{image export format, currently supported: png }
  \item{top}{whether to call \code{\link{rgl.bringtotop}}}
  \item{...}{arguments to pass to \code{rgl.snapshot} }
}
\details{
Animations can be created in a loop modifying the scene and saving 
each screenshot to a file. Various graphics programs (e.g. ImageMagick)
can put these together into a single animation. (See \code{\link{movie3d}} or
the example below.)
}
\note{
On some systems, the snapshot
will include content from other windows if they cover the active rgl
window.  Setting \code{top = TRUE} (the default) will use 
\code{\link{rgl.bringtotop}} before the snapshot
to avoid this.  (See \url{http://www.opengl.org/resources/faq/technical/rasterization.htm#rast0070}
for more details.)
}
\seealso{\code{\link{movie3d}}, \code{\link{rgl.viewpoint}}}

\examples{

\dontrun{

#
# create animation
#

shade3d(oh3d(), color = "red")
rgl.bringtotop()
rgl.viewpoint(0, 20)

setwd(tempdir())
for (i in 1:45) {
  rgl.viewpoint(i, 20)
  filename <- paste("pic", formatC(i, digits = 1, flag = "0"), ".png", sep = "")
  rgl.snapshot(filename)
}
## Now run ImageMagick command:
##    convert -delay 10 *.png -loop 0 pic.gif
}

}

\keyword{dynamic}
