\name{viewpoint}
\alias{rgl.viewpoint}
\alias{view3d}
\title{Set up viewpoint}
\description{
  Set the viewpoint orientation.
}
\usage{
view3d( theta = 0, phi = 15, ...)
rgl.viewpoint( theta = 0, phi = 15, fov = 60, zoom = 1, 
        scale = par3d("scale"), interactive = TRUE, userMatrix, 
        type = c("userviewpoint", "modelviewpoint") )
}
\arguments{
  \item{theta, phi}{polar coordinates in degrees. \code{theta} rotates round the z axis. \code{phi} rotates round the x axis, from -90 to 90.}
  \item{...}{additional parameters to pass to \code{rgl.viewpoint}}
  \item{fov}{field-of-view angle in degrees}
  \item{zoom}{zoom factor}
  \item{scale}{real length 3 vector specifying the rescaling to apply to each axis}
  \item{interactive}{logical, specifying if interactive navigation is allowed}
  \item{userMatrix}{4x4 matrix specifying user point of view}
  \item{type}{which viewpoint to set?}
}
\details{
The data model can be rotated using the polar coordinates \code{theta}
and \code{phi}.  Alternatively, it can be set in a completely general way using the 4x4 matrix
\code{userMatrix}.  If \code{userMatrix} is specified, \code{theta} and \code{phi} are ignored.

The pointing device of your graphics user-interface can also be used to 
set the viewpoint interactively. With the pointing device the buttons are by default set as follows:

\describe{
\item{left}{adjust viewpoint position}
\item{middle}{adjust field of view angle}
\item{right or wheel}{adjust zoom factor}
}

The user's view can be set with \code{fov} and \code{zoom}.

If the \code{fov} angle is set to 0, a parallel or orthogonal
projection is used. Small non-zero values (e.g. 0.01 or less, but not
0.0) are likely to lead to rendering errors due to OpenGL limitations.

Prior to version 0.94, all of these characteristics were stored in 
one viewpoint object.  With that release the characteristics are split
into those that affect the projection (the user viewpoint) and those that
affect the model (the model viewpoint).  By default, this function
sets both, but the \code{type} argument can be used to limit the effect.

}
\seealso{\code{\link{par3d}}}
\examples{
\dontrun{
# animated round trip tour for 10 seconds

rgl.open()
shade3d(oh3d(), color = "red")

start <- proc.time()[3]
while ((i <- 36*(proc.time()[3] - start)) < 360) {
  rgl.viewpoint(i, i/4); 
}
}
}
\keyword{dynamic}
