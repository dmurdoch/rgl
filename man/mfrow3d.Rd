\name{mfrow3d}
\alias{mfrow3d}
\alias{layout3d}
\alias{next3d}
\title{
Set up multiple figure layouts in rgl.
}
\description{
The \code{mfrow3d} and \code{layout3d} functions provide functionality in \pkg{rgl}
similar to \code{\link{par}("mfrow")} and \code{\link{layout}} in classic R graphics.
}
\usage{
mfrow3d(nr, nc, byrow = TRUE, parent = NA, ...)
layout3d(mat, widths = rep.int(1, ncol(mat)), 
              heights = rep.int(1, nrow(mat)),
              parent = NA, 
              ...)
next3d(current = NA, clear = TRUE)
}
\arguments{
  \item{nr, nc}{
Number of rows and columns of figures.
}
  \item{byrow}{
Whether figures progress by row (as with \code{\link{par}("mfrow")}) or by column 
(as with \code{\link{par}("mfcol")}).
}
  \item{mat, widths, heights}{
Layout parameters; see \code{\link{layout}} for their interpretation.
}
  \item{parent}{
The parent subscene.  \code{NA} indicates the current subscene.
}
  \item{\dots}{
Additional parameters to pass to \code{\link{newSubscene3d}} as each
subscene is created.
}
  \item{current}{
The subscene to move away from.  \code{NA} indicates the current subscene.
}
  \item{clear}{
Whether the newly entered subscene should be cleared upon entry.
}
}
\details{
rgl can maintain a list of subscenes; the \code{mfrow3d} and \code{layout3d} functions create that list.
When the list is in place, \code{next3d} causes rgl to move to the next scene in the list, or cycle
back to the first one.

Unlike the classic R graphics versions of these functions, these functions are completely compatible with
each other.  You can mix them within a single rgl window.
}
\value{
\code{mfrow3d} and \code{layout3d} return a vector of subscene id values that have just been
created.  If a previous subscene list was in effect, it is attached as an attribute \code{"prev"}.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{newSubscene3d}}, \code{\link{par}}, \code{\link{layout}}.
}
\examples{
open3d()
mfrow3d(3,2)
col <- rainbow(6)
shade3d(tetrahedron3d(), col=col[1])
next3d()
shade3d(cube3d(), col=col[2])
next3d()
shade3d(octahedron3d(), col=col[3])
next3d()
shade3d(icosahedron3d(), col=col[4])
next3d()
shade3d(dodecahedron3d(), col=col[5])
next3d()
shade3d(cuboctahedron3d(), col=col[6])
}
\keyword{graphics }
