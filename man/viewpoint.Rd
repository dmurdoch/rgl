\name{rgl.viewpoint}
\alias{rgl.viewpoint}
\title{setup viewpoint}
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
The viewpoint is always set in an orbit around the data model. 
It can be either specified with \code{rgl.viewpoint} or interactively using the pointing device of
your graphics user-interface.
With the pointing device you can use the buttons as follows:

\itemize{
\item{left}{adjust viewpoint position}
\item{middle}{adjust field of view angle}
\item{right or wheel}{adjust zoom factor}
}

}
\examples{

# animated round trip tour

for(i in 1:36) {
  rgl.viewpoint(i*10,i*10/4); 
}

}
\keyword{dynamic}
