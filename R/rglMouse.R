rglMouse <- function(sceneId, 
		     choices = c("trackball", "selecting", 
		     	         "xAxis", "yAxis", "zAxis", 
				 "polar", "zoom", "fov", 
				 "none"),
	             labels = choices,
	             button = 1, 
		     dev = rgl.cur(), 
		     subscene = currentSubscene3d(dev),
	             default = par3d("mouseMode", dev = dev, subscene = subscene)[button]) {
  if (inherits(sceneId, "rglWebGL"))
    widget <- sceneId$elementId
  else
    widget <- as.character(sceneId)
  stopifnot(length(choices) == length(labels))
  stopifnot(length(button == 1) && button %in% 1:3)
  options <- mapply(function(x, y) tags$option(x, value = y), labels, choices,
  		    SIMPLIFY = FALSE)
  for (i in seq_along(choices)) 
    options[[i]] <- tags$option(labels[i], value = choices[i])
  default <- which(choices == default)
  options[[default]] <- tagAppendAttributes(options[[default]], selected = NA)
  changecode <- subst('document.getElementById("%widget%").rglinstance.setMouseMode(this.value, button = %button%, subscene = %subscene%)', 
  		    widget = widget, button = button, subscene = subscene)
  result <- tags$select(tagList(options), onchange = HTML(changecode))
  if (inherits(sceneId, "rglWebGL"))
    browsable(tagList(sceneId, result))
  else
    browsable(result)
}