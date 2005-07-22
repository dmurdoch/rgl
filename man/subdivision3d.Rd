\name{subdivision3d}
\alias{subdivision3d}
\alias{subdivision3d.qmesh3d}
\title{generic subdivision surface method}
\description{
The Subdivision surface algorithm divide and refine (deform) a
given mesh recursively to certain degree (depth).
The qmesh3d algorithm consists of two stages: divide and deform.
The divide step generates for each quad four new quads, the deform
step drags the points (refinement step).
}
\usage{
  subdivision3d( mesh, depth, ...)
  subdivision3d.qmesh3d( mesh, depth, normalize=F, deform=T )
  divide.qmesh3d(mesh, ib=mesh$ib, vb=mesh$vb )
  normalize.qmesh3d(mesh)
  deform.qmesh3d(mesh,vb=mesh$vb,ib=mesh$ib)
}
\arguments{
  \item{mesh}{3d geometry mesh}
  \item{depth}{recursion depth}
  \item{normalize}{normalize qmesh3d coordinates after division if deform is TRUE otherwise}
  \item{deform}{deform mesh after normalization}
}
\details{
  Generic subdivision surface method. Currently there exists
  an algorithm that can be applied on qmesh3d objects.
}
\examples{
  shade3d( subdivision3d( cube3d(), depth=3 ), color="red", alpha=0.5 )
}
\seealso{
  \code{\link{r3d}}
  \code{\link{qmesh3d}}
}
\keyword{dynamic}
