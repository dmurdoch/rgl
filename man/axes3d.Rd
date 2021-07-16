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
	zlab = NULL, line = NA, level = NA, floating = NULL, ...) 
axis3d(edge, at = NULL, labels = TRUE, tick = TRUE, line = 0, 
	pos = NULL, nticks = 5, ...) 
mtext3d(text, edge, at = NULL, line = 0, level = 0, 
        floating = FALSE, pos = NA, ...) 
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
  \item{line, level}{ the "line" of the plot margin to draw the label on, and "level" above or below it  }
  \item{floating}{ which mode of axis labels? One of 
  \code{TRUE}, \code{FALSE} or \code{NA}. (\code{NULL}
  may also be used in \code{title3d} calls).
  See Details for how these are handled.}
  \item{edge, pos}{ the position at which to draw the axis or text }
  \item{text}{ the text to draw }
  \item{at}{ the value of a coordinate at which to draw the axis or labels. }
  \item{\dots}{ additional parameters which are passed to \code{\link{bbox3d}} or \code{\link{material3d}} }
}

\details{
The rectangular prism holding the 3D plot has 12 edges.  They are identified
using 3 character strings.  The first character (`x', `y', or `z') selects 
the direction of the axis.  The next two characters are each `-' or `+',
selecting the lower or upper end of one of the other coordinates.  If only
one or two characters are given, the remaining characters normally default to `-' (but with \code{mtext3d(..., floating = TRUE)} the default is `+'; see below).  
For example \code{edge = 'x+'} draws an x-axis at the high level of y and the
low level of z.

By default, \code{axes3d} uses the \code{\link{bbox3d}} function to draw the axes.  
The labels will move so that they do not obscure the data.  Alternatively,
a vector of arguments as described above may be used, in which case
fixed axes are drawn using \code{axis3d}.

As of \pkg{rgl} version 0.106.21, axis drawing has changed
significantly.  Text drawn in the margins 
will
adapt to the margins (see \code{\link{bbox3d}}).  The
\code{edge} and \code{floating} parameters will be recorded
in the \code{margin} and \code{floating} material
properties for the object.

If \code{floating = FALSE}, they will be drawn on the
specified edge.  

If \code{floating = TRUE}, they will
move as the axis labels move when the scene is rotated.
The signs on the edge specification are interpreted as
agreeing with the axis ticks `+' or disagreeing `-'.
For example, \code{"x++"} will draw text on the x axis
in the same edge as the ticks, while \code{"x--"} will draw
on the opposite edge.

The final possible value for \code{floating} in \code{mtext3d} is
\code{NA}, which reproduces legacy \pkg{rgl}
behaviour.  In
this case the labels are not tied to the bounding box,
so they should be drawn last, or they could appear inside
the box, overlapping the data.

In \code{title3d} \code{floating = NULL} (the default) 
indicates the main title 
and subtitle will be fixed while the axis labels will be
floating.  The default locations for title and subtitle
are \code{line = 2} and 
\code{level = 2} on edges \code{"x++"} and \code{"x--"}
respectively.  The axis labels float at \code{line = 4} and \code{level = 1} on the same edge as the ticks.

The \code{at} parameter in \code{axis3d} is the location
of the ticks, defaulting to \code{\link{pretty}} locations.
In \code{mtext3d} the \code{at} parameter is the location
on the specified axis
at which to draw the text, defaulting to the middle of the
bounding box.

The \code{line} parameter is the line counting out
from the box in the same direction as the axis ticks,
and \code{level} is the line out in the orthogonal
direction.  The ticks run from \code{line = 0} to \code{line = 1}, and the
tick labels are drawn at \code{line = 2}.  Both are drawn at level 0.  

The \code{pos} parameter is only supported in legacy mode.  If it is a numeric vector of length 3, \code{edge} determines
the direction of the axis and the tick marks, and the values of the
other two coordinates in \code{pos} determine the position.  
The \code{level} parameter is ignored in legacy mode.

For \code{mtext3d} in \code{floating = TRUE} or \code{floating = FALSE} mode,
there are 3 special values for the \code{at} parameter: it may
be \code{-Inf}, \code{NA} or \code{+Inf}, referring 
to the bottom, middle or top of the given axis respectively.
}
\note{\code{mtext3d} is a wrapper for \code{\link{text3d}}
that sets the \code{margin} and \code{floating} material
properties.  In fact, these properties can be set for many
kinds of objects (most kinds where it would make sense), 
with the effect that the object will be drawn
in the margin, with \code{x} coordinate corresponding to
\code{at}, \code{y} corresponding to \code{line}, and \code{z}
corresponding to \code{level}.

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
