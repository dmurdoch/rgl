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
writeASY(title = "scene", 
         outtype = c("pdf", "eps", "asy", "latex", "pdflatex"), 
         prc = TRUE, 
         runAsy = "asy \%filename\%", 
         ids = NULL)
}
\arguments{
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
  \item{ids}{
If not \code{NULL}, write out just these
rgl objects.
}
}
\details{
Asymptote is both a language describing a 
2D or 3D graphic, and a program to interpret
that language and produce output in a variety
of formats including EPS, PDF (interactive
or static), etc.
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
}
\examples{
x <- rnorm(20)
y <- rnorm(20)
z <- rnorm(20)
plot3d(x, y, z, type = "s", col = "red")
setwd(tempdir())
writeASY("interactive")  # Produces interactive.pdf
writeASY("noninteractive", prc = FALSE) # Produces noninteractive.pdf
}
