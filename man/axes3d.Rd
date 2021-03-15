\name{axes3d}
\alias{axes3d}
\alias{axis3d}
\alias{mtext3d}
\alias{title3d}
\alias{box3d}
\title{ Draw boxes, axes and other text outside the data }
\description{
These functions draw axes, boxes and text outside the range of the data.
\code{axes3d}, \code{box3d} and \code{title3d} are the higher level functions; 
normally the others need not be called directly by users.
}
\usage{
axes3d(edges = "bbox", labels = TRUE, tick = TRUE, nticks = 5, 
	box = FALSE, expand = 1.03, ...)
box3d(...) 
title3d(main = NULL, sub = NULL, xlab = NULL, ylab = NULL, 
	zlab = NULL, line = NA, ...) 
axis3d(edge, at = NULL, labels = TRUE, tick = TRUE, line = 0, 
	pos = NULL, nticks = 5, ...) 
mtext3d(text, edge, line = 0, at = NULL, pos = NA, ...) 
}
\arguments{
  \item{edges}{ a code to describe which edge(s) of the box to use; see Details below }
  \item{labels}{ whether to label the axes, or (for \code{axis3d}) the
  labels to use}
  \item{tick}{ whether to use tick marks }
  \item{nticks}{ suggested number of ticks }
  \item{box}{ draw the full box if \code{"bbox"} axes are used }
  \item{expand}{ how much to expand the box around the data }
  \item{main}{ the main title for the plot }
  \item{sub}{ the subtitle for the plot }
  \item{xlab, ylab, zlab}{ the axis labels for the plot }
  \item{line}{ the ``line'' of the plot margin to draw the label on }
  \item{edge, pos}{ the position at which to draw the axis or text }
  \item{text}{ the text to draw }
  \item{at}{ the value of a coordinate at which to draw the axis }
  \item{\dots}{ additional parameters which are passed to \code{\link{bbox3d}} or \code{\link{material3d}} }
}

\details{
The rectangular prism holding the 3D plot has 12 edges.  They are identified
using 3 character strings.  The first character (`x', `y', or `z') selects 
the direction of the axis.  The next two characters are each `-' or `+',
selecting the lower or upper end of one of the other coordinates.  If only
one or two characters are given, the remaining characters default to `-'.  
For example \code{edge = 'x+'} draws an x-axis at the high level of y and the
low level of z.

By default, \code{axes3d} uses the \code{\link{bbox3d}} function to draw the axes.  
The labels will move so that they do not obscure the data.  Alternatively,
a vector of arguments as described above may be used, in which case
fixed axes are drawn using \code{axis3d}.

If \code{pos} is a numeric vector of length 3, \code{edge} determines
the direction of the axis and the tick marks, and the values of the
other two coordinates in \code{pos} determine the position.  See the
examples.
}
\value{
These functions are called for their side effects.  They return the object IDs of
objects added to the scene.
}
\author{ Duncan Murdoch }

\seealso{Classic graphics functions \code{\link{axis}}, \code{\link{box}},
\code{\link{title}}, \code{\link{mtext}}, and RGL function \code{\link{bbox3d}}.}

\examples{
  open3d()
  points3d(rnorm(10), rnorm(10), rnorm(10))

  # First add standard axes
  axes3d()  

  # and one in the middle (the NA will be ignored, a number would 
  # do as well)
  axis3d('x', pos = c(NA, 0, 0))

  # add titles
  title3d('main', 'sub', 'xlab', 'ylab', 'zlab')

  rgl.bringtotop()
  
  open3d()
  points3d(rnorm(10), rnorm(10), rnorm(10))
  
  # Use fixed axes
  
  axes3d(c('x', 'y', 'z'))
         
  # Put 4 x-axes on the plot
  axes3d(c('x--', 'x-+', 'x+-', 'x++'))         
  
  axis3d('x', pos = c(NA, 0, 0))     
  title3d('main', 'sub', 'xlab', 'ylab', 'zlab')
}


\keyword{dynamic}%-- one or more ...
