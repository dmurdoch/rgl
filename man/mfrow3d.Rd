\name{mfrow3d}
\alias{mfrow3d}
\alias{layout3d}
\alias{next3d}
\alias{subsceneList}
\title{
Set up multiple figure layouts in rgl.
}
\description{
The \code{mfrow3d} and \code{layout3d} functions provide functionality in \pkg{rgl}
similar to \code{\link{par}("mfrow")} and \code{\link{layout}} in classic R graphics.
}
\usage{
subsceneList(value, window = rgl.cur())
mfrow3d(nr, nc, byrow = TRUE, parent = NA, ...)
layout3d(mat, widths = rep.int(1, ncol(mat)), 
              heights = rep.int(1, nrow(mat)),
              parent = NA, 
              ...)
next3d(current = NA, clear = TRUE)
}
\arguments{
  \item{value}{
A new subscene list to set.  If missing, return the current one (or \code{NULL}).
}
  \item{window}{
Which window to operate on.
}
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
shapes <- list(Tetrahedron=tetrahedron3d(), Cube=cube3d(), Octahedron=octahedron3d(),
               Icosahedron=icosahedron3d(), Dodecahedron=dodecahedron3d(),
               Cuboctahedron=cuboctahedron3d())
col <- rainbow(6)
open3d()
mfrow3d(3,2)
for (i in 1:6) {
  shade3d(shapes[[i]], col=col[i])
  if (i < 6) next3d()
}

open3d()
mat <- matrix(1:4, 2,2)
mat <- rbind(mat, mat+4, mat+8)
layout3d(mat, height = rep(c(3,1), 3), model = "inherit")
for (i in 1:6) {
  shade3d(shapes[[i]], col=col[i])
  next3d()
  text3d(0,0,0, names(shapes)[i])
  if (i < 6) next3d()
}
}
\keyword{graphics }
