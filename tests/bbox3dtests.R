# Tests of bbox3d improvements

library(rgl)

x <- cube3d(col="red", front="culled", back="filled"); open3d(); shade3d(x); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=FALSE,draw_front=TRUE); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=TRUE); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=TRUE, front="lines", back = "lines"); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=TRUE, front="lines", back = "lines"); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=TRUE, front="lines", back = "filled"); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=FALSE, front="lines", back = "lines"); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=FALSE, front="filled", back = "culled"); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=FALSE, front="culled", back = "filled"); rglwidget()


open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=FALSE,draw_front=FALSE); rglwidget()

open3d();points3d(1:10, 11:20, 21:30); bbox3d(col="red", lit=TRUE,draw_front=FALSE); rglwidget()

example(bbox3d); rglwidget()

open3d(); spheres3d(rnorm(10), rnorm(10), rnorm(10), 
                    radius = runif(10), color = rainbow(10)); rglwidget()

open3d(); spheres3d(rnorm(10), rnorm(10), rnorm(10), 
                    radius = runif(10), color = rainbow(10),
                    front = "lines", back="culled"); rglwidget()
