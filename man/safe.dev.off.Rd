\name{safe.dev.off}
\alias{safe.dev.off}
\title{
Close graphics device in a safe way.
}
\description{
The \code{\link{dev.off}} function in \pkg{grDevices} doesn't restore
the previous graphics device when called.  This function does.
}
\usage{
safe.dev.off(which = dev.cur(), prev = dev.prev())
}
\arguments{
  \item{which}{
Which device to close.
}
  \item{prev}{
Which device to set as current after closing.
}
}
\details{
This function closes device \code{which} if it is not device 1,
then calls \code{\link{dev.set}(prev)} if there are any devices still
open.
}
\value{
The number and name of the new active device.  It will not 
necessarily be \code{prev} if that device isn't already open.
}
\references{
\url{https://bugs.r-project.org/show_bug.cgi?id=18604}
}
\author{
Duncan Murdoch
}
\examples{
# Open a graphics device
dev.new()
first <- dev.cur()

# Open a second graphics device
dev.new()
second <- dev.cur()
second

# Open another one, and close it using dev.off()
dev.new()
dev.off()
dev.cur() == second # Not the same as second!

# Try again with safe.dev.off()
dev.set(second)
dev.new()
safe.dev.off()
dev.cur() == second

# Close the other two devs
safe.dev.off()
safe.dev.off()
}