\name{qmesh3d}
\alias{qmesh3d}
\alias{dot3d.qmesh3d}
\alias{wire3d.qmesh3d}
\alias{shade3d.qmesh3d}
\alias{cube3d}
\alias{oh3d}
\title{3D Quadrangle Mesh objects}
\description{
  3D Quadrangle Mesh object creation and a collection of sample objects.
}
\usage{
  qmesh3d(vertices,indices,homogeneous=TRUE,material=NULL)
  cube3d()  # cube object
  oh3d()    # an 'o' object
}
\arguments{
  \item{vertices}{3- or 4-component vector of coordinates}
  \item{indices}{4-component vector of quad indices}
  \item{homogeneous}{logical indicating if homogeneous (four component) coodinates are used.}
  \item{material}{material properties for later rendering}
}
\examples{

  # generate a quad mesh object

  vertices <- c( 
     -1.0, -1.0, 0, 1.0,
      1.0, -1.0, 0, 1.0,
      1.0,  1.0, 0, 1.0,
     -1.0,  1.0, 0, 1.0
  )
  indices <- c( 1, 2, 3, 4 )
  clear3d()  
  wire3d( qmesh3d(vertices,indices) )
  
  # render 4 meshes

  clear3d()  
  bg3d("gray")
  shade3d( translate3d( oh3d(), -6, 0, 0 ), color="red" )
  l1 <- subdivision3d( oh3d() )
  shade3d( translate3d( l1 , -2, 0, 0 ), color="red" )
  l2 <- subdivision3d( l1 )
  shade3d( translate3d( l2 , 2, 0, 0 ), color="red" )
  l3 <- subdivision3d( l2 )
  shade3d( translate3d( l3 , 6, 0, 0 ), color="red" )
  
}
\seealso{
  \code{\link{r3d}}
}
\keyword{dynamic}
