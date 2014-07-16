\name{rgl.attrib}
\alias{rgl.attrib.count}
\alias{rgl.attrib}
\title{
Get information about shapes
}
\description{
Retrieves information about the shapes in a scene.
}
\usage{
rgl.attrib.count(id, attrib)
rgl.attrib(id, attrib, first = 1, 
           last = rgl.attrib.count(id, attrib))
}
\arguments{
  \item{id}{
A shape identifier, as returned by \code{\link{rgl.ids}}.
}
  \item{attrib}{
An attribute of a shape.  Currently supported: one of \cr
\code{"vertices"}, \code{"normals"}, \code{"colors"}, \code{"texcoords"}, 
\code{"dim"}, \code{"texts"}, \code{"cex"}, \code{"adj"}, \code{"radii"}, 
\code{"centers"}, \code{"ids"}, \code{"usermatrix"}, \code{"types"}, \code{"flags"}\cr
or unique prefixes
to one of those. 
}
  \item{first, last}{
Specify these to retrieve only those rows of the result.
}
}
\details{
If the identifier is not found or is not a shape that has the given attribute, 
zero will be returned by \code{rgl.attrib.count}, and an empty matrix
will be returned by \code{rgl.attrib}.

The first four \code{attrib} names correspond to the usual OpenGL
properties; \code{"dim"} is used just for surfaces, defining the rows
and columns in the rectangular grid; \code{"cex"} and \code{"adj"}
apply only to text objects.
}
\value{
\code{rgl.attrib.count} returns the count of the requested attribute.  \code{rgl.attrib}
returns the values of the attribute.  Attributes
are mostly real-valued, with the following sizes:
\tabular{lll}{
\code{"vertices"}	\tab 3 values 	\tab x, y, z \cr
\code{"normals"}	\tab 3 values 	\tab x, y, z \cr
\code{"centers"}	\tab 3 values 	\tab x, y, z \cr
\code{"colors"}	\tab 4 values 	\tab r, g, b, a \cr
\code{"texcoords"}	\tab 2 values 	\tab s, t \cr
\code{"dim"}	\tab 2 values 	\tab r, c \cr
\code{"cex"}	\tab 1 value 	\tab cex \cr
\code{"adj"}	\tab 2 values 	\tab x, y \cr
\code{"radii"}	\tab 1 value 	\tab r \cr
\code{"ids"}	\tab 1 value	\tab id \cr
\code{"usermatrix"}	\tab 4 values 	\tab x, y, z, w \cr
\code{"texts"}	\tab 1 value	\tab text \cr
\code{"types"}	\tab 1 value	\tab type \cr
\code{"flags"}	\tab 1 value	\tab flag \cr
}
The \code{"texts"} and \code{"types"} attributes are character-valued; the flags
attribute is logical valued, with named rows.

These are returned as matrices with the row count equal to the count for the attribute,
and the columns as listed above.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{rgl.ids}}
}
\examples{
p <- plot3d(rnorm(100), rnorm(100), rnorm(100), type="s", col="red")
rgl.attrib.count(p["data"], "vertices")
rgl.attrib(p["data"], "vertices", last=10)
}
\keyword{ graphics }
