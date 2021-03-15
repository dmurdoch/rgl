\name{turn3d}
\alias{turn3d}
\title{
Create a solid of rotation from a two-dimensional curve
}
\description{
This function \dQuote{turns} the curve (as on a lathe) to form a 
solid of rotation along the x axis.
}
\usage{
turn3d(x, y = NULL, n = 12, smooth = FALSE, ...)
}
\arguments{
  \item{x, y}{
Points on the curve, in a form suitable for \code{\link{xy.coords}}.
The \code{y} values must be non-negative.
}
  \item{n}{
How many steps in the rotation?
}
  \item{smooth}{
logical; whether to add normals for a smooth appearance.
}
  \item{...}{
Additional parameters to pass to \code{\link{tmesh3d}}.
}
}
\value{
A mesh object containing triangles and/or quadrilaterals.
}
\author{
Fang He and Duncan Murdoch
}
\seealso{
\code{\link{extrude3d}}
}
\examples{
x <- 1:10
y <- rnorm(10)^2
shade3d(turn3d(x, y), col = "green")
}
\keyword{ graphics }
