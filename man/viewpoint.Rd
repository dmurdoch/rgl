\name{viewpoint}
\alias{rgl.viewpoint}
\alias{view3d}
\title{Set up viewpoint}
\description{
  Set the viewpoint orientation.
}
\usage{
view3d( theta = 0, phi = 15, ...)
rgl.viewpoint( theta = 0, phi = 15, fov = 60, zoom = 1, scale = par3d("scale"), 
               interactive = TRUE, userMatrix )
}
\arguments{
  \item{theta,phi}{polar coordinates}
  \item{...}{additional parameters to pass to \code{rgl.viewpoint}}
  \item{fov}{field-of-view angle}
  \item{zoom}{zoom factor}
  \item{scale}{real length 3 vector specifying the rescaling to apply to each axis}
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
\dontrun{
# animated round trip tour for 10 seconds

rgl.open()
shade3d(oh3d(), color="red")

start <- proc.time()[3]
while ((i <- 36*(proc.time()[3]-start)) < 360) {
  rgl.viewpoint(i,i/4); 
}
}
}
\keyword{dynamic}
