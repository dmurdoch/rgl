\name{subsceneInfo}
\alias{subsceneInfo}
\title{
Get information on subscenes
}
\description{
This function retrieves information about the tree of subscenes shown in the active
window.
}
\usage{
subsceneInfo(id = NA, embeddings, recursive = FALSE)
}
\arguments{
  \item{id}{
Which subscene to report on; \code{NA} is the current subscene.  Set to \code{"root"} for the root.
}
  \item{embeddings}{
Optional new setting for the embeddings for this subscene.
}
  \item{recursive}{
Whether to report on children recursively.
}
}
\details{
In RGL, each window contains a tree of \dQuote{subscenes}, each containing views of 
a subset of the objects defined in the window.

Rendering in each subscene depends on the viewport, the projection, and the model
transformation.  Each of these characteristics may be inherited from the parent 
(\code{embedding[i] = "inherit"}), may modify the parent (\code{embedding[i] = "modify"}),
or may replace the parent (\code{embedding[i] == "replace"}).  All three must be
specified if \code{embeddings} is used.
}
\value{
\item{id}{The object id of the subscene}
\item{parent}{The object id of the parent subscene, if any}
\item{children}{If \code{recursive}, a list of the information for the children,
otherwise just their object ids.}
\item{embedding}{A vector of 3 components describing how this subscene is
embedded in its parent.
}
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{newSubscene3d}}
}
\examples{
example(plot3d)
subsceneInfo()
}
\keyword{ graphics }
