\name{rgl.postscript}
\alias{rgl.postscript}
\title{export screenshot}
\description{
  Saves the screenshot as PostScript file.
}
\usage{
rgl.postscript( filename, fmt="eps", drawText=TRUE )
}
\arguments{
  \item{filename}{full path to filename.}
  \item{fmt}{export format, currently supported: ps, eps, tex, pdf, svg, pgf }
  \item{drawText}{logical, whether to draw text}
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

# Save the first persp3d example.
# Include the persp3da.tex and persp3db.tex files in latex or pdflatex document

example(persp3d)
rgl.close()  # delete the second example

title3d("Using LaTeX text")
rgl.postscript("persp3da.ps","ps",drawText=FALSE)
rgl.postscript("persp3da.pdf","pdf",drawText=FALSE)
rgl.postscript("persp3da.tex","tex")
rgl.pop()
title3d("Using ps/pdf text")
rgl.postscript("persp3db.ps","ps")
rgl.postscript("persp3db.pdf","pdf")
rgl.postscript("persp3db.tex","tex",drawText=FALSE)

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
