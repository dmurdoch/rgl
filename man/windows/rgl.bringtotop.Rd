\name{rgl.bringtotop}
\alias{rgl.bringtotop}
\title{Assign focus to an RGL window }
\description{
'rgl.bringtotop' brings the specified RGL window to the
front of the window stack (and gives it focus).}
\usage{
rgl.bringtotop(stay = FALSE)
}
\arguments{
  \item{stay}{whether to make the window stay on top.}
}
\details{
If \code{stay} is \code{TRUE}, then the window will stay on top
of normal windows.
}
\author{ Ming Chen/Duncan Murdoch }
\seealso{ \code{\link[graphics]{bringToTop}}}
\examples{
rgl.clear()
rgl.points(rnorm(1000), rnorm(1000), rnorm(1000), color=heat.colors(1000), size=2)
rgl.bringtotop(stay = TRUE)    
}
\keyword{ dynamic }
