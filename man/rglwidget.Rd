\name{rglwidget}
\alias{rglwidget}
\alias{rgl.printRglwidget}
\title{
An htmlwidget to hold an rgl scene.
}
\description{
The \pkg{htmlwidgets} package provides a framework for embedding
graphical displays in HTML documents of various types.  This function
provides the necessities to embed an \pkg{rgl} scene in one.
}
\usage{
rglwidget(x = scene3d(minimal), width = figWidth(), height = figHeight(),
          controllers = NULL, snapshot = !webgl,
          elementId = NULL, reuse = !interactive(),
          webGLoptions = list(preserveDrawingBuffer = TRUE), 
          shared = NULL, minimal = TRUE, 
          webgl = !latex, latex, ...)
}
\arguments{
  \item{x}{
An \pkg{rgl} scene produced by the \code{\link[rgl]{scene3d}} function.
}
  \item{width, height}{
The width and height of the display in pixels.
}
  \item{controllers}{Names of \code{\link{playwidget}} objects
associated with this scene, or objects (typically piped in).  See Details below.
}
  \item{snapshot,webgl,latex}{Control of mode of display of scene.
  See Details below.
}
  \item{elementId}{The id to use on the HTML \code{div}
component that will hold the scene.
}
  \item{reuse}{A logical variable indicating whether
rgl objects from earlier scenes should be referenced. See
the Details below.
}
  \item{webGLoptions}{A list of options to pass
  to WebGL when the drawing context is created.  See the Details below.}
  \item{shared}{An object produced by \code{\link{rglShared}}, or a list of such objects.}
  \item{minimal}{Should attributes be skipped if they currently have
  no effect?  See \code{\link{scene3d}}.}
  \item{...}{Additional arguments
to pass to \code{htmlwidgets::\link{createWidget}}.}
}
\details{
This produces a WebGL version of an \pkg{rgl} scene using the \pkg{htmlwidgets}
framework.  This allows display of the scene in the RStudio IDE, a browser, an \pkg{rmarkdown} document
or in a \pkg{shiny} app.

\code{options(rgl.printRglwidget = TRUE)} will cause
\code{rglwidget()} to be called and displayed
when the result of an \pkg{rgl} call that changes the
scene is printed.

In a \pkg{shiny} app, there will often be one or more
\code{\link{playwidget}} objects in the app, taking input from
the user.  In order to be sure that the initial value of the user control
is reflected in the scene, you should list all players in the
\code{controllers} argument.  See the sample application in
\code{system.file("shinyDemo", package = "rglwidget")} for an example.

In RMarkdown or in standalone code, you can use a \pkg{magrittr}-style
\dQuote{pipe} command to join an \code{rglwidget} with a
\code{\link{playwidget}} or \code{\link{toggleWidget}}.  If the control widget comes
first, it should be piped into the \code{controllers}
argument.  If the \code{rglwidget} comes first, it
can be piped into the first argument of \code{playwidget} or \code{toggleWidget}.

If the \code{reuse} argument is \code{FALSE} (the default in interactive
use), earlier information will be
cleared before drawing the new scene.  If \code{TRUE}, earlier
data will be re-used in the current scene, so it may be smaller
and faster to load.  In both cases information from the current
scene (added to earlier information if \code{reuse=TRUE}) will
be saved for possible use in a future scene.
If \code{reuse=NA}, the saved information will neither be used
nor updated.

If \code{elementId} is \code{NULL} and we are not in a Shiny app,
\code{elementId} is set to a random value to facilitate re-use
of information.

To save the display to a file, use \code{htmlwidgets::\link{saveWidget}}.  This requires \command{pandoc} to be installed.

The \code{webGLoptions} argument is a list which will
be passed when the WebGL context is created.  See
the WebGL 1.0 specification on \url{https://www.khronos.org/registry/webgl/specs/} for possible
settings.  The default in \code{rglwidget} differs
from the WebGL default by setting \code{preserveDrawingBuffer = TRUE} in order to allow other tools to read
the image, but please note that some implementations
of WebGL contain bugs with this setting.  We have
attempted to work around them, but may change our
default in the future if this proves unsatisfactory.

The default for the \code{latex} argument is \code{TRUE}
if we detect that we are producing LaTeX/PDF output in
\pkg{knitr}, \code{FALSE} otherwise.

The \code{webgl} argument controls
whether a dynamic plot is displayed in HTML.  In LaTeX
dynamic plots can't be
displayed, so if the \code{latex} argument is \code{TRUE},
\code{webgl} defaults to \code{FALSE}.

The \code{snapshot} argument controls whether a snapshot is
displayed:  it can be a logical value
or a character value.  If logical and \code{FALSE},
no snapshot will be included.  If \code{TRUE},
a snapshot will be taken of the scene \code{x}
using \code{\link{snapshot3d}}.  If \code{snapshot}
is a character string starting \code{"data:"}, it
will be assumed to be the result of the \code{\link[knitr]{image_uri}} function.  Otherwise it will be assumed to
be a filename, and \code{\link[knitr]{image_uri}} will be used
to embed it in the output page. 

For HTML output, if both \code{webgl = TRUE} and a snapshot are specified,
both will be included in the output, and the snapshot will
be shown when WebGL is unavailable.  If \code{webgl = FALSE},
only the snapshot will be included.  It's an error to
have both \code{webgl = FALSE} and \code{snapshot = FALSE}.
}
\value{
An object of class \code{"htmlwidget"} (or \code{"shiny.tag.list"}
if pipes are used) that will intelligently print itself into
HTML in a variety of contexts including the R console, within R Markdown
documents, and within Shiny output bindings.

If \code{reuse = TRUE}, a record will be kept of objects in the scene
and they need not be included in the HTML generated for later scenes.
This is normally useful only in \pkg{rmarkdown} documents which can have
many \pkg{rgl} scenes; if the widget is displayed in RStudio,
only one scene will be shown.

If objects are passed in the \code{shared} argument,
then the widget will respond to selection and filtering 
applied to those as shared datasets.  See \code{\link{rglShared}} for more details and an example.
}
\section{Appearance}{
The appearance of the display is set by the stylesheet
in \code{system.file("htmlwidgets/lib/rglClass/rgl.css")}.

The widget is of class \code{rglWebGL}, with id
set according to \code{elementId}.  (As of this writing,
no special settings are given for class \code{rglWebGL},
but you can add your own.)
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{hook_webgl}} for an earlier approach to this problem. \code{\link{rglwidgetOutput}} for Shiny details.
}
\examples{
save <- getOption("rgl.useNULL")
options(rgl.useNULL=TRUE)
example("plot3d", "rgl")
widget <- rglwidget()
if (interactive())
  widget
  
\donttest{
# Save it to a file.  This requires pandoc
filename <- tempfile(fileext = ".html")
htmlwidgets::saveWidget(rglwidget(), filename)
browseURL(filename)
}
}

