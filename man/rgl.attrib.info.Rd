\name{rgl.attrib.info}
\alias{rgl.attrib.info}
\alias{rgl.attrib.count}
\title{
Get information about attributes of objects
}
\description{
These functions give information about the attributes of
\pkg{rgl} objects.  \code{rgl.attrib.info} is the more 
\dQuote{user-friendly} function; \code{rgl.attrib.count} is a 
lower-level function more likely to be used in programming.
}
\usage{
rgl.attrib.info(id = rgl.ids("all", 0)$id, attribs = NULL, showAll = FALSE)
rgl.attrib.count(id, attrib)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{id}{
One or more \pkg{rgl} object ids.
}
  \item{attribs}{
A character vector of one or more attribute names.
}
  \item{showAll}{
Should attributes with zero entries be shown?
}
  \item{attrib}{
A single attribute name.
}
}
\details{
See the first example below to get the full list of attribute
names.
}
\value{
A dataframe containing the following columns:
\item{id}{The id of the object.}
\item{attrib}{The full name of the attribute.}
\item{nrow, ncol}{The size of matrix that would be returned
by \code{\link{rgl.attrib}} for this attribute.}
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{rgl.attrib}} to obtain the attribute values.
}
\examples{
open3d()
id <- points3d(rnorm(100), rnorm(100), rnorm(100), col = "green")
rgl.attrib.info(id, showAll = TRUE)
rgl.attrib.count(id, "vertices")

merge(rgl.attrib.info(), rgl.ids("all"))
}
