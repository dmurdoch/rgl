\name{mesh3d}
\alias{shape3d}
\alias{mesh3d}
\alias{qmesh3d}
\alias{tmesh3d}

\title{Construct 3D mesh objects}
\description{
Creates meshes containing points, segments, triangles and quads.
}
\usage{
  mesh3d( x, y = NULL, z = NULL, vertices, homogeneous = TRUE,
                    material = NULL,
                    normals = NULL, texcoords = NULL,
                    points = NULL, segments = NULL,
                    triangles = NULL, quads = NULL,
                    meshColor = c("vertices", "edges", "faces", "legacy"))
  qmesh3d(vertices, indices, homogeneous = TRUE, material = NULL, 
         normals = NULL, texcoords = NULL,
         meshColor = c("vertices", "edges", "faces", "legacy"))
  tmesh3d(vertices, indices, homogeneous = TRUE, material = NULL, 
         normals = NULL, texcoords = NULL,
         meshColor = c("vertices", "edges", "faces", "legacy"))
  
}
\arguments{
  \item{x, y, z}{coordinates.  Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{vertices}{A 3 or 4 row matrix of coordinates; takes
  precedence over \code{x, y, z}.  May also be given as a vector; then \code{homogeneous = TRUE} indicates it should be treated
  as 4 rows.}
  \item{homogeneous}{If \code{vertices} is given without 
  dimensions, \code{TRUE} indicates 4 homogeneous coordinates
  should be assumed.}
  \item{material}{material properties for later rendering}
  \item{normals}{normals at each vertex}
  \item{texcoords}{texture coordinates at each vertex}
  \item{points}{vector of indices of vertices to draw as points}
  \item{segments}{2xn matrix of indices of vertices to draw as
  segments}
  \item{triangles}{3xn matrix of indices of vertices to draw
  as triangles}
  \item{quads}{4xn matrix of indices of vertices to draw as quads}
  \item{indices}{(obsolete) 3xn or 4xn matrix of vertex indices}
  \item{meshColor}{how should colours be interpreted?  See details in \code{\link{shade3d}}.}
  }
\details{
  These functions create \code{mesh3d} objects, which consist of a matrix
  of vertex coordinates together with a matrices of indices indicating how the vertices should be displayed, and 
  material properties.

  The \code{"shape3d"} class is a general class for shapes that can be plotted
  by \code{dot3d}, \code{wire3d} or \code{shade3d}.
  
  The \code{"mesh3d"} class is a class of objects that form meshes: the vertices
  are in member \code{vb}, as a 4 by \code{n} matrix using
  homogeneous coordinates.  Indices of these vertices are
  contained in optional components \code{ip} for points,
  \code{is} for line segments, \code{it} for triangles, and
  \code{ib} for quads.
  Individual meshes may have any combination of these.

}
\value{
Objects of class \code{c("mesh3d",
  "shape3d")}. 
  
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
  wire3d( mesh3d(vertices = vertices, quads = indices) )
  
}
\seealso{
  \code{\link{shade3d}}, \code{\link{shapelist3d}} for multiple shapes
}
\keyword{dynamic}
