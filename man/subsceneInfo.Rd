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
subsceneInfo(id, recursive = FALSE)
}
\arguments{
  \item{id}{
Which subscene to report on; defaults to the current subscene.  Set to 0 for the root.
}
  \item{recursive}{
Whether to report on children recursively.
}
}
\details{
In rgl, each window contains a tree of \dQuote{subscenes}, each containing views of 
a subset of the objects defined in the window.
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
