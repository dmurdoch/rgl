library(shiny)
library(rgl)
library(misc3d)

options(rgl.useNULL = TRUE)
set.seed(123)

u1 <- runif(1)
u2 <- runif(1)*(1-u1)
u3 <- 1 - u1 - u2
# Example modified from ?contour3d
#Example 2: Nested contours of mixture of three tri-variate normal densities
nmix3 <- function(x, y, z, m, s) {
  u1 * dnorm(x, m, s) * dnorm(y, m, s) * dnorm(z, m, s) +
    u2 * dnorm(x, -m, s) * dnorm(y, -m, s) * dnorm(z, -m, s) +
    u3 * dnorm(x, m, s) * dnorm(y, -1.5 * m, s) * dnorm(z, m, s)
}
f <- function(x,y,z) nmix3(x,y,z,.5,.5)
g <- function(n = 40, k = 5, alo = 0.1, ahi = 0.5, cmap = heat.colors) {
  th <- seq(0.05, 0.2, len = k)
  col <- rev(cmap(length(th)))
  al <- seq(alo, ahi, len = length(th))
  x <- seq(-2, 2, len=n)
  bg3d(col="white")
  contour3d(f,th,x,x,x,color=col,alpha=al)
}

f3 <- function(x) -f(x[1], x[2], x[3])

g(20,3)
surface <- scene3d()
rgl.close()

neldermead <- function(x, f) {
  n <- nrow(x)
  p <- ncol(x)

  if (n != p + 1) stop(paste('Need', p + 1, 'starting points'))

  fx <- rep(NA, n)
  for (i in 1:n) fx[i] <- f(x[i,])

  o <- order(fx)
  fx <- fx[o]
  x <- x[o,]
  xmid <- apply(x[1:p,], 2, mean)
  z1 <- xmid - (x[n,] - xmid)
  fz1 <- f(z1)

  if (fz1 < fx[1]) {
    z2 <- xmid - 2*(x[n,] - xmid)
    fz2 <- f(z2)
    if (fz2 < fz1) {
      # cat('Accepted reflection and expansion, f(z2)=',fz2,'\n')
      x[n,] <- z2
    } else {
      # cat('Accepted good reflection, f(z1)=',fz1,'\n')
      x[n,] <- z1
    }
  } else if (fz1 < fx[p]) {
    # cat('Accepted okay reflection, f(z1)=',fz1,'\n')
    x[n,] <- z1
  } else {
    if (fz1 < fx[n]) {
      x[n,] <- z1
      fx[n] <- fz1
    }
    z3 <- xmid + (x[n,] - xmid)/2
    fz3 <- f(z3)
    if (fz3 < fx[n]) {
      # cat('Accepted contraction 1, f(z3)=',fz3,'\n')
      x[n,] <- z3
    } else {
      # cat('Accepted contraction 2,')
      for (i in 2:n) {
        x[i,] <- x[1,] + (x[i,] - x[1,])/2
        # cat(' f(z', i+2, ') = ', f(x[i,]), sep='')
      }
      # cat('\n')
    }
  }
  return(x)
}

showsimplex <- function(x, f, col="blue") {
  n <- nrow(x)
  z <- numeric(n)
  for (i in 1:n) z[i] <- f(x[i,])
  xyz <- cbind(x, z)

  # This is tricky:

  # 1. draw all lines, taking vertices two at a time:
  c(segments3d(xyz[as.numeric(combn(n, 2)),], col="black", depth_test = "lequal"),
    # 2. draw all faces, taking vertices three at a time:
    triangles3d(xyz[as.numeric(combn(n, 3)),], col=col, alpha=0.3))
}

setStartPoint <- function() {
  xyz <- matrix(rnorm(12, sd=0.1) + rep(rnorm(3,sd=2), each=4), 4, 3)
  subsets <-list()
  for (i in 1:60){
    xyz <- neldermead(xyz,f3)
    subset <- showsimplex(xyz,f3)
    subsets <-c(subsets,list(subset))
  }
  names(subsets) <- seq_along(subsets)
  subsets
}

shinyServer(function(input, output, session) {

  plot3d(surface)
  dev <- rgl.cur()
  save <- options(rgl.inShiny = TRUE)
  on.exit(options(save))

  session$onSessionEnded(function() {
    rgl.set(dev)
    rgl.close()
  })

  path <- reactiveValues(subsets = setStartPoint())

  observeEvent(input$newStart, {
    rgl.set(dev)

    deletes <- unique(unlist(path$subsets))

    if (length(deletes))
      delFromSubscene3d(deletes)
    subsets <- setStartPoint()
    adds <- unique(unlist(subsets))
    session$sendCustomMessage("sceneChange",
      sceneChange("thewidget", delete = deletes, add = adds,
                  skipRedraw = TRUE))
    path$subsets <- subsets
    updateSliderInput(session, "Slider", value=1)
    updateSliderInput(session, "Slider2", value=1)
    session$onFlushed(function()
      session$sendCustomMessage("sceneChange",
        sceneChange("thewidget", skipRedraw = FALSE)))
  })

  output$thewidget <- renderRglwidget({
    rglwidget(controllers=c("thecontroller", "thecontroller2"))
  })

  output$thecontroller <-
    renderPlaywidget({
      if (length(path$subsets))
        playwidget("thewidget", respondTo = "Slider",
                   subsetControl(1, path$subsets),
                   start = 1, stop = length(path$subsets))
      })

  output$thecontroller2 <-
    renderPlaywidget({
      if (length(path$subsets))
        playwidget("thewidget", respondTo = "Slider2",
                   subsetControl(1, path$subsets, accumulate = TRUE))
      })
})

