\name{rgl.select}
\alias{rgl.select}
\title{
Switch to select mode, and return the mouse position selected.
}
\description{
Mostly for internal use, this function temporarily
installs a handler on a button of the mouse that will 
return the mouse coordinates of one click and drag rectangle.
}
\usage{
rgl.select(button = c("left", "middle", "right"),
           dev = rgl.cur(), subscene = currentSubscene3d(dev))
}
\arguments{
  \item{button}{
Which button to use?
}
  \item{dev, subscene}{
The rgl device and subscene to work with  
}
}
\value{
A vector of four coordinates:  the X and Y coordinates of the start and end of the
dragged rectangle.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{rgl.select3d}}, a version that allows the selection region to be used to
select points in the scene.
}
