\name{writeASY}
\alias{writeASY}
\title{
Write Asymptote code for an rgl scene
}
\description{
Asymptote is a language for 3D graphics that
is highly integrated with LaTeX.  This is
an experimental function to
write an Asymptote program to approximate 
an rgl scene.
}
\usage{
writeASY(scene = scene3d(),
         title = "scene", 
         outtype = c("pdf", "eps", "asy", "latex", "pdflatex"), 
         prc = TRUE, 
         runAsy = "asy \%filename\%", 
         defaultFontsize = 12,
         width = 7, height = 7,
         ppi = 100,
         ids = NULL, 
         ver244 = FALSE)
}
\arguments{
  \item{scene}{rgl scene object}
  \item{outtype}{
What type of file to write?  See Details.
}
  \item{prc}{
Whether to produce an interactive PRC scene.
}
  \item{title}{
The base of the filename to produce.
}
  \item{runAsy}{
Code to run the Asymptote program.
}
  \item{defaultFontsize}{
The default fontsize for text. 
  }
  \item{width, height}{
Width and height of the output image, in inches.
  }
  \item{ppi}{
\dQuote{Pixels per inch} to assume when converting
line widths and point sizes (which rgl measures in 
pixels).
  }
  \item{ids}{
If not \code{NULL}, write out just these
rgl objects.
}
  \item{ver244}{
Asymptote version 2.44 had a definition for its \dQuote{light()} function
that was incompatibly changed in some later version.  (The new 
version is seen in version 2.49, but may have arrived earlier.).  
Setting \code{ver244 = TRUE} makes
\code{writeASY} use the older definition.
}
}
\details{
Asymptote is both a language describing a 
2D or 3D graphic, and a program to interpret
that language and produce output in a variety
of formats including EPS, PDF (interactive
or static), etc.

The interactive scene produced with \code{prc = TRUE}
requires \code{outtype = "pdf"}, and (as of this
writing) has a number of limitations:
\itemize{
\item{As far as we know, only Adobe Acrobat Reader of a sufficiently recent version can display 
these scenes.}
\item{Current versions ignore lighting settings.}
}
}
\value{
The filename of the output file is returned
invisibly.
}
\references{
J. C. Bowman and A. Hammerlindl (2008). Asymptote: A vector graphics language, 
TUGBOAT: The Communications of the TeX Users Group, 29:2, 288-294.
}
\author{
Duncan Murdoch
}
\note{
This function is currently under development and limited in the quality
of output it produces.  Arguments will likely
change.

There are a number of differences between the interactive display in 
Asymptote and the display in rgl.  In particular, many objects that are
a fixed size in rgl will scale with the image in Asymptote.  Defaults
have been chosen somewhat arbitrarily; tweaking will likely be needed.

Material properties of surfaces are not yet implemented.
}
\seealso{
\code{\link{scene3d}} saves a copy of a scene to an R variable; \code{\link{writeWebGL}},
\code{\link{writePLY}}, \code{\link{writeOBJ}} and \code{\link{writeSTL}}
write the scene to a file in various other formats.
}
\examples{
x <- rnorm(20)
y <- rnorm(20)
z <- rnorm(20)
plot3d(x, y, z, type = "s", col = "red")
olddir <- setwd(tempdir())
writeASY(title = "interactive")  # Produces interactive.pdf
writeASY(title = "noninteractive", prc = FALSE) # Produces noninteractive.pdf
setwd(olddir)
}
