\name{identify3d}
\alias{identify3d}
\title{
Identify points in plot.
}
\description{
Identify points in a plot, similarly to the \code{\link{identify}} function
in base graphics.
}
\usage{
identify3d(x, y = NULL, z = NULL, labels = seq_along(x), n = length(x), 
           plot = TRUE, adj = c(-0.1, 0.5), tolerance = 20, 
           buttons = c("right", "middle"))
}
\arguments{
  \item{x, y, z}{coordinates of points in a scatter plot.  Alternatively, any
    object which defines coordinates (see \code{\link{xyz.coords}}) 
    can be given as \code{x}, and \code{y} and \code{z} left missing.}
  \item{labels}{an optional character vector giving labels for the
    points.  Will be coerced using \code{\link{as.character}}, and
    recycled if necessary to the length of \code{x}.}
  \item{n}{the maximum number of points to be identified.}
  \item{plot}{logical: if \code{plot} is \code{TRUE}, the labels are
    printed near the points and if \code{FALSE} they are omitted.}
  \item{adj}{numeric vector to use as \code{adj} parameter to 
    \code{\link{text3d}} when plotting the labels.}
  \item{tolerance}{the maximal distance (in pixels) 
    for the pointer to be \sQuote{close enough} to a point.}
  \item{buttons}{a length 1 or 2 character vector giving the buttons
    to use for selection and quitting.}
}
\details{
If \code{buttons} is length 1, the user can quit by reaching \code{n}
selections, or by hitting the 
escape key, but the result will be lost if escape is used.
}
\value{
A vector of selected indices.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{identify}} for base graphics, \code{\link{select3d}} for selecting regions.
}
\keyword{ graphics }
