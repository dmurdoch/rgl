\name{mesh3d}
\alias{shape3d}
\alias{mesh3d}
\alias{as.mesh3d}
\alias{qmesh3d}
\alias{tmesh3d}
\alias{dot3d}
\alias{dot3d.qmesh3d} % for back compatibility
\alias{dot3d.mesh3d}
\alias{wire3d}
\alias{wire3d.qmesh3d} % for back compatibility
\alias{wire3d.mesh3d}
\alias{shade3d}
\alias{shade3d.qmesh3d} % for back compatibility
\alias{shade3d.mesh3d}
\alias{cube3d}
\alias{oh3d}
\alias{tetrahedron3d}
\alias{octahedron3d}
\alias{icosahedron3d}
\alias{dodecahedron3d}
\alias{cuboctahedron3d}

\title{3D Mesh objects}
\description{
  3D triangle and quadrangle mesh object creation and a collection of sample objects.
}
\usage{
  qmesh3d(vertices, indices, homogeneous = TRUE, material = NULL, 
         normals = NULL, texcoords = NULL)
  tmesh3d(vertices, indices, homogeneous = TRUE, material = NULL, 
         normals = NULL, texcoords = NULL)
  as.mesh3d(x, ...)
  
  cube3d(trans = identityMatrix(), ...)  
  tetrahedron3d(trans = identityMatrix(), ...)  
  octahedron3d(trans = identityMatrix(), ...)  
  icosahedron3d(trans = identityMatrix(), ...)
  dodecahedron3d(trans = identityMatrix(), ...)
  cuboctahedron3d(trans = identityMatrix(), ...)
  
  oh3d(trans = identityMatrix(), ...)    # an 'o' object
  
  dot3d(x, ...)   # draw dots at the vertices of an object
  \method{dot3d}{mesh3d}(x, override = TRUE, ...)
  wire3d(x, ...)  # draw a wireframe object
  \method{wire3d}{mesh3d}(x, override = TRUE, ...)
  shade3d(x, ...) # draw a shaded object
  \method{shade3d}{mesh3d}(x, override = TRUE, ...)
}
\arguments{
  \item{x}{a \code{mesh3d} object (class \code{qmesh3d} or \code{tmesh3d}), or for \code{as.mesh3d} an object
  with a method defined.}
  \item{vertices}{3- or 4-component vector of coordinates}
  \item{indices}{4-component vector of vertex indices}
  \item{homogeneous}{logical indicating if homogeneous (four component) coordinates are used.}
  \item{material}{material properties for later rendering}
  \item{normals}{normals at each vertex}
  \item{texcoords}{texture coordinates at each vertex}
  \item{trans}{transformation to apply to objects; see below for defaults}
  \item{...}{additional rendering parameters}
  \item{override}{should the parameters specified here override those stored in the object?}
}
\details{
  These functions create and work with \code{mesh3d} objects, which consist of a matrix
  of vertex coordinates together with a matrix of indices indicating which vertex is
  part of which face.  Such objects may have  triangular faces,
  planar quadrilateral faces, or both.
  
  The \code{as.mesh3d} function is generic; currently
the only method defined is \code{\link{as.mesh3d.deldir}}.

  The sample objects optionally take a matrix transformation \code{trans} as 
  an argument.  This transformation is applied to all vertices of the default shape.
  The default is an identity transformation. 
  
  The \code{"shape3d"} class is a general class for shapes that can be plotted
  by \code{dot3d}, \code{wire3d} or \code{shade3d}.
  
  The \code{"mesh3d"} class is a class of objects that form meshes: the vertices
  are in member \code{vb}, as a 3 or 4 by \code{n} matrix.  Meshes with triangular
  faces will contain \code{it}, a \code{3 * n} matrix giving the indices of the 
  vertices in each face.  Quad meshes will have vertex indices in \code{ib},
  a \code{4 * n} matrix.
}
\value{

  \code{qmesh3d}, \code{cube3d}, \code{oh3d}, \code{tmesh3d},
  \code{tetrahedron3d}, \code{octahedron3d}, \code{icosahedron3d} and
  \code{dodecahedron3d} return objects of class \code{c("mesh3d",
  "shape3d")}.  The first three of these are quad meshes, the rest are
  triangle meshes.
  
  \code{dot3d}, \code{wire3d}, and \code{shade3d} are called for their side effect
  of drawing an object into the scene; they return an object ID (or vector of IDs, for some 
  classes) invisibly.
  
  See \code{\link{rgl.primitive}} for a discussion of texture coordinates.
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
  wire3d( qmesh3d(vertices, indices) )
  
  # render 4 meshes vertically in the current view

  open3d()  
  bg3d("gray")
  l0 <- oh3d(tran = par3d("userMatrix"), color = "green" )
  shade3d( translate3d( l0, -6, 0, 0 ))
  l1 <- subdivision3d( l0 )
  shade3d( translate3d( l1 , -2, 0, 0 ), color = "red", override = FALSE )
  l2 <- subdivision3d( l1 )
  shade3d( translate3d( l2 , 2, 0, 0 ), color = "red", override = TRUE )
  l3 <- subdivision3d( l2 )
  shade3d( translate3d( l3 , 6, 0, 0 ), color = "red" )
  
  # render all of the Platonic solids
  open3d()
  shade3d( translate3d( tetrahedron3d(col = "red"), 0, 0, 0) )
  shade3d( translate3d( cube3d(col = "green"), 3, 0, 0) )
  shade3d( translate3d( octahedron3d(col = "blue"), 6, 0, 0) )
  shade3d( translate3d( dodecahedron3d(col = "cyan"), 9, 0, 0) )
  shade3d( translate3d( icosahedron3d(col = "magenta"), 12, 0, 0) )
}
\seealso{
  \code{\link{r3d}}, \code{\link{par3d}}, \code{\link{shapelist3d}} for multiple shapes
}
\keyword{dynamic}
