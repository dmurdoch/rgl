\name{GramSchmidt}
\alias{GramSchmidt}
\title{
The Gram-Schmidt algorithm
}
\description{
Generate a 3x3 orthogonal matrix using the Gram-Schmidt algorithm.
}
\usage{
GramSchmidt(v1, v2, v3, order = 1:3)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{v1, v2, v3}{
Three length 3 vectors (taken as row vectors).
}
  \item{order}{
The precedence order for the vectors; see Details.
}
}
\details{
This function orthogonalizes the matrix \code{rbind(v1, v2, v3)}
using the Gram-Schmidt algorithm.  It can handle rank 2 matrices
(returning a rank 3 matrix).  If the original is rank 1, it is likely
to fail.

The \code{order} vector determines the precedence of the original
vectors. For example, if it is \code{c(i,j,k)}, then row \code{i} 
will be unchanged (other than normalization); row \code{j} will
normally be transformed within the span of rows \code{i} and \code{j}.  
Row \code{k} will be transformed orthogonally to the span of
the others.
}
\value{
A 3x3 matrix whose rows are the orthogonalization of the original
row vectors.
}
\author{
Duncan Murdoch
}
\examples{
# Proceed through the rows in order
print(A <- matrix(rnorm(9), 3,3))
GramSchmidt(A[1,], A[2,], A[3,])

# Keep the middle row unchanged
print(A <- matrix(c(rnorm(2), 0, 1, 0, 0, rnorm(3)), 3,3, byrow = TRUE))
GramSchmidt(A[1,], A[2,], A[3,], order=c(2,1,3))
}
