\name{subscene3d}
\alias{newSubscene3d}
\alias{useSubscene3d}
\alias{addToSubscene3d}
\alias{delFromSubscene3d}
\alias{gc3d}
\title{
Create, select or modify a subscene.
}
\description{
This creates a new subscene, or selects one by \code{id} value, or adds objects to one.
}
\usage{
newSubscene3d(viewport = "inherit", projection = "inherit", model = "inherit", 
           parent = subsceneInfo()$id, 
           copyLights = TRUE, copyShapes = FALSE, copyBBoxDeco = copyShapes, newviewport)
useSubscene3d(subscene)
addToSubscene3d(ids, subscene = subsceneInfo()$id)
delFromSubscene3d(ids, subscene = subsceneInfo()$id)
gc3d(protect = NULL)
}
\arguments{
  \item{viewport, projection, model}{
How should the new subscene be embedded?  Possible values are
\code{c("inherit", "modify", "replace")}.  See Details below.
}
  \item{parent}{
The parent subscene (defaults to the current subscene).
}
  \item{copyLights, copyShapes, copyBBoxDeco}{
Whether lights, shapes and bounding box decorations should be copied to the new subscene.
}
  \item{newviewport}{
Optionally specify the new subscenes viewport (in pixels).
}
  \item{subscene}{
Which subscene to use or modify.
}
  \item{ids}{
A vector of integer object ids to add to the subscene.
}
  \item{protect}{
Object ids to protect from this garbage collection.
}
}
\details{
Note that the scene \dQuote{owns} objects; \code{addToSubscene3d} and \code{delFromSubscene3d} 
just put their ids into or remove them from the list being displayed within a particular subscene.
The \code{gc3d} function deletes objects from the scene if they are not visible in any
subscene, unless they are protected by having their id included in \code{protect}.

The viewport, projection matrix and model matrix each have three possible settings:
\code{c("inherit", "modify", "replace")}.  \code{"inherit"} means that the corresponding value
from the parent subscene will be used.  \code{"replace"} means that the new subscene will
have its own value of the value, independent of its parent.  \code{"modify"} means that the 
child value will be applied first, and then the parent value will be applied.  For viewport, this
means that if the parent viewport is changed, the child will maintain its relative position.  For
the two matrices, \code{"modify"} is unlikely to give satisfactory results, but it is available
for possible use.
}
\value{
If successful, each function returns the object id of the subscene, with the exception of
\code{gc3d}, which returns the count of objects which have been deleted.
}
\author{
Duncan Murdoch and Fang He.
}
\seealso{
\code{\link{subsceneInfo}}
}
\examples{
example(plot3d)
root <- subsceneInfo()$id
v <- par3d("viewport")
v <- v/2
newSubscene3d(viewport = "replace", newviewport = v, copyShapes = TRUE)
v[1:2] <- v[3:4]
useSubscene3d(root)
newSubscene3d(viewport = "modify", model = "replace", newviewport = v, copyShapes = TRUE)
}
\keyword{ graphics }
