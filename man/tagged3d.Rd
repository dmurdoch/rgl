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
tagged3d(tags = NULL, ids = NULL, subscene = 0)
}
\arguments{
  \item{tags}{
A vector of tags to use for selection.
}
  \item{ids}{
A vector of ids to report the tags on.
}
  \item{subscene}{
Where to look:  by default, the whole scene is searched.
\code{NA} restricts the search to the current subscene,
or a subscene id can be given.
}
}
\value{
Exactly one of \code{tags} and \code{ids} must be specified.

If \code{tags} is specified, a dataframe with columns
\item{id}{item id}
\item{type}{item type}
\item{tag}{item tag}

If \code{ids} is specified, a vector of tags (in the same order
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
tagged3d(ids = ids)
}
