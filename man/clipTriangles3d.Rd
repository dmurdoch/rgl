\name{clipTriangles3d}
\alias{clipTriangles3d}
\title{
Clip triangles to general region
}
\description{
Modifies a matrix of triangle vertices so that values of 
a function are bounded.
}
\usage{
clipTriangles3d(triangles, fn, bound = 0, greater = TRUE, attributes = NULL)
}
\arguments{
  \item{triangles}{
A \code{3m x 3} matrix of vertices of triangles.
}
  \item{fn}{
A function used to determine clipping, or a vector of \code{3m} values from such
a function.
}
  \item{bound}{
The value(s) of \code{fn} on the clipping boundary.
}
  \item{greater}{
Logical; whether to keep \code{fn >= bound} or not.
}
  \item{attributes}{
If not \code{NULL}, a vector or matrix-like object (i.e. a matrix, dataframe, tibble, etc.) of characteristics associated with each vertex
in \code{triangles}.  These will be propagated to the 
result.
}
}
\details{
This function transforms a matrix of vertices that would be
used to draw a collection of triangles.  Modifications depend
on how many of the vertices satisfy the condition 
(\code{fn >= bound} or \code{fn <= bound}, depending on \code{greater})
for inclusion:  
\itemize{
\item If no vertices in a triangle satisfy the condition, the triangle is omitted.
\item If one vertex satisfies the condition, the other two vertices
in that triangle are shrunk towards it by assuming \code{fn}
is locally linear.
\item If two vertices satisfy the condition, the third vertex
is shrunk along each edge towards each other vertex, forming a
quadrilateral made of two new triangles.
\item If all vertices satisfy the condition, they are included
with no modifications.
}
}
\value{
A new matrix of vertices that all (approximately) satisfy the
clipping condition.  Note that the order of vertices will likely
differ from the original order.

If \code{attributes} is not \code{NULL}, it will be included
in the result as an attribute named \code{"attributes"}, reordered
consistently with the vertices.
}
\author{
Duncan Murdoch
}
\references{
See \url{https://stackoverflow.com/q/56242470/2554330} for the 
motivating example.
}
\examples{
m <- 1000
triangles <- matrix(rep(rnorm(3*m), each = 3) + 
                    rnorm(9*m, sd = 0.1), 3*m, 3)

col <- rep(cm.colors(m), each=3)

# Clip triangles to lie within a unit sphere

fn <- function(triangles) rowSums(triangles^2)
modified <- clipTriangles3d(triangles, fn, bound = 1, 
                            greater = FALSE, attributes = col)
open3d()
triangles3d(modified, col = attr(modified, "attributes"))
}