\name{readSTL}
\alias{readSTL}
\alias{writeSTL}
\title{
Read and write STL (stereolithography) format files
}
\description{
These functions read and write STL files.  This is a simple file format that
is commonly used in 3D printing.  It does not represent text,
only triangles.  The \code{writeSTL} function converts some RGL object
types to triangles.
}
\usage{
readSTL(con, ascii = NA, plot = TRUE, ...)
writeSTL(con, ascii = FALSE, 
         pointRadius = 0.005, 
         pointShape = icosahedron3d(),
         lineRadius = pointRadius,
         lineSides = 20,
         ids = tagged3d(tags),
         tags = NULL)
}
\arguments{
  \item{con}{
A connection or filename.
}
  \item{ascii}{
Whether to use the ASCII format or the binary format.  The
default \code{NA} setting for \code{readSTL()} causes it
to detect the format.  This only works for files, not other
connections, which default to binary.
}
  \item{plot}{
On reading, should the object be plotted?
}
  \item{\dots}{
If plotting, other parameters to pass to \code{\link{triangles3d}}
}
  \item{pointRadius, lineRadius}{
The radius of points and lines relative to the overall scale of the figure.
}
  \item{pointShape}{
A mesh shape to use for points.  It is scaled by the \code{pointRadius}.
}
  \item{lineSides}{
Lines are rendered as cylinders with this many sides.
}
  \item{ids}{
The identifiers (from \code{\link{ids3d}}) of the
objects to write.  If \code{NULL}, try to write everything.
}
 \item{tags}{
Alternate way to specify \code{ids}.  Ignored if \code{ids} is
given. 
 }
}
\details{
The current implementation is limited.  For reading, it ignores normals
and color information.  For writing, it only outputs triangles, quads, planes, spheres,
points, line segments, line strips and surfaces, and does not write color information.
Lines and points are rendered in an isometric scale:  if your data scales vary, they
will look strange.

Since the STL format only allows one object per file, all RGL objects
are combined into a single object when output.

The output file is readable by Blender and Meshlab; the latter can write in
a number of other formats, including U3D, suitable for import into a PDF document.

}
\value{
\code{readSTL} invisibly returns the object id if \code{plot = TRUE}, or (visibly) 
a matrix of vertices of the triangles if not.

\code{writeSTL} invisibly returns the name of the connection to which the 
data was written.
}
\references{
The file format was found on Wikipedia on October 25, 2012.  I learned
about the STL file format from David Smith's blog reporting on 
Ian Walker's \code{r2stl} function.  
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{scene3d}} saves a copy of a scene to an R variable;
\code{\link{rglwidget}}, \code{\link{writeASY}}, \code{\link{writePLY}}, \code{\link{writeOBJ}} and \code{\link{writeSTL}}
write the scene to a file in various other formats.
}
\examples{
filename <- tempfile(fileext = ".stl")
open3d()
shade3d( icosahedron3d(col = "magenta") )
writeSTL(filename)
open3d()
readSTL(filename, col = "red")
}
\keyword{ graphics }
