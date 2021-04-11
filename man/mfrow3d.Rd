\name{mfrow3d}
\alias{mfrow3d}
\alias{layout3d}
\alias{next3d}
\alias{subsceneList}
\alias{clearSubsceneList}
\title{
Set up multiple figure layouts
}
\description{
The \code{mfrow3d} and \code{layout3d} functions provide functionality in RGL
similar to \code{\link{par}("mfrow")} and \code{\link{layout}} in classic R graphics.
}
\usage{
subsceneList(value, window = cur3d())

mfrow3d(nr, nc, byrow = TRUE, parent = NA, sharedMouse = FALSE, ...)
layout3d(mat, widths = rep.int(1, ncol(mat)), 
              heights = rep.int(1, nrow(mat)),
              parent = NA, sharedMouse = FALSE,
              ...)
next3d(current = NA, clear = TRUE, reuse = TRUE)
clearSubsceneList(delete = currentSubscene3d() \%in\% subsceneList(), 
                  window = cur3d())
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
The parent subscene.  \code{NA} indicates the current subscene.  See Details below.
}
  \item{sharedMouse}{
Whether to make all subscenes \code{\link{par3d}("listeners")} to each other.
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
  \item{reuse}{
Whether to skip advancing if the current subscene has no objects in it.
}
  \item{delete}{
If \code{TRUE}, delete the subscenes in the current window.
}
}
\details{
rgl can maintain a list of subscenes; the \code{mfrow3d} and \code{layout3d} functions create that list.
When the list is in place, \code{next3d} causes RGL to move to the next scene in the list, or cycle
back to the first one.

Unlike the classic R graphics versions of these functions, these functions are completely compatible with
each other.  You can mix them within a single RGL window.

In the default case where \code{parent} is missing, \code{mfrow3d} and \code{layout3d} will
call \code{clearSubsceneList()} at the start.  

By default \code{clearSubsceneList()} checks
whether the current subscene is in the current subscene list; if so, it will delete
all subscenes in the list, and call \code{\link{gc3d}} to delete any objects that are no
longer shown.  The subscene list will be set to a previous value if one was recorded,
or \code{NULL} if not.

If \code{parent} is specified in \code{mfrow3d} or \code{layout3d} 
(even as \code{NA}), the new subscenes will be created within 
the parent.

The \code{next3d()} function first finds out if the current
subscene is in the current list.  If not, it moves to the
previous list, and looks there.  Once it finds a list 
containing the current subscene, it moves to the next entry
in that list.  If it can't find one, it creates a length
one list containing just the current subscene.
}
\value{
\code{mfrow3d} and \code{layout3d} return a vector of subscene id values that have just been
created.  If a previous subscene list was in effect and was not automatically cleared,
it is attached as an attribute \code{"prev"}.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{newSubscene3d}}, \code{\link{par}}, \code{\link{layout}}.
}
\examples{
shapes <- list(Tetrahedron = tetrahedron3d(), Cube = cube3d(), Octahedron = octahedron3d(),
               Icosahedron = icosahedron3d(), Dodecahedron = dodecahedron3d(),
               Cuboctahedron = cuboctahedron3d())
col <- rainbow(6)
open3d()
mfrow3d(3, 2)
for (i in 1:6) {
  next3d()   # won't advance the first time, since it is empty
  shade3d(shapes[[i]], col = col[i])
}
highlevel(integer()) # To trigger display as rglwidget

open3d()
mat <- matrix(1:4, 2, 2)
mat <- rbind(mat, mat + 4, mat + 8)
layout3d(mat, height = rep(c(3, 1), 3), sharedMouse = TRUE)
for (i in 1:6) {
  next3d()
  shade3d(shapes[[i]], col = col[i])
  next3d()
  text3d(0, 0, 0, names(shapes)[i])
}
highlevel(integer())
}
\keyword{graphics }
