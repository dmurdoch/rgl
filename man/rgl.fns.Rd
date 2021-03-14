\name{rgl.fns}
\alias{rgl.abclines}
\title{
Low level functions that should not be called by users.
}
\description{
These functions provide the implementation for various
\code{*3d} functions designed for users to call.
}
\usage{
rgl.abclines(x, y = NULL, z = NULL, a, b = NULL, c = NULL, ...)
}
\arguments{
  \item{x, y, z}{
Coordinates of points
} 
  \item{a, b, c}{
Coordinates of the direction vectors for the lines.
}
  \item{...}{
Material properties.
}

}
\details{
See the corresponding \code{*3d} function: \code{\link{abclines3d}}.
}
\keyword{internal}