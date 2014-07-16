\name{observer3d}
\alias{observer3d}
\title{
Set the observer location.
}
\description{
This function sets the location of the viewer.
}
\usage{
observer3d(x, y = NULL, z = NULL, auto = FALSE)
}
\arguments{
  \item{x,y,z}{
The location as a 3 vector, using the usual \code{xyz.coords}
conventions for specification.  If \code{x} is missing
or any coordinate is \code{NA}, no change will be made to the
location.  
}
  \item{auto}{ 
If \code{TRUE}, the location will be set 
automatically by \pkg{rgl} to make the whole bounding box visible.
}
}
\details{
This function
sets the location of the viewer relative to the scene, after the model transformations
(scaling, rotation) have been done, but before lighting or projection have been 
applied.  (See \code{\link{par3d}} for details on the rendering pipeline.)

The coordinate system is a slightly strange one:  the X coordinate
moves the observer location from left to right, and the Y coordinate moves up
and down.  The Z coordinate changes the depth from the viewer.  All are measured
relative to the center of the bounding box (\code{par("bbox")}) of the subscene.
The observer always looks in the positive Z direction
after the model rotation have been done.  The coordinates are in post-scaling
units.
}
\note{
This function is likely to change in future versions of \pkg{rgl}, to allow more 
flexibility in the specification of the observer's location and orientation.
}
\value{
Invisibly returns the previous value.
}
\author{
Duncan Murdoch
}

\examples{
example(surface3d)  # The volcano data
observer3d(0,0,440) # Viewed from very close up
}
\keyword{ graphics }
