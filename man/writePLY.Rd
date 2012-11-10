\name{writePLY}
\alias{writePLY}
\title{
Write Stanford PLY format files
}
\description{
This function writes PLY files.  This is a simple file format that
is commonly used in 3D printing.  It does not represent text,
only edges and polygons.  The \code{writePLY} function 
does the necessary conversions.

}
\usage{
writePLY(con, format = c("little_endian", "big_endian", "ascii"), 
         pointRadius = 0.005, pointShape = icosahedron3d(), 
         lineRadius = pointRadius, lineSides = 20, 
         pointsAsEdges = FALSE, linesAsEdges = pointsAsEdges, 
         withColors = TRUE, withNormals = !(pointsAsEdges || linesAsEdges), 
         ids = NULL)
}
\arguments{
  \item{con}{
A connection or filename.
}
  \item{format}{
Which output format.  Defaults to little-endian binary.
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
  \item{pointsAsEdges, linesAsEdges}{
Whether to convert points and lines to \dQuote{Edge} records in the PLY output.
}
  \item{withColors}{
Whether to output vertex colour information.
}
  \item{withNormals}{
Whether to output vertex normals for smooth shading.
}
  \item{ids}{
The identifiers (from \code{\link{rgl.ids}}) of the
objects to write.  If \code{NULL}, try to write everything.
}

}
\details{

The current implementation only outputs triangles, quads, planes, spheres,
points, line segments, line strips and surfaces.
}
\value{
Invisibly returns the name of the connection to which the 
data was written.
}
\references{
The file format was found at \url{http://www.mathworks.com/matlabcentral/fx_files/5459/1/content/ply.htm}
on November 10, 2012.  
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{writeWebGL}} for a more capable way to output an RGL scenes, or \code{\link{writeSTL}} for a
simpler one.
}
\examples{
filename <- tempfile()
open3d()
shade3d( icosahedron3d(col="magenta") )
writePLY(filename)
}
\keyword{ graphics }

