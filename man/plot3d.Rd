\name{plot3d}
\alias{plot3d}
\alias{plot3d.default}
\alias{plot3d.mesh3d}
\title{3D Scatterplot}
\description{
Draws a 3D scatterplot.
}
\usage{
plot3d(x, ...)
\method{plot3d}{default}(x, y, z,  
	xlab, ylab, zlab, type = "p", 
	col, size, lwd, radius,
	add = FALSE, aspect = !add, 
	xlim = NULL, ylim = NULL, zlim = NULL, 
	forceClipregion = FALSE, ...)
\method{plot3d}{mesh3d}(x, xlab = "x", ylab = "y", zlab = "z", type = c("shade", "wire", "dots"),
	add = FALSE, aspect = !add, ...)	
}
\arguments{
  \item{x, y, z}{vectors of points to be plotted. Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{xlab, ylab, zlab}{labels for the coordinates.}
  \item{type}{For the default method, a single character indicating the type of item to plot.  
  Supported types are: 'p' for points, 's' for spheres, 
  'l' for lines, 'h' for line segments 
  from \code{z = 0}, and 'n' for nothing.  For the \code{mesh3d} method, one of 
  'shade', 'wire', or 'dots'.  Partial matching is used.
  }
  \item{col}{the color to be used for plotted items.}
  \item{size}{the size for plotted points.}
  \item{lwd}{the line width for plotted items.}
  \item{radius}{the radius of spheres:  see Details below.}
  \item{add}{whether to add the points to an existing plot.}
  \item{aspect}{either a logical indicating whether to adjust the aspect ratio, or a new ratio.}
  \item{xlim, ylim, zlim}{If not \code{NULL}, set clipping
limits for the plot.}
  \item{forceClipregion}{Force a clipping region to be used,
whether or not limits are given.}
  \item{\dots}{additional parameters which will be passed to \code{\link{par3d}}, \code{\link{material3d}}
  or \code{\link{decorate3d}}.}
}
\value{
  \code{plot3d} is called for the side effect of drawing the plot; a vector
  of object IDs is returned.
}
\details{
\code{plot3d} is a partial 3D analogue of plot.default.

Missing values in the data are skipped, as in standard graphics.

If \code{aspect} is \code{TRUE}, aspect ratios of \code{c(1, 1, 1)} are passed to
\code{\link{aspect3d}}.  If \code{FALSE}, no aspect adjustment is done.  In other
cases, the value is passed to \code{\link{aspect3d}}.

With \code{type = "s"}, spheres are drawn centered at the specified locations.
The radius may be controlled by \code{size} (specifying the size relative
to the plot display, with the default \code{size = 3} giving a radius 
about 1/20 of the plot region) or \code{radius} (specifying it on the data scale
if an isometric aspect ratio is chosen, or on an average scale
if not). 
}
\section{Clipping}{
If any of \code{xlim}, \code{ylim} or \code{zlim} are specified,
they should be length two vectors giving lower and upper 
clipping limits for the corresponding coordinate.  \code{NA}
limits will be ignored.

If any clipping limits are given, then the data will be
plotted in a newly created subscene within the current one;
otherwise plotting will take place directly in the current
subscene.  This subscene is named \code{"clipregion"}
in the results.  This may affect the appearance of transparent
objects if some are drawn in the \code{plot3d} call and others after, 
as \pkg{rgl} will not attempt to depth-sort objects if they are
in different subscenes.  It is best to draw all overlapping 
transparent objects in the same subscene.  See the example 
in \code{\link{planes3d}}.  It will also affect the use
of \code{\link{clipplanes3d}}; clipping planes need to be in the 
same subscene as the objects being clipped.

Use \code{forceClipregion = TRUE} to force creation of this 
subscene even without specifying limits. 
}
\author{
  Duncan Murdoch
}
\seealso{
  \code{\link{plot.default}},  
  \code{\link{open3d}}, \code{\link{par3d}}.
  There are  \code{\link{plot3d.function}} and \code{\link{plot3d.deldir}} methods for plotting surfaces.
}
\examples{
  open3d()
  x <- sort(rnorm(1000))
  y <- rnorm(1000)
  z <- rnorm(1000) + atan2(x, y)
  plot3d(x, y, z, col = rainbow(1000))
}
\keyword{dynamic}

