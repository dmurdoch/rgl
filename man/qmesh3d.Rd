\name{qmesh3d}
\alias{qmesh3d}
\alias{dot3d}
\alias{dot3d.qmesh3d}
\alias{wire3d}
\alias{wire3d.qmesh3d}
\alias{shade3d}
\alias{shade3d.qmesh3d}
\alias{cube3d}
\alias{oh3d}
\title{3D Quadrangle Mesh objects}
\description{
  3D Quadrangle Mesh object creation and a collection of sample objects.
}
\usage{
  qmesh3d(vertices, indices, homogeneous = TRUE, material = NULL)
  cube3d(trans = identityMatrix(), ...)  # cube object
  oh3d(trans = identityMatrix(), ...)    # an 'o' object
  
  dot3d(x, ...)   # draw dots at the vertices of an object
  \method{dot3d}{qmesh3d}(x, override = TRUE, ...)
  wire3d(x, ...)  # draw a wireframe object
  \method{wire3d}{qmesh3d}(x, override = TRUE, ...)
  shade3d(x, ...) # draw a shaded object
  \method{shade3d}{qmesh3d}(x, override = TRUE, ...)
}
\arguments{
  \item{x}{a qmesh3d object (class qmesh3d)}
  \item{vertices}{3- or 4-component vector of coordinates}
  \item{indices}{4-component vector of quad indices}
  \item{homogeneous}{logical indicating if homogeneous (four component) coordinates are used.}
  \item{material}{material properties for later rendering}
  \item{trans}{transformation to apply to objects; see below for defaults}
  \item{...}{additional rendering parameters}
  \item{override}{should the parameters specified here override those stored in the object?}
}
\details{
  The \code{cube3d} and \code{oh3d} objects optionally take a matrix transformation as 
  an argument.  This transformation is applied to all vertices of the default shape.
  
  The default is an identity transformation.  Use \code{par3d("userMatrix")} to render the
  object vertically in the current user view.
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
  
  open3d()  
  wire3d( qmesh3d(vertices,indices) )
  
  # render 4 meshes vertically in the current view

  clear3d()  
  bg3d("gray")
  l0 <- oh3d(tran = par3d("userMatrix"), color = "green" )
  shade3d( translate3d( l0, -6, 0, 0 ))
  l1 <- subdivision3d( l0 )
  shade3d( translate3d( l1 , -2, 0, 0 ), color="red", override = FALSE )
  l2 <- subdivision3d( l1 )
  shade3d( translate3d( l2 , 2, 0, 0 ), color="red", override = TRUE )
  l3 <- subdivision3d( l2 )
  shade3d( translate3d( l3 , 6, 0, 0 ), color="red" )
  
}
\seealso{
  \code{\link{r3d}}, \code{\link{par3d}} 
}
\keyword{dynamic}
