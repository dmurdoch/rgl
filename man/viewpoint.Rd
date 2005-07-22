\name{viewpoint}
\alias{rgl.viewpoint}
\title{setup viewpoint}
\description{
  Set the viewpoint orientation.
}
\usage{
rgl.viewpoint( theta = 0, phi = 15, fov = 60, zoom = 1, interactive = TRUE, userMatrix )
}
\arguments{
  \item{theta,phi}{polar coordinates}
  \item{fov}{field-of-view angle}
  \item{zoom}{zoom factor}
  \item{interactive}{logical, specifying if interactive navigation is allowed}
  \item{userMatrix}{4x4 matrix specifying user point of view}
}
\details{
The viewpoint can be set in an orbit around the data model, using the polar coordinates \code{\theta}
and \code{phi}.  Alternatively, it can be set in a completely general way using the 4x4 matrix
\code{userMatrix}.  If \code{userMatrix} is specified, \code{theta} and \code{phi} are ignored.

The pointing device of your graphics user-interface can also be used to 
set the viewpoint interactively. With the pointing device the buttons are by default set as follows:

\itemize{
\item{left}{adjust viewpoint position}
\item{middle}{adjust field of view angle}
\item{right or wheel}{adjust zoom factor}
}

}
\seealso{\code{\link{par3d}}}
\examples{

# animated round trip tour

for(i in 1:360) {
  rgl.viewpoint(i,i/4); 
}

}
\keyword{dynamic}
