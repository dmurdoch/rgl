\name{subdivision3d}
\alias{subdivision3d}
\alias{subdivision3d.qmesh3d}
\alias{divide.qmesh3d}
\alias{normalize.qmesh3d}
\alias{deform.qmesh3d}
\title{generic subdivision surface method}
\description{
The Subdivision surface algorithm divide and refine (deform) a
given mesh recursively to certain degree (depth).
The qmesh3d algorithm consists of two stages: divide and deform.
The divide step generates for each quad four new quads, the deform
step drags the points (refinement step).
}
\usage{
  subdivision3d( x,  ...)
  subdivision3d.qmesh3d( x, depth=1, normalize=FALSE, deform=TRUE, ... )
  divide.qmesh3d(mesh,  vb=mesh$vb, ib=mesh$ib )
  normalize.qmesh3d(mesh)
  deform.qmesh3d(mesh,vb=mesh$vb,ib=mesh$ib)
}
\arguments{
  \item{x}{3d geometry mesh}
  \item{mesh}{3d geometry mesh}
  \item{depth}{recursion depth}
  \item{normalize}{normalize qmesh3d coordinates after division if deform is TRUE otherwise}
  \item{deform}{deform mesh after normalization}
  \item{ib}{vector of indices (i.e., which sets of vertices to combine
    into quads); 4xn matrix or equivalent vector}
  \item{vb}{vector of vertices: 4xn matrix (rows x,y,z,h) or equivalent
    vector, where h indicates scaling of each plotted quad}
  \item{...}{other arguments (unused)}
}
\details{
  Generic subdivision surface method. Currently there exists
  an algorithm that can be applied on qmesh3d objects.
}
\examples{
  open3d()
  shade3d( subdivision3d( cube3d(), depth=3 ), color="red", alpha=0.5 )
}
\seealso{
  \code{\link{r3d}}
  \code{\link{qmesh3d}}
}
\keyword{dynamic}
