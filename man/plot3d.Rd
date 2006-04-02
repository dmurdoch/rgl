\name{plot3d}
\alias{plot3d}
\alias{plot3d.default}
\title{3D Scatterplot}
\description{
Draws a 3D scatterplot.
}
\usage{
plot3d(x, ...)
\method{plot3d}{default}(x, y, z, xlim, ylim, zlim, 
	xlab, ylab, zlab, type = 'p', col,  
	box, axes = TRUE, add = FALSE, main, sub, 
	top = TRUE, aspect = !add, ...)
}
\arguments{
  \item{x, y, z}{vectors of points to be plotted. Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{xlim, ylim, zlim}{limits to use for the coordinates.}
  \item{xlab, ylab, zlab}{labels for the coordinates.}
  \item{type}{a single character indicating the type of item to plot.  
  Supported types are: 'p' for points, 'l' for lines, 'h' for line segments
  from \code{z=0}, and 'n' for nothing.}
  \item{main, sub}{main title and subtitle.}
  \item{col}{the colour to be used for plotted items.}
  \item{box, axes}{whether to draw a box and axes.}
  \item{add}{whether to add the points to an existing plot.}
  \item{top}{whether to bring the window to the top when done.}
  \item{aspect}{either a logical indicating whether to adjust the aspect ratio, or a new ratio}
  \item{\dots}{additional parameters which will be passed to \code{\link{par3d}}}.
}
\value{
  the 3D handle for the item that was plotted.
}
\details{
This is a partial 3D analogue of plot.default.

Note that since \code{rgl} does not currently support
clipping, all points will be plotted, and \code{xlim}, \code{ylim}, and \code{zlim}
will only be used to increase the respective ranges.

No rescaling of points will be done, so if the variables are on widely differing scales,
a long thin or flat plot region may result.

Missing values in the data are not currently supported.

If \code{aspect} is \code{TRUE}, aspect ratios of \code{c(1,1,1)} are passed to
\code{\link{aspect3d}}.  If \code{FALSE}, no aspect adjustment is done.  In other
cases, the value is passed to \code{\link{aspect3d}}.

}
\author{
  Duncan Murdoch
}
\seealso{
  \code{\link{plot.default}},  
  \code{\link{open3d}}, \code{\link{par3d}}.
}
\examples{
  open3d()
  x <- sort(rnorm(1000))
  y <- rnorm(1000)
  z <- rnorm(1000) + atan2(x,y)
  plot3d(x, y, z, col=rainbow(1000), size=2)
}
\keyword{dynamic}

