rglMouse <- function(sceneId, 
		     choices = c("trackball", "selecting", 
		     	         "xAxis", "yAxis", "zAxis", 
				 "polar", "zoom", "fov", 
				 "none"),
	             labels = choices,
	             button = 1, 
		     dev = rgl.cur(), 
		     subscene = currentSubscene3d(dev),
	             default = par3d("mouseMode", dev = dev, subscene = subscene)[button],
		     stayActive = FALSE,
		     ...) {
  stopifnot(length(choices) == length(labels))
  stopifnot(length(button == 1) && button %in% 1:3)
  options <- mapply(function(x, y) tags$option(x, value = y), labels, choices,
  		    SIMPLIFY = FALSE)
  for (i in seq_along(choices)) 
    options[[i]] <- tags$option(labels[i], value = choices[i])
  default <- which(choices == default)
  options[[default]] <- tagAppendAttributes(options[[default]], selected = NA)
  changecode <- 'document.getElementById(this.attributes.rglSceneId.value).rglinstance.
                   setMouseMode(this.value, 
                                button = parseInt(this.attributes.rglButton.value), 
                                subscene = parseInt(this.attributes.rglSubscene.value),
                                stayActive = parseInt(this.attributes.rglStayActive.value))' 
  result <- tags$select(tagList(options), 
  		        onchange = HTML(changecode), 
  		        rglButton = button,
  		        rglSubscene = subscene,
  		        rglStayActive = as.numeric(stayActive),
  		        ...)
  
  if (!missing(sceneId)) {
    if (inherits(sceneId, "rglWebGL"))
      result <- tagAppendAttributes(result, rglSceneId = sceneId$elementId)
    else if (inherits(sceneId, "shiny.tag.list")) {
      for (i in rev(seq_along(sceneId))) {
      	tag <- sceneId[[i]]
      	if (inherits(tag, "rglWebGL")) {
      	  result <- tagAppendAttributes(result, rglSceneId = tag$elementId)
      	  break;
      	}
      }
    } else
      result <- tagAppendAttributes(result, rglSceneId = sceneId)
  } else
    sceneId <- ""
  
  if (is.character(sceneId))
    browsable(result)
  else
    browsable(tagList(sceneId, result))
}