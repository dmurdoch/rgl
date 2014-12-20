\name{writeWebGL}
\alias{writeWebGL}
\title{
Write scene to HTML.
}
\description{
Writes the current scene to a collection of files that contain WebGL code to reproduce
it in a browser.
}
\usage{
writeWebGL(dir = "webGL", filename = file.path(dir, "index.html"), 
           template = system.file(file.path("WebGL", "template.html"), package = "rgl"),
           prefix = "",
           snapshot = TRUE, commonParts = TRUE,
           font = "Arial", width, height)
}
\arguments{
  \item{dir}{
  Where to write the files.
}
  \item{filename}{
  The filename to use for the main file.  
}
  \item{template}{
The template web page to which to write the Javascript for the scene.  See Details below.
}
  \item{prefix}{
An optional prefix to use on global identifiers in the scene; use different prefixes
for different scenes displayed on the same web page.  If not blank, it should be a legal identifier
in Javascript and HTML.
}
  \item{snapshot}{
  Whether to include a snapshot of the scene, to be displayed in browsers that don't support WebGL.
}
  \item{commonParts}{
  Whether to include parts that would be common to several
figures on the same page.  Currently this includes
a reference to and copy of the \file{CanvasMatrix.js}
file in the output.
}
  \item{font}{
  The font to use for text.
}
  \item{width, height}{
  The (optional) width and height in pixels of the image to display.  If omitted,
the \code{par3d("windowRect")} dimensions will be used.
}
}
\details{
This function writes out a web page containing Javascript that reconstructs the scene in WebGL.

Use the \code{template} argument to give the filename of a web page that is to contain the
code for the new scene.  It should contain a single line containing \code{paste("\%", prefix, "WebGL\%")}, e.g.
\code{\%WebGL\%} with the default empty prefix.  That line will be replaced by the Javascript and other
code necessary to reproduce the current scene.  The template may also contain the string \code{"\%rglVersion\%"}
which will be replaced with the current \pkg{rgl} version number.  If
\code{template} is \code{NULL}, the output will simply be written directly
to the main file.

To put more than one scene into a web page, use different values of \code{prefix} for each.  The prefix
will be used in identifiers in both Javascript and HTML, so it is safest to start with a letter and
only use alphanumeric characters.

WebGL is a fairly new technology for displaying 3D scenes in browsers.  Most current browsers support it
to some extent, though it may not be enabled by default; see \url{http://get.webgl.org} for details.  A major
exception currently is Microsoft's Internet Explorer, though plugins are available.

Currently \code{writeWebGL} has a number of known limitations, some of which will be gradually eliminated as
development progresses:
\itemize{
\item The bounding box decorations are fixed; labels do not move as they do within \R.
\item User-defined mouse controls are not supported.
\item No automatic movement (e.g. rotation via \code{\link{spin3d}}) is supported.
\item Missing values are not handled properly.
\item Polygons will only be rendered as filled; there is no support in WebGL for wireframe or point rendering.
\item WebGL browsers generally do not support more than 65535 vertices per
object.  \code{writeWebGL} will print a warning if this limit is exceeded, but it is up to the user
to break his scene into smaller objects.  (And 65535 vertices may not be small enough!)
}
}
\value{
The \code{filename} is returned.
}
\references{
\url{http://www.webgl.org}
}
\author{
Duncan Murdoch.
}
\note{
If \code{commonParts} is \code{TRUE}, the output includes a binary copy of
the CanvasMatrix Javascript library.  This
file is necessary for the Javascript code written by \code{writeWebGL} to 
function properly, but only one copy is needed if the output page
contains multiple \code{writeWebGL} figures.  

Its source (including 
the copyright notice and license for free use) is included in the file named by
\code{system.file("WebGL/CanvasMatrix.src.js", package = "rgl")}.  
}
\seealso{
\code{\link{scene3d}} saves a copy of a scene to an R variable;
\code{\link{writePLY}}, \code{\link{writeOBJ}} and \code{\link{writeSTL}}
write the scene to a file in various other formats.
}
\examples{
plot3d(rnorm(100), rnorm(100), rnorm(100), type="s", col="red")
# This writes a copy into temporary directory 'webGL', and then displays it
filename <- writeWebGL(dir=file.path(tempdir(), "webGL"), 
                       width=500)
if (interactive())
  browseURL(paste0("file://", filename))
}
\keyword{ graphics }
