\name{gltfTypes}
\alias{gltfTypes}
\docType{data}
\title{
Names of glTF types.
}
\description{
The glTF specification packs data into buffers, labelling
type type of each part with an integer.  The first six are the
integers used there, with \code{"int"} and \code{"double"}
added for completeness; those values are taken from
OpenGL header files.
}
\usage{gltfTypes}
\format{
\code{gltfTypes} is simply a named vector containing integer values.
}
\details{
These are used in the \code{\link{Buffer}} object.
}
\references{
\url{https://www.khronos.org/registry/glTF/specs/2.0/glTF-2.0.html#_accessor_componenttype}
}
\examples{
gltfTypes
}
