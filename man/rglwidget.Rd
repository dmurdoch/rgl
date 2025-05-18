\name{rglwidget}
\alias{rglwidget}
\alias{rgl.printRglwidget}
\title{
An htmlwidget to hold an RGL scene
}
\description{
The \pkg{htmlwidgets} package provides a framework for embedding
graphical displays in HTML documents of various types.  This function
provides the necessities to embed an RGL scene in one.
}
\usage{
rglwidget(x = scene3d(minimal), width = figWidth(), height = figHeight(),
          controllers = NULL,
          elementId = NULL, 
          reuse = FALSE,
          webGLoptions = list(preserveDrawingBuffer = TRUE), 
          shared = NULL, minimal = TRUE, 
          webgl, snapshot, 
          shinyBrush = NULL, 
          altText = "3D plot",
          ...,
          oldConvertBBox = FALSE,
          fastTransparency = getOption("rgl.fastTransparency", TRUE))
}
\arguments{
  \item{x}{
An RGL scene produced by the \code{\link[rgl]{scene3d}} function.
}
  \item{width, height}{
The width and height of the display in pixels.
}
  \item{controllers}{Names of \code{\link{playwidget}} objects
associated with this scene, or objects (typically piped in).  See Details below.
}
  \item{snapshot,webgl}{Control of mode of display of scene.
  See Details below.
}
  \item{elementId}{The id to use on the HTML \code{div}
component that will hold the scene.
}
  \item{reuse}{Ignored.  See Details below.
}
  \item{webGLoptions}{A list of options to pass
  to WebGL when the drawing context is created.  See the Details below.}
  \item{shared}{An object produced by \code{\link{rglShared}}, or a list of such objects.}
  \item{minimal}{Should attributes be skipped if they currently have
  no effect?  See \code{\link{scene3d}}.}
  \item{shinyBrush}{The name of a Shiny \code{input} element
  to receive information about mouse selections.}
  \item{altText}{Text to include for screen-readers or browsers
  that don't handle WebGL.  See Details below.}
  \item{oldConvertBBox, fastTransparency}{See Details below.}
  \item{...}{Additional arguments
to pass to \code{htmlwidgets::\link[htmlwidgets]{createWidget}}.}
}
\details{
This produces a WebGL version of an RGL scene using the \pkg{htmlwidgets}
framework.  This allows display of the scene in the RStudio IDE, a browser, an \pkg{rmarkdown} document
or in a \pkg{shiny} app.

\code{options(rgl.printRglwidget = TRUE)} will cause
\code{rglwidget()} to be called and displayed
when the result of an RGL call that changes the
scene is printed.

In RMarkdown or in standalone code, you can use a \pkg{magrittr}-style
\dQuote{pipe} command to join an \code{rglwidget} with a
\code{\link{playwidget}} or \code{\link{toggleWidget}}.  If the control widget comes
first, it should be piped into the \code{controllers}
argument.  If the \code{rglwidget} comes first, it
can be piped into the first argument of \code{playwidget} or \code{toggleWidget}.

In earlier versions, the \code{reuse} argument let one output scene share data from earlier ones.  This is no longer supported.

If \code{elementId} is \code{NULL} and we are not in a Shiny app,
\code{elementId} is set to a random value to facilitate re-use
of information.

To save the display to a file, use \code{htmlwidgets::\link[htmlwidgets]{saveWidget}}.
This requires \command{pandoc} to be installed.  
For a snapshot, you can use
\code{htmltools::save_html(img(src=rglwidget(snapshot=TRUE)), file = ...)}.

The \code{webGLoptions} argument is a list which will
be passed when the WebGL context is created.  See
the WebGL 1.0 specification on \url{https://registry.khronos.org/webgl/} for possible
settings.  The default in \code{rglwidget} differs
from the WebGL default by setting \code{preserveDrawingBuffer = TRUE} in order to allow other tools to read
the image, but please note that some implementations
of WebGL contain bugs with this setting.  We have
attempted to work around them, but may change our
default in the future if this proves unsatisfactory.

The \code{webgl} argument controls
whether a dynamic plot is displayed in HTML.  In LaTeX
and some other formats
dynamic plots can't be
displayed, so if the \code{snapshot} argument is \code{TRUE},
\code{webgl} must be \code{FALSE}.  (In previous versions
of the \pkg{rgl} package, both \code{webgl} and \code{snapshot} could be
\code{TRUE}; that hasn't worked for a while and is no longer
allowed as of version 0.105.6.)

The \code{snapshot} argument controls whether a snapshot is
displayed:  it must be \code{!webgl} if both are specified.

Prior to \pkg{rgl} 0.106.21, \code{rglwidget} converted 
bounding box decorations into separate objects: a box, text
for the labels, segments for the ticks.  By default it now
generates these in Javascript, allowing axis labels to move as
they do in the display in \R.  If you prefer the old conversion,
set \code{oldConvertBBox = TRUE}.

In version 1.3.4, the handling of transparent objects was 
changed to match the \pkg{rgl} device more closely.  The new
method of rendering is quite a bit faster, though sometimes 
less accurate.  To get the older drawing method set 
\code{fastTransparency = FALSE}.
}
\section{R Markdown specifics}{
In an R Markdown document, you would normally call
\code{\link{setupKnitr}(autoprint = TRUE)} and would not 
make explicit calls to \code{rglwidget()}.  If you do
make such calls, the graphics will be inserted into the
document. 

In \pkg{knitr} versions greater than 1.42.5,
the \code{altText} argument will be ignored and the alternate
text will be set from chunk option \code{fig.alt} or 
\code{fig.cap} as with other graphics.
}
\section{Shiny specifics}{

This widget is designed to work with Shiny for interactive
displays linked to a server running R.

In a Shiny app, there will often be one or more
\code{\link{playwidget}} objects in the app, taking input from
the user.  In order to be sure that the initial value of the user control
is reflected in the scene, you should list all players in the
\code{controllers} argument.  See the sample application in
\code{system.file("shinyDemo", package = "rglwidget")} for an example.

In Shiny, it is possible to find out information about mouse selections
by specifying the name of an \code{input} item in the
\code{shinyBrush} argument.  For example, with
\code{shinyBrush = "brush3d"}, each change
to the mouse selection will send data to \code{input$brush3d} in an
object of class \code{"rglMouseSelection"} with the
following components:
\describe{
\item{subscene}{The ID of the subscene where the mouse is selecting.}
\item{state}{Either \code{"changing"} or \code{"inactive"}.}
\item{region}{The coordinates of the corners of the selected region in the window,
in order \code{c(x1, y1, x2, y2)}.}
\item{model, proj, view}{The model matrix, projection matrix and viewport in effect at that location.}
}
This object can be used as the first argument to
\code{\link{selectionFunction3d}} to produce a test function for
whether a particular location is in the selected region.  If the 
brush becomes inactive, an object containing only the \code{state}
field will be sent, with value \code{"inactive"}.
}

\value{
An object of class \code{"htmlwidget"} (or \code{"shiny.tag.list"}
if pipes are used) that will intelligently print itself into
HTML in a variety of contexts including the R console, within R Markdown
documents, and within Shiny output bindings.

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
\code{\link{hook_webgl}} for an earlier approach to this problem. \code{\link{rglwidgetOutput}} for Shiny details.  The \HTMLVignette{WebGL}{}{User Interaction in WebGL} vignette
gives more details.
}
\examples{
save <- options(rgl.useNULL=TRUE)
example("plot3d", "rgl")
widget <- rglwidget()
if (interactive() || in_pkgdown_example())
  widget
  
\donttest{
if (interactive() && !in_pkgdown_example()) {
  # Save it to a file.  This requires pandoc
  filename <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(rglwidget(), filename)
  browseURL(filename)
}
}

options(save)
}

