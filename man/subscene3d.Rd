\name{subscene3d}
\alias{subscene3d}
\alias{newSubscene3d}
\alias{currentSubscene3d}
\alias{useSubscene3d}
\alias{addToSubscene3d}
\alias{delFromSubscene3d}
\alias{gc3d}
\title{
Create, select or modify a subscene
}
\description{
This creates a new subscene, or selects one by \code{id} value, or adds objects to one.
}
\usage{
newSubscene3d(viewport = "replace", 
              projection = "replace", 
              model = "replace",
              mouseMode = "inherit", 
              parent = currentSubscene3d(), 
              copyLights = TRUE, 
              copyShapes = FALSE, 
              copyBBoxDeco = copyShapes, 
              copyBackground = FALSE, newviewport,
              ignoreExtent)
currentSubscene3d(dev = cur3d())
useSubscene3d(subscene)
addToSubscene3d(ids, subscene = currentSubscene3d())
delFromSubscene3d(ids, subscene = currentSubscene3d())
gc3d(protect = NULL)
}
\arguments{
  \item{viewport, projection, model, mouseMode}{
How should the new subscene be embedded?  Possible values are
\code{c("inherit", "modify", "replace")}.  See Details below.
}
  \item{parent}{
The parent subscene (defaults to the current subscene).
}
  \item{copyLights, copyShapes, copyBBoxDeco, copyBackground}{
Whether lights, shapes, bounding box decorations and background should be copied to the new subscene.
}
  \item{newviewport}{
Optionally specify the new subscene's viewport (in pixels).
}
  \item{ignoreExtent}{
Whether to ignore the subscene's bounding box when calculating the parent bounding
box.  Defaults to \code{TRUE} if \code{model} is not \code{"inherit"}.
}
  \item{dev}{
Which RGL device to query for the current subscene.
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
The \pkg{rgl} package allows multiple windows to be open; each one corresponds to a \dQuote{scene}.
Within each scene there are one or more \dQuote{subscenes}.  Each subscene corresponds
to a rectangular region in the window, and may have its own projection, transformation and behaviour in response to 
the mouse.

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

The \code{mouseMode} parameter 
can only be one of \code{c("inherit", "replace")}.  If
it is \code{"inherit"}, the subscene will use the mouse
controls of the parent, and any change to them will
affect the parent and all children that inherit from it.
This is the behaviour that was present before \pkg{rgl}
version 0.100.13.  If it is \code{"replace"}, then
it will receive a copy of the parent mouse controls,
but modifications to them will affect only this 
subscene, not the parent.  Note that this is orthogonal
to the \code{\link{par3d}("listeners")} setting:
if another subscene is listed as a listener, it will respond
to mouse actions using the same mode as the one receiving
them.

The \code{viewport} parameter controls the rectangular region in which the subscene is displayed.
It is specified using \code{newviewport} (in pixels relative to the whole window), or set to 
match the parent viewport.

The \code{projection} parameter controls settings corresponding to the observer.  These
include the field of view and the zoom; they also include the position of the observer relative to
the model.  The \code{par3d("projMatrix")} matrix is determined by the projection.

The \code{model} parameter controls settings corresponding to the model.  Mouse rotations affect
the model, as does scaling.  The \code{par3d("modelMatrix")} matrix is determined by these as
well as by the position of the observer (since OpenGL assumes that the observer is at
(0, 0, 0) after the MODELVIEW transformation).  Only those parts concerning the model are
inherited when \code{model} specifies inheritance, the observer setting is controlled by
\code{projection}.

If \code{copyBackground} is \code{TRUE}, the background of the newly created child will
overwrite anything displayed in the parent subscene, regardless of depth.
}
\value{
If successful, each function returns the object id of the subscene, with the exception of
\code{gc3d}, which returns the count of objects which have been deleted, 
and \code{useSubscene3d}, which returns the previously active subscene id.
}
\author{
Duncan Murdoch and Fang He.
}
\seealso{
\code{\link{subsceneInfo}} for information about a subscene, 
\code{\link{mfrow3d}} and \code{\link{layout3d}} to set up 
multiple panes of subscenes.
}
\examples{

# Show the Earth with a cutout by using clipplanes in subscenes

lat <- matrix(seq(90, -90, len = 50)*pi/180, 50, 50, byrow = TRUE)
long <- matrix(seq(-180, 180, len = 50)*pi/180, 50, 50)

r <- 6378.1 # radius of Earth in km
x <- r*cos(lat)*cos(long)
y <- r*cos(lat)*sin(long)
z <- r*sin(lat)

open3d()
obj <- surface3d(x, y, z, col = "white", 
       texture = system.file("textures/worldsmall.png", package = "rgl"), 
       specular = "black", axes = FALSE, box = FALSE, xlab = "", ylab = "", zlab = "",
       normal_x = x, normal_y = y, normal_z = z)
       
cols <- c(rep("chocolate4", 4), rep("burlywood1", 4), "darkgoldenrod1")
rs <- c(6350, 5639, 4928.5, 4207, 3486, 
                         (3486 + 2351)/2, 2351, (2351 + 1216)/2, 1216)
for (i in seq_along(rs)) 
  obj <- c(obj, spheres3d(0, 0, col = cols[i], radius = rs[i]))
  
root <- currentSubscene3d()

newSubscene3d("inherit", "inherit", "inherit", copyShapes = TRUE, parent = root)
clipplanes3d(1, 0, 0, 0)

newSubscene3d("inherit", "inherit", "inherit", copyShapes = TRUE, parent = root)
clipplanes3d(0, 1, 0, 0)

newSubscene3d("inherit", "inherit", "inherit", copyShapes = TRUE, parent = root)
clipplanes3d(0, 0, 1, 0)

# Now delete the objects from the root subscene, to reveal the clipping planes
useSubscene3d(root)
delFromSubscene3d(obj)
}
\keyword{ graphics }
