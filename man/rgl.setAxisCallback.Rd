\name{rgl.setAxisCallback}
\alias{rgl.setAxisCallback}
\alias{rgl.getAxisCallback}
\title{
User-defined axis labelling callbacks.
}
\description{
These are low level functions to set or get user-defined axis labelling callbacks in R.
}
\usage{
rgl.setAxisCallback(axis, draw = NULL, 
                    dev = cur3d(), subscene = currentSubscene3d(dev))
rgl.getAxisCallback(axis, dev = cur3d(), subscene = currentSubscene3d(dev))
}

\arguments{
  \item{axis}{
Which axis? Can be value from \code{1:3}.
}
  \item{draw}{
The function to draw the axis.  See Details below.
}
  \item{dev, subscene}{
The RGL device and subscene to work with.
}
}
\details{
This function only works if a bounding box decoration 
(set by \code{\link{bbox3d}}, for example) exists.  When it
tries to label the axis specified in \code{rgl.setAxisCallback},
it will call \code{draw}, which is assumed to be a function
with header \code{function(margin)}.  

The \code{margin}
argument will be a single string like \code{"x++"}, indicating
that RGL is drawing the x axis, and suggests putting it on the
edge represented by the high values of the other two axes.
The function may use \code{\link{par3d}("bbox")} to determine 
the current size of the bounding box and should draw an
appropriate axis.  See \code{\link{mtext3d}} for a discussion
of drawing in the margins.

The box outlining the plot region will always be drawn, but
can be made invisible by setting \code{front = "cull", back = "cull"} in the call to \code{\link{bbox3d}}.
}
\value{
Called for the side effect of setting the callback.  The set
function returns
\code{NULL} invisibly.
}
\seealso{\code{\link{setAxisCallbacks}} to
work with \code{\link{rglwidget}}.
} 
\author{
Duncan Murdoch
}

\examples{
datelabels <- local({

  id <- 0
  bbox <- NULL
  
function(margin) {
  # Only need to redraw when the bbox changes
  if (!identical(bbox, par3d("bbox"))) {
    if (id > 0)
      pop3d(id = id)
    axis <- match(substr(margin, 1, 1), c("x", "y", "z"))
    range <- as.Date(par3d("bbox")[2*axis + (-1):0],
                          origin = "1970-01-01")
    where <- pretty(range)  
    where <- where[range[1] <= where & where <= range[2]]
    id <<- mtext3d(format(where, format="\%b \%d"), margin, at = where, line = 1)
    bbox <<- par3d("bbox")
  }
}
})

# This doesn't work in WebGL displays

if (!in_pkgdown_example()) {
  xyz <- cbind(Sys.Date() + rnorm(10, mean = 10),
               rnorm(10), rnorm(10))
  open3d()
  # The default plots dates numerically:
  plot3d(xyz, xlab = "Date", ylab = "y", zlab = "z")

  rgl.setAxisCallback(1, datelabels)
  # Repeat the data 5 days later
  points3d(xyz + rep(c(5, 0, 0), each = 10))
  # Make the plot square again
  aspect3d(1,1,1)
}
}
