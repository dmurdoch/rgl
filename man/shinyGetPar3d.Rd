\name{shinyGetPar3d}
\alias{shinyGetPar3d}
\alias{shinySetPar3d}
\alias{shinyResetBrush}
\title{
Communicate RGL parameters between R and Javascript in Shiny
}
\description{
These functions allow Shiny apps to read and write the \code{par3d}
settings that may have been modified by user interaction in the browser.

}
\usage{
shinyGetPar3d(parameters, session, subscene = currentSubscene3d(cur3d()), tag = "")
shinySetPar3d(..., session, subscene = currentSubscene3d(cur3d()))
shinyResetBrush(session, brush)
}
\arguments{
  \item{parameters}{
A character vector naming the parameters to get.
}
  \item{session}{
The Shiny session object.
}
  \item{subscene}{
The subscene to which the parameters apply.  Defaults to 
the currently active subscene in the R session.
}
  \item{tag}{
An arbitrary string or value which will be sent as part of the
response.
}
  \item{...}{
A number of \code{name = value} pairs to be modified, or a
single named list of parameters.  Entries named \code{tag}
or \code{subscene} will be ignored.
  }
  \item{brush}{The name of a Shiny input element corresponding to
  the \code{shinyBrush} argument to \code{\link{rglwidget}}.}
}
\details{
Requesting information from the browser is a complicated process.
The \code{shinyGetPar3d} function doesn't return the requested value,
it just submits a request for the value to be returned later in
\code{input$par3d}, a reactive input.  No action will result
except when a reactive observer depends on \code{input$par3d}.
See the example code below.

The \code{shinySetPar3d} function sends a message to the browser
asking it to change a particular parameter.  The change will be
made immediately, without sending the full scene to the browser,
so should be reasonably fast.
}
\value{
These functions are called for their side effects, and don't return
useful values.

The side effect of \code{shinyGetPar3d} is to cause \code{input$par3d}
to be updated sometime later.  
Besides the requested parameter values, \code{input$par3d} will
contain a copy of the \code{subscene} and \code{tag} arguments.

The side effect of \code{shinySetPar3d} is to send a message to the
browser to update its copy of the \code{par3d} parameters 
immediately.
}
\note{
R and the browser don't maintain a perfect match between the way
parameters are stored internally.  The browser version of parameters
will be returned by \code{shinyGetPar3d} and should be supplied to
\code{shinySetPar3d}.
}
\references{
\url{https://shiny.rstudio.com/articles/communicating-with-js.html}
describes the underlying mechanisms used by these two functions.
}
\seealso{The \code{\link{rglwidget}} argument \code{shinySelectionInput} allows information about mouse selections
to be returned to R.}
\author{
Duncan Murdoch
}

\examples{
if (interactive() && !in_pkgdown_example()) {
  save <- options(rgl.useNULL = TRUE)

  xyz <- matrix(rnorm(300), ncol = 3)

  app = shiny::shinyApp(
    ui = shiny::bootstrapPage(
      shiny::actionButton("redraw", "Redraw"),
      rglwidgetOutput("rglPlot")
    ),
    server = function(input, output, session) {
      # This waits until the user to click on the "redraw" 
      # button, then sends a request for the current userMatrix
      shiny::observeEvent(input$redraw, {
        shinyGetPar3d("userMatrix", session)
      })
    
      # This draws the plot whenever input$par3d changes,
      # i.e. whenever a response to the request above is
      # received.
      output$rglPlot <- renderRglwidget({
        if (length(rgl.dev.list())) close3d()
        col <- sample(colors(), 1)
        plot3d(xyz, col = col, type = "s", main = col)
        par3d(userMatrix = input$par3d$userMatrix)
        rglwidget()
      })
    })
  shiny::runApp(app)
  options(save)
}
}
