
library(shiny)
library(rgl)

open3d(useNULL = TRUE)
ids <- plot3d(rnorm(100), rnorm(100), rnorm(100))[1]
scene <- scene3d()
rgl.close()

ui <- (fluidPage(
	checkboxInput("chk", label = "Display", value = FALSE),
	playwidgetOutput("control"),
	rglwidgetOutput("wdg")
))

server <- function(input, output, session) {
	options(rgl.useNULL = TRUE)
	save <- options(rgl.inShiny = TRUE)
	on.exit(options(save))
	
	output$wdg <- renderRglwidget({
		rglwidget(scene, controllers = c("control"))
	})
	
	output$control <- renderPlaywidget({
		toggleWidget("wdg", respondTo = "chk",
			     ids = ids)
	})
}

if (interactive())
  shinyApp(ui = ui, server = server)
