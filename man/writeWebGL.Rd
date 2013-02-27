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
           snapshot = TRUE, font = "Arial", width, height)
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
code necessary to reproduce the current scene.

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
The output includes a binary copy of the CanvasMatrix Javascript library.  Its source contains the following copyright notice:
\preformatted{
/*
 * Copyright (C) 2009 Apple Inc. All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */
}
}
\seealso{
\code{\link{scene3d}} saves a copy of a scene to an R variable;
\code{\link{writePLY}}, \code{\link{writeOBJ}} and \code{\link{writeSTL}}
write the scene to a file in various other formats.
}
\examples{
\donttest{
plot3d(rnorm(100), rnorm(100), rnorm(100), type="s", col="red")
# This writes a copy into temporary directory 'webGL', and then displays it
browseURL(paste("file://", writeWebGL(dir=file.path(tempdir(), "webGL"), 
          width=500), sep=""))
}
}
\keyword{ graphics }
