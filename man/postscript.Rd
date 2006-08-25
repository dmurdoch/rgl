\name{rgl.postscript}
\alias{rgl.postscript}
\title{export screenshot}
\description{
  Saves the screenshot as PostScript file.
}
\usage{
rgl.postscript( filename, fmt="eps" )
}
\arguments{
  \item{filename}{full path to filename.}
  \item{fmt}{export format, currently supported: ps, eps, tex, pdf, svg, pgf }
}
\details{
Animations can be created in a loop modifying the scene and saving 
a screenshot to a file. (See example below)
}
\references{
GL2PS: an OpenGL to PostScript printing library by Christophe Geuzaine
}
\author{ Christophe Geuzaine / Albrecht Gebhardt }
\examples{

\dontrun{

#
# create a series of frames for an animation
#

rgl.open()
shade3d(oh3d(), color="red")
rgl.viewpoint(0,20)

for (i in 1:45) {
  rgl.viewpoint(i,20)
  filename <- paste("pic",formatC(i,digits=1,flag="0"),".eps",sep="") 
  rgl.postscript(filename, fmt="eps")
}

}

}
\seealso{
  \code{\link{rgl.viewpoint}}, \code{\link{rgl.snapshot}}
}
\keyword{dynamic}
