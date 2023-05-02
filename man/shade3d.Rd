\name{shade3d}
\alias{dot3d}
\alias{dot3d.mesh3d}
\alias{wire3d}
\alias{wire3d.mesh3d}
\alias{shade3d}
\alias{shade3d.mesh3d}

\title{Draw 3D mesh objects}
\description{
Draws 3D mesh objects in full, or just the edges, or just 
the vertices.
}
\usage{
  dot3d(x, ...)   # draw dots at the vertices of an object
  \method{dot3d}{mesh3d}(x, ...,
                         front = "points", back = "points")
  wire3d(x, ...)  # draw a wireframe object
  \method{wire3d}{mesh3d}(x, ...,
                          front = "lines", back = "lines")
  shade3d(x, ...) # draw a shaded object
  \method{shade3d}{mesh3d}(x, override = TRUE, 
                           meshColor = c("vertices", "edges", "faces", "legacy"), 
                           texcoords = NULL, ...,
                           front = "filled", back = "filled")
}
\arguments{
  \item{x}{a \code{mesh3d} object.}
  \item{...}{additional rendering parameters, or for
  \code{dots3d} and \code{wire3d}, parameters to pass
  to \code{shade3d}}
  \item{override}{should the parameters specified here override those stored in the object?}
  \item{meshColor}{how should colours be interpreted?  See details 
  below}
  \item{texcoords}{texture coordinates at each vertex.}
  \item{front, back}{Material properties for rendering.}
}
\details{
  
  The \code{meshColor} argument controls how material colours and textures are interpreted.  This parameter
was added in \pkg{rgl} version 0.100.1 (0.100.27 for \code{dot3d}).  Possible values are:
\describe{
\item{\code{"vertices"}}{Colours and texture coordinates are applied by vertex, in the order
they appear in the \code{x$vb} matrix.}
\item{\code{"edges"}}{Colours are applied to each edge:  first to the segments in the \code{x$is} matrix, then
the 
3 edges of each triangle in the \code{x$it} matrix, then the 4
edges of each quad in the \code{x$ib} matrix.  This mode
is only supported if both front and back materials are
\code{"lines"}, and the mesh contains no points.}
\item{\code{"faces"}}{Colours are applied to each object
in the mesh:  first to the points, then the segments, 
triangles and finally quads.  The entire whole face (or point or
segment) receives one colour from the specified colours.}
\item{\code{"legacy"}}{Colours and textures are applied in the same way
as in \pkg{rgl} versions earlier than 0.100.1.}
}
Unique partial matches of these values will be recognized.

If colours are specified but \code{meshColor} is not
and \code{options(rgl.meshColorWarning = TRUE)},
a warning will be given that their
interpretation may have changed.  In versions 0.100.1 to 0.100.26
of \pkg{rgl}, the default
was to give the warning; now the default is for no warning.

Note that since version 0.102.10, \code{meshColor = 
"edges"} is only allowed when drawing lines (the
\code{wire3d} default), and it may draw
edges more than once.  In general, if any rendering
draws twice at the same location, which copy is visible 
depends on the order of drawing and the
\code{\link{material3d}("depth_test")}
setting.  

Whether points, lines or solid faces are drawn is
determined in 3 steps:
\enumerate{
\item{If arguments \code{"front"} or \code{"back"} are
specified in the call, those are used.}
\item{If one or both of those arguments are not
specified, but the material properties are present in
the object, those are used.}
\item{If values are not specified in either of those
places, \code{shade3d} draws filled surfaces,
\code{wire3d} draws lines, and \code{dot3d} draws points.
}
}
Note:  For some versions of rgl up to version 0.107.15, 
rule 2 above was not respected.
}
\value{
  \code{dot3d}, \code{wire3d}, and \code{shade3d} are called for their side effect
  of drawing an object into the scene; they return an object ID (or vector of IDs) invisibly.
  
  See \link{primitives} for a discussion of texture coordinates.
}
\examples{

  # generate a quad mesh object

  vertices <- c( 
     -1.0, -1.0, 0,
      1.0, -1.0, 0,
      1.0,  1.0, 0,
     -1.0,  1.0, 0
  )
  indices <- c( 1, 2, 3, 4 )
  
  open3d()  
  wire3d( mesh3d(vertices = vertices, quads = indices) )
  
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
  \code{\link{mesh3d}}, \code{\link{par3d}}, \code{\link{shapelist3d}} for multiple shapes
}
\keyword{dynamic}
