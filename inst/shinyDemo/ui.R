library(shiny)

shinyUI(fluidPage(
  registerSceneChange(),
  titlePanel("Nelder-Mead"),
  sidebarLayout(
    sidebarPanel(
      helpText("The Nelder-Mead algorithm evaluates the function",
               "on the vertices of a simplex.  At each step it",
               "moves one vertex of the simplex to a better value."),
      sliderInput("Slider", min=1, max=60, step=1, value=1, label="Steps",
                animate=animationOptions(200, loop=TRUE)),
      sliderInput("Slider2", min=1, max=60, step=1, value=1, label="Cumulative",
                  animate=animationOptions(200, loop=TRUE)),
      playwidgetOutput('thecontroller'),
      playwidgetOutput('thecontroller2'),
      actionButton('newStart', 'Restart')),
    mainPanel(
      rglwidgetOutput('thewidget', width = "100%", height = 512))
  )
))
