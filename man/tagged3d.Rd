\name{tagged3d}
\alias{tagged3d}
\title{
Find tags on rgl objects.
}
\description{
Objects with material properties may have an arbitrary
string set as a tag.  This function retrieves the id
values associated with a given tag, or the tags set on 
given ids.
}
\usage{
tagged3d(tags = NULL, ids = NULL, full = FALSE, subscene = 0)
}
\arguments{
  \item{tags}{
A vector of tags to use for selection.
}
  \item{ids}{
A vector of ids to report the tags on.
}
  \item{full}{logical; whether to return 
a dataframe containing \code{id}, \code{type}, \code{tag},
or a vector of ids or tags.}
  \item{subscene}{
Where to look:  by default, the whole scene is searched.
\code{NA} restricts the search to the current subscene,
or a subscene id can be given.
}
}
\details{
Exactly one of \code{tags} and \code{ids} must be specified.
}
\value{
A dataframe is constructed with columns
\item{id}{item id}
\item{type}{item type}
\item{tag}{item tag}
matching the specified \code{tags} or \code{ids} value.
If \code{full = TRUE}, the full dataframe is returned, otherwise
just the requested ids or tags.

If \code{ids} is specified, the return value will be
in the same order
as \code{ids}).
}
\author{
Duncan Murdoch
}

\examples{
open3d()
ids <- plot3d(rnorm(10), rnorm(10), rnorm(10), tag = "plot")
unclass(ids)
tagged3d("plot")
tagged3d(ids = ids, full = TRUE)
}
