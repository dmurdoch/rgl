\name{rgl.postscript}
\alias{rgl.postscript}
\title{Export vector graphics}
\description{
  Saves the screenshot to a file in PostScript or other vector graphics format.
}
\usage{
rgl.postscript( filename, fmt = "eps", drawText = TRUE )
}
\arguments{
  \item{filename}{full path to filename.}
  \item{fmt}{export format, currently supported: ps, eps, tex, pdf, svg, pgf }
  \item{drawText}{logical, whether to draw text}
}
\details{
Animations can be created in a loop modifying the scene and saving 
a screenshot to a file. (See example below)

This function is a wrapper for the GL2PS library by Christophe Geuzaine,
and has the same limitations as that library:  not all OpenGL features
are supported, and some are only supported in some formats.
See the reference for full details.
}
\references{
GL2PS: an OpenGL to PostScript printing library by Christophe Geuzaine,
\url{http://www.geuz.org/gl2ps/}, version 1.4.0.
}
\author{ Christophe Geuzaine / Albrecht Gebhardt }
\examples{
# Create new files in tempdir
savedir <- setwd(tempdir())

x <- y <- seq(-10, 10, length = 20)
z <- outer(x, y, function(x, y) x^2 + y^2)
persp3d(x, y, z, col = 'lightblue')

title3d("Using LaTeX text", col = 'red', line = 3)
rgl.postscript("persp3da.ps", "ps", drawText = FALSE)
rgl.postscript("persp3da.pdf", "pdf", drawText = FALSE)
rgl.postscript("persp3da.tex", "tex")
pop3d()
title3d("Using ps/pdf text", col = 'red', line = 3)
rgl.postscript("persp3db.ps", "ps")
rgl.postscript("persp3db.pdf", "pdf")
rgl.postscript("persp3db.tex", "tex", drawText = FALSE)

setwd(savedir)

\dontrun{

#
# create a series of frames for an animation
#

rgl.open()
shade3d(oh3d(), color = "red")
rgl.viewpoint(0, 20)

for (i in 1:45) {
  rgl.viewpoint(i, 20)
  filename <- paste("pic", formatC(i, digits = 1, flag = "0"), ".eps", sep = "") 
  rgl.postscript(filename, fmt = "eps")
}

}

}
\seealso{
  \code{\link{view3d}}, \code{\link{snapshot3d}}
}
\keyword{dynamic}
