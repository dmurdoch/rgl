tkpar3dsave <- function(params = c("userMatrix", "scale", "zoom", "FOV"), 
                        times = FALSE, 
                        dev = cur3d(),
                        ...) {
  
  if (!requireNamespace("tcltk", quietly = TRUE))
    stop("This function requires 'tcltk'")
  
  results <- list()
  for (n in params) results[[n]] <- list()
  if (times) {
    start <- proc.time()[3]
    results$times <- numeric(0)
  }
  
  RecordParms <- function() {
    values <- par3d(params)
    if (length(params) == 1) {
      values <- list(values)
      names(values) <- params
    }
    for (n in params) results[[n]] <<- c(results[[n]], list(values[[n]]))
    if (times) results$times <<- c(results$times, proc.time()[3] - start)
  }	
  base <- tcltk::tktoplevel(...)
  tcltk::tkwm.title(base, "par3d")
  
  text <- tcltk::tklabel(base, text="Click on Record to save par3d parameters.",
                         justify="left",
                         wraplength="2i")
  frame <- tcltk::tkframe(base)	
  save <- tcltk::tkbutton(frame, text="Record", command=RecordParms)		
  
  quit <- tcltk::tkbutton(frame,text="Quit", command=function()tcltk::tkdestroy(base))
  
  tcltk::tkpack(save, quit, side="left")
  tcltk::tkpack(text, frame)
  
  tcltk::tkwait.window(base)
  
  results
}
