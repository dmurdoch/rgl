\name{observer3d}
\alias{observer3d}
\title{
Set the observer location.
}
\description{
This function sets the location of the viewer.
}
\usage{
observer3d(x, y=NULL, z=NULL)
}
\arguments{
  \item{x,y,z}{
The location as a 3 vector, using the usual \code{xyz.coords}
conventions for specification.  If \code{x} is missing
or any coordinate is \code{NA}, \pkg{rgl}
will set the location to make the whole scene visible.
}
}
\details{
See \code{\link{par3d}} for details on the rendering pipeline.  This function
sets the location of the viewer relative to the scene, after the model transformations
(scaling, rotation) have been done, but before lighting or projection have been 
applied.  The coordinate system is a slightly strange one:  the X coordinate
moves the observer location from left to right, and the Y coordinate moves up
and down.  The Z coordinate changes the depth from the viewer.  All are measured
relative to the center of the bounding box (\code{par("bbox")}) of the scene,
after the scaling and rotation have been done.
}
\value{
No useful value is returned; the function is called for the side effect
of changing the viewpoint.
}
\author{
Duncan Murdoch
}

\examples{
example(surface3d)  # The volcano data
observer3d(0,0,440) # Viewed from very close up
}
\keyword{ graphics }
