\name{rgl.incrementID}
\alias{rgl.incrementID}
\title{
Increment ID
}
\description{
This function is mainly for internal use.  It simply 
increments the internal object ID number and returns
the new value.  Negative values have no effect.
}
\usage{
rgl.incrementID(n = 1L)
}
\arguments{
  \item{n}{
An integer increment to use.
}
}
\value{
The resulting ID value.
}
\examples{
# Get the current ID value
rgl.incrementID(0)

# Increment it
rgl.incrementID()
}