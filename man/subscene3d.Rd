\name{subscene3d}
\alias{newSubscene3d}
\title{
Create, select or modify a subscene.
}
\description{
This creates a new subscene, or selects one by \code{id} value, or adds objects to one.
}
\usage{
newSubscene3d(viewport = "inherit", projection = "inherit", model = "inherit", 
           parent = subsceneInfo()$id, copyLights = TRUE, copyShapes = FALSE, newviewport)
useSubscene3d(subscene)
addToSubscene3d(ids, subscene = subsceneInfo()$id)
}
\arguments{
  \item{viewport, projection, model}{
How should the new subscene be embedded?  Possible values are
\code{c("inherit", "modify", "replace")}.
}
  \item{parent}{
The parent subscene (defaults to the current subscene).
}
  \item{copyLights, copyShapes}{
Whether lights and shapes should be copied to the new subscene.
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
}
\value{
If successful, the object id of the subscene.
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
newSubscene3d(viewport = "modify", newviewport = v, copyShapes = TRUE)
}
\keyword{ graphics }
