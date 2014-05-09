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
newSubscene3d(viewport = "replace", projection = "replace", model = "replace", 
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
The rgl package allows multiple windows to be open; each one corresponds to a \dQuote{scene}.
Within each scene there are one or more \dQuote{subscenes}.  Each subscene corresponds
to a rectangular region in the window, and may have it's own projection and transformation.

There is always a current subscene:  most graphic operations make changes there, e.g. by adding
an object to it.

The scene \dQuote{owns} objects; \code{addToSubscene3d} and \code{delFromSubscene3d} 
put their ids into or remove them from the list being displayed within a particular subscene.
The \code{gc3d} function deletes objects from the scene if they are not visible in any
subscene, unless they are protected by having their id included in \code{protect}.

The \code{viewport}, \code{projection} and \code{model} parameters each have three possible settings:
\code{c("inherit", "modify", "replace")}.  \code{"inherit"} means that the corresponding value
from the parent subscene will be used.  \code{"replace"} means that the new subscene will
have its own value of the value, independent of its parent.  \code{"modify"} means that the 
child value will be applied first, and then the parent value will be applied.  For viewport, this
means that if the parent viewport is changed, the child will maintain its relative position.  For
the two matrices, \code{"modify"} is unlikely to give satisfactory results, but it is available
for possible use.

The \code{viewport} parameter controls the rectangular region in which the subscene is displayed.
It is specified using \code{newviewport} (in pixels relative to the whole window), or set to 
match the parent viewport.

The \code{projection} parameter controls settings corresponding to the observer.  These
include the field of view and the zoom; they also include the position of the observer relative to
the model.  The \code{par3d("projMatrix")} matrix is determined by the projection.

The \code{model} parameter controls settings corresponding to the model.  Mouse rotations affect
the model, as does scaling.  The \code{par3d("modelMatrix")} matrix is determined by these as
well as by the position of the observer (since OpenGL assumes that the observer is at
(0,0,0) after the MODELVIEW transformation).  Only those parts concerning the model are
inherited when \code{model} specifies inheritance, the observer setting is controlled by
\code{projection}.
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
