\name{rgl.snapshot}
\alias{rgl.snapshot}
\alias{snapshot3d}
\title{export screenshot}
\description{
  Saves the screenshot as png file.
}
\usage{
rgl.snapshot( filename, fmt="png" )
snapshot3d( ... )
}
\arguments{
  \item{filename}{full path to filename.}
  \item{fmt}{image export format, currently supported: png }
  \item{...}{arguments to pass to \code{rgl.snapshot} }
}
\details{
Animations can be created in a loop modifying the scene and saving 
each screenshot to a file. Various graphics programs (e.g. ImageMagick)
can put these together into a single animation. (See example below)
}
\examples{

\dontrun{

#
# create animation
#

shade3d(oh3d(), color="red")
rgl.viewpoint(0,20)

setwd(tempdir())
for (i in 1:45) {
  rgl.viewpoint(i,20)
  filename <- paste("pic",formatC(i,digits=1,flag="0"),".png",sep="")
  rgl.snapshot(filename)
}
## Now run ImageMagick command:
##    convert -delay 10 *.png -loop 0 pic.gif
}

}
\seealso{
  \code{\link{rgl.viewpoint}}
}
\keyword{dynamic}
