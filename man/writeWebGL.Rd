\name{writeWebGL}
\alias{writeWebGL}
\title{
Write scene to HTML.
}
\description{
Obsolete function to write the current scene to a collection of files that contain WebGL code to reproduce
it in a browser.  Please use \code{\link{rglwidget}} instead.
}
\usage{
writeWebGL(dir = "webGL", filename = file.path(dir, "index.html"), 
           template = system.file(file.path("WebGL", "template.html"), package = "rgl"),
           prefix = "",
           snapshot = TRUE, commonParts = TRUE, reuse = NULL, 
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
  Whether to include a snapshot of the scene, to be displayed in browsers that don't support WebGL, or
a specification of the snapshot to use.  See
details below.
}
  \item{commonParts}{
  Whether to include parts that would be common to several
figures on the same page.  Currently this includes
a reference to and copy of the \file{CanvasMatrix.js}
file in the output.
}
  \item{reuse}{
  When writing several figures on the same page, set this
to a dataframe containing values to reuse.  See the Value section below.
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
This obsolete function writes out a web page containing Javascript that reconstructs the scene in WebGL.  It will
be formally deprecated in an upcoming release; you should use
\code{\link{rglwidget}} instead in any new code, and start
migrating old code there.

The remaining documentation has been removed to discourage 
use of this function.
}
\value{
The \code{filename} is returned.
}
\author{
Duncan Murdoch.
}
\note{
If \code{commonParts} is \code{TRUE}, the output includes a binary copy of
the CanvasMatrix Javascript library.  
Its source (including 
the copyright notice and license for free use) is included in the file named by
\code{system.file("htmlwidgets/lib/CanvasMatrix.src.js", package = "rgl")}.  
}
\seealso{
\code{\link{rglwidget}} should be used instead of \code{writeWebGL}.  Other functions which are related:
\code{\link{scene3d}} saves a copy of a scene to an R variable; \code{\link{writeASY}},
\code{\link{writePLY}}, \code{\link{writeOBJ}} and \code{\link{writeSTL}}
write the scene to a file in various other formats.
}
