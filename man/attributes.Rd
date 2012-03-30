\name{attributes}
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
An attribute of a shape.  Currently supported: one of 
\code{c("vertices", "normals", "colors", "texcoords", "dim", "texts",
        "cex", "adj", "radii", "centers")}, or unique prefixes
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
\describe{
\item{vertices}{3 values, x, y, z}
\item{normals}{3 values, x, y, z}
\item{centers}{3 values, x, y, z}
\item{colors}{4 values, r, g, b, a}
\item{texcoords}{2 values, s, t}
\item{dim}{2 values, r, c}
\item{cex}{1 value}
\item{adj}{2 values, x, y}
\item{radii}{1 value}
}
The \code{"texts"} attribute is character-valued.

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
