\name{rgl.getAxisCallback}
\alias{rgl.getAxisCallback}
\title{
Get user-defined axis labelling callbacks.
}
\description{
This function gets a user-defined axis labelling callback in R.
}
\usage{
rgl.getAxisCallback(axis, dev = cur3d(), subscene = currentSubscene3d(dev))
}

\arguments{
  \item{axis}{
Which axis? Can be value from \code{1:3}.
}
  \item{dev, subscene}{
The RGL device and subscene to work with.
}
}
\value{
The callback function.
}
\seealso{\code{\link{setAxisCallbacks}} to
work with \code{\link{rglwidget}}.
} 
\author{
Duncan Murdoch
}
