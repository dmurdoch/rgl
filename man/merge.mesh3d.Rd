\name{merge.mesh3d}
\alias{merge.mesh3d}
\title{
Merge \code{"mesh3d"} objects.
}
\description{
Attempts to merge \code{"mesh3d"} objects.  Objects need
to be similar enough; see Details.
}
\usage{
merge.mesh3d(x, y, ..., attributesMustMatch = FALSE)
}
\arguments{
  \item{x, y}{
\code{"mesh3d"} objects to merge.
}
  \item{\dots}{
Optional additional objects.
}
  \item{attributesMustMatch}{ See Details.}
}
\details{
To allow objects to be merged, they need to be similar enough
in terms of having the same list of material properties,
normals, texture coordinates, etc.  

If \code{attributesMustMatch} is \code{TRUE}, it is an error
to have attributes in one mesh but not in another, and 
those attributes that only specify a single value must have equal
values in all meshes.

If \code{attributesMustMatch} is \code{FALSE}, any non-matching
attributes will be dropped from the final result.
}
\value{
A single \code{"mesh3d"} object merging the contents
of the arguments.
}
\author{
Duncan Murdoch
}
\examples{
# Notice that the alpha setting for the cube is dropped, because
# the other shapes don't specify alpha.
shade3d(merge(cube3d(col="red", alpha = 0.5),
              translate3d(tetrahedron3d(col="green"), 2, 0, 0),
              translate3d(octahedron3d(col="blue"), 4, 0, 0)))
}
