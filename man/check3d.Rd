\name{.check3d}
\alias{.check3d}
\alias{check3d}
\title{
Check for an open RGL window.
}
\description{
Mostly for internal use, this function returns the current device
number if one exists, or opens a new device and returns that.
}
\usage{
.check3d()
}
\value{
The device number of an RGL device.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{open3d}}
}
\examples{
rgl.dev.list()
.check3d()
rgl.dev.list()
.check3d()
rgl.dev.list()
close3d()
}
