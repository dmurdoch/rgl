\name{rgl.viewpoint}
\alias{rgl.viewpoint}
\title{setup Viewpoint}
\description{
  Set the viewpoint orientation.
}
\usage{
rgl.viewpoint( theta = 0, phi = 15, fov = 60, zoom = 0, interactive = TRUE )
}
\arguments{
  \item{theta,phi}{polar coordinates}
  \item{fov}{field-of-view angle}
  \item{zoom}{zoom factor}
  \item{interactive}{logical, specifying if interactive navigation is allowed}
}
\details{
The viewpoint is always positioned orbiting around the data model. 
It may be specified by using the command or interactively using the pointing device of
your graphics user-interface.
Using the pointing device, you may drag on the device window using the buttons:

\itemize{
\item{left}{adjust viewpoint position}
\item{middle}{adjust field of view angle}
\item{right or wheel}{adjust zoom factor}
}

}
\examples{

# animated round trip tour

for(i in 1:360) {
  rgl.viewpoint(i,i/4); 
}

}
\keyword{dynamic}
