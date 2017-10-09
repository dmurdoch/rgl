\name{writeOBJ}
\alias{writeOBJ}
\alias{readOBJ}
\title{
Write Wavefront OBJ format files; read simple ones
}
\description{
\code{writeOBJ} writes OBJ files.  This is a file format that
is commonly used in 3D graphics applications.  It does not represent text,
but does represent points, lines, polygons (and many other types that
RGL doesn't support).  \code{readOBJ} reads only some parts
of OBJ files.
}
\usage{
writeOBJ(con, 
         pointRadius = 0.005, pointShape = icosahedron3d(), 
         lineRadius = pointRadius, lineSides = 20, 
         pointsAsPoints = FALSE, linesAsLines = FALSE, 
         withNormals = TRUE, withTextures = TRUE, 
         separateObjects = TRUE,
         ids = NULL)
readOBJ(con, ...)
}
\arguments{
  \item{con}{
A connection or filename.
}
  \item{pointRadius, lineRadius}{
The radius of points and lines relative to the overall scale of the figure,
if they are converted to polyhedra.
}
  \item{pointShape}{
A mesh shape to use for points if they are converted.  It is scaled by the \code{pointRadius}.
}
  \item{lineSides}{
Lines are rendered as cylinders with this many sides.
}
  \item{pointsAsPoints, linesAsLines}{
Whether to convert points and lines to \dQuote{point} and \dQuote{line} records in the OBJ output.
}
  \item{withNormals}{
Whether to output vertex normals for smooth shading.
}
  \item{separateObjects}{
Whether to mark each RGL object as a separate object in the file.
}
  \item{withTextures}{
Whether to output texture coordinates.
}
  \item{ids}{
The identifiers (from \code{\link{rgl.ids}}) of the
objects to write.  If \code{NULL}, try to write everything.
}

  \item{...}{
Additional arguments (typically just \code{material}) to pass to
\code{\link{tmesh3d}}.
  }

}
\details{

The current \code{writeOBJ} implementation only outputs triangles, quads, planes, spheres,
points, line segments, line strips and surfaces.  It does not output material
properties such as colors, since the OBJ format does not support the per-vertex
colors that RGL uses.  

The \code{readOBJ} implementation can
only read faces and normals, and ignores 
information about textures.

The defaults for \code{pointsAsPoints} and \code{linesAsLines} have been
chosen because Blender (\url{http://www.blender.org}) does not import
points or lines, only polygons.  If you are exporting to other software you
may want to change them.

If present, texture coordinates are output by default, but the
textures themselves are not.

Individual RGL objects are output as separate objects in the file when 
\code{separateObjects = TRUE}, the default.

The output file should be readable by Blender and Meshlab; the latter can write in
a number of other formats, including U3D, suitable for import into a PDF document.
}
\value{
\code{writeObj} invisibly returns the name of the connection to which the 
data was written.

\code{readObj} returns a mesh object constructed
from the input file.
}
\references{
The file format was found at \url{http://www.martinreddy.net/gfx/3d/OBJ.spec}
on November 11, 2012.  
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{scene3d}} saves a copy of a scene to an R variable; \code{\link{writeWebGL}}, \code{\link{writeASY}},
\code{\link{writePLY}} and \code{\link{writeSTL}}
write the scene to a file in various other formats.
}
\examples{
filename <- tempfile(fileext = ".obj")
open3d()
shade3d( icosahedron3d() )
writeOBJ(filename)

# The motivation for writing readObj() was to read this shape
# file of Comet 67P/Churyumov-Gerasimenko, from the ESA:
\donttest{
open3d()
shade3d(readOBJ(url(
"http://sci.esa.int/science-e/www/object/doc.cfm?fobjectid=54726"
), material = list(col = "gray")))
}
}
\keyword{ graphics }
