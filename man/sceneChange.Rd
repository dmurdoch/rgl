\name{sceneChange}
\alias{sceneChange}
\alias{registerSceneChange}
\title{
Make large change to a scene from Shiny
}
\description{
These functions allow Shiny apps to make relatively large changes
to a scene, adding and removing objects from it.
}
\usage{
sceneChange(elementId, x = scene3d(),
            delete = NULL, add = NULL, replace = NULL,
            material = FALSE, rootSubscene = FALSE,
            delfromSubscenes = NULL, skipRedraw = FALSE)
registerSceneChange()
}
\arguments{
  \item{elementId}{
The id of the element holding the \code{rglClass} instance.
}
  \item{x}{
The new scene to use as a source for objects to add.
}
  \item{delete, add, replace}{
Object ids to modify in the scene.  The \code{delete} and
\code{replace} ids must be present in the old scene in the browser;
the \code{add} and \code{replace} ids must be present in \code{x}.
}
  \item{material}{
Logical to indicate whether default material should be updated.
}
  \item{rootSubscene}{
Logical to indicate whether root subscene should be updated.
}
  \item{delfromSubscenes}{
A vector of subscene ids that may have been changed by
deletions.  By default, all subscenes in \code{x} are used,
but the objects may be included in subscenes in the browser
that are different.
}
  \item{skipRedraw}{
If \code{TRUE}, stop the scene from redrawing until \code{skipRedraw=FALSE} is sent.  If \code{NA}, don't redraw this time, but don't
change the state of the \code{skipRedraw} flag.
}
}
\details{
\code{registerSceneChange} must be called in the UI component
of a Shiny app to register the \code{"sceneChange"} custom
message.
}
\value{
\code{registerSceneChange} returns the HTML code to register the
message.

\code{sceneChange} returns a list to be used as the \code{"sceneChange"}
message to change the scene.  Use
\code{\link[shiny:session]{shiny::session$sendCustomMessage}} to send it.
}

\author{
Duncan Murdoch
}
\seealso{
\code{\link{playwidget}} for a different approach to modifying
scenes that can be much faster, but may be less flexible.  The
Shiny demo in this package makes use of all of these approaches.
}
\examples{
\dontrun{
shinyUI(fluidPage(
  registerSceneChange(),
  actionButton("thebutton", "Change")
))

shinyServer(function(input, output, session) {
  observeEvent(input$thebutton, {
    session$sendCustomMessage("sceneChange",
      sceneChange("thewidget", delete = deletes, add = adds))
  })
})
}
}
