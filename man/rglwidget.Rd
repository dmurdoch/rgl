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
rglwidget(x = scene3d(), width = NULL, height = NULL,
          controllers = NULL, snapshot = FALSE,
          elementId = NULL, reuse = !interactive(),
          webGLoptions = list(preserveDrawingBuffer = TRUE), ...)
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
  \item{snapshot}{Control of snapshot of scene.  See
\code{\link{writeWebGL}} for details.
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
the WebGL 1.0 specification on \url{https://www.khronos.org/registry/webgl/specs} for possible
settings.  The default in \code{rglwidget} differs
from the WebGL default by setting \code{preserveDrawingBuffer = TRUE} in order to allow other tools to read
the image, but please note that some implementations
of WebGL contain bugs with this setting.  We have
attempted to work around them, but may change our
default in the future if this proves unsatisfactory.
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
\code{\link[rgl]{hook_webgl}} for an earlier approach to this problem. \code{\link{rglwidgetOutput}} for Shiny details.
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

