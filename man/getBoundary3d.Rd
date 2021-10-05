\name{getBoundary3d}
\alias{getBoundary3d}
\title{
Extract the boundary of a mesh
}
\description{
Constructs a mesh of line segments corresponding to
non-shared (i.e. boundary) edges of triangles or quads
in the original mesh.
}
\usage{
getBoundary3d(mesh, sorted = FALSE, simplify = TRUE)
}
\arguments{
  \item{mesh}{
A mesh object.
}
  \item{sorted}{
Whether the result should have the segments sorted in
sequential order.
}
  \item{simplify}{
Whether to simplify the resulting mesh, dropping all unused
vertices.  If \code{FALSE}, the vertices of the result will 
be identical to the vertices of \code{mesh}; if \code{TRUE},
they will likely be different, even if no vertices were dropped.
  }
}
\value{
A \code{"mesh3d"} object containing 0 or more segments.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{mesh3d}}
}
\examples{
x <- cube3d()
x$ib <- x$ib[,-(1:2)]
b <- getBoundary3d(x, sorted = TRUE)

open3d(); shade3d(x, alpha=0.2, col = "blue"); shade3d(b) 
text3d(t(x$vb), text = 1:ncol(x$vb), adj = 0)

# Show edge vertices in sequence:
c(b$is[1,1], b$is[2,]) 
}
