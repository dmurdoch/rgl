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
\note{not completely implemented for X11 graphics (stay not implemented;
window managers such as KDE may block this action
(set "Focus stealing prevention level" to None in Control Center/Window Behavior/Advanced)).
Not currently implemented under OS/X.}
\seealso{ \code{\link[graphics]{bringToTop}}}
\examples{
rgl.open()
rgl.points(rnorm(1000), rnorm(1000), rnorm(1000), color=heat.colors(1000), size=2)
rgl.bringtotop(stay = TRUE)    
}
\keyword{ dynamic }
