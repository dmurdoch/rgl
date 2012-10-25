\name{readSTL}
\alias{readSTL}
\alias{writeSTL}
\title{
Read and write STL (stereolithography) format files
}
\description{
These functions read and write STL files.  This is a simple file format that
is commonly used in 3D printing.  It does not represent lines or text,
only triangles.  The \code{writeSTL} function converts some RGL object
types to triangles.
}
\usage{
readSTL(con, ascii = FALSE, plot = TRUE, ...)
writeSTL(con, ascii = FALSE)
}
\arguments{
  \item{con}{
A connection or filename.
}
  \item{ascii}{
Whether to use the ASCII format or the binary format.
}
  \item{plot}{
On reading, should the object be plotted?
}
  \item{\dots}{
If plotting, other parameters to pass to \code{\link{triangles3d}}
}
}
\details{
The current implementation is quite limited.  For reading, it ignores normals
and colour information.  For writing, it only outputs triangles, quads, planes and surfaces,
and does not write colour information.
}
\value{
\code{readSTL} invisibly returns the object id if \code{plot=TRUE}, or (visibly) 
a matrix of vertices of the triangles if not.

\code{writeSTL} invisibly returns the name of the connection to which the 
data was written.
}
\references{
The file format was found on Wikipedia on October 25, 2012.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{writeWebGL}} for a more capable way to output RGL scenes.
}
\examples{
filename <- tempfile()
open3d()
shade3d( icosahedron3d(col="magenta") )
writeSTL(filename)
open3d()
readSTL(filename, col="red")
}
\keyword{ graphics }
