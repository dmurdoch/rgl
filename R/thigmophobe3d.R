thigmophobe3d <- function(x, y = NULL, z = NULL, 
                          P = par3d("projMatrix"),
                          M = par3d("modelMatrix"),
                          windowRect = par3d("windowRect")) {
  if (!requireNamespace("plotrix") || packageVersion("plotrix") < "3.7-3") 
    stop("This function requires the plotrix package, version 3.7-3 or higher.")
  
  xyz <- xyz.coords(x, y, z)
  
  pts3d <- rbind(xyz$x, xyz$y, xyz$z, 1)
  pts2d <- asEuclidean(t(P %*% M %*% pts3d))
  w <- diff(windowRect[c(1,3)])
  h <- diff(windowRect[c(2,4)])
  pts2d <- cbind(w*pts2d[,1], h*pts2d[,2])
  
  if (packageVersion("plotrix") < "3.7.6")
    plotrix::thigmophobe(pts2d, plot.span = c(-w, w, -h, h),
                         xlog = FALSE, ylog = FALSE)  
  else
    plotrix::thigmophobe(pts2d, usr = c(-w, w, -h, h),
                     xlog = FALSE, ylog = FALSE,
                     pin = c(w, h)/50) # This doesn't seem to matter...
}
