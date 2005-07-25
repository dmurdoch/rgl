\name{matrices3d}
\alias{scale3d}
\alias{Translate3d}
\alias{rotate3d}
\alias{as.homogeneous}
\alias{as.euclidean}
\title{Work with homogeneous coordinates }
\description{
These functions construct 4x4 matrices for transformations
in the homogeneous coordinate system used by OpenGL, and translate
between homogeneous and Euclidean coordinates.
}
\usage{
scale3d(x, y, z)
Translate3d(x, y, z)
rotate3d(angle, x, y, z, matrix)
as.homogeneous(x)
as.euclidean(x)
}
\arguments{
  \item{x, y, z, angle, matrix}{See details} 
}
\details{
OpenGL uses homogeneous coordinates to handle perspective and affine
transformations.  The homogeneous point \code{(x, y, z, w)} corresponds
to the Euclidean point \code{(x/w, y/w, z/w)}.  The matrices produced by
this function are to be left-multiplied by a row vector 
of homogeneous coordinates; alternatively, the transpose of the result
can be right-multiplied by a column vector.

To compose transformations, use matrix multiplication.  The effect is
to apply the matrix on the left first, followed by the one on the right.

\code{scale3d} scales each coordinate by the given factor.  In Euclidean
coordinates, \code{(u, v, w)} is transformed to \code{(x*u, y*v, z*w)}.

\code{Translate3d} translates each coordinate by the given translation, i.e.
\code{(u,v,w)} is transformed to \code{(u+x,v+y,w+z)}.

\code{rotate3d} can be called in two ways.  With 
arguments \code{angle, x, y, z} it represents a rotation 
of \code{angle} radians about the axis 
\code{x, y, z}.  Alternatively, a 3x3 rotation matrix can be given;
it will be converted into the corresponding matrix in 4x4 homogeneous
coordinates.

Use \code{as.homogeneous(x)} to convert the Euclidean vector \code{x} to
homogeneous coordinates, and \code{as.euclidean(x)} for the reverse transformation.

}
\value{
A 4x4 matrix representing the requested transformation
in homogeneous coordinates.  
}
\author{ Duncan Murdoch }

\examples{
# A 90 degree rotation about the x axis:

rotate3d(pi/2, 1, 0, 0)

# Find what happens when you rotate (2,0,0) by 45 degrees about the y axis:

x <- as.homogeneous(c(2,0,0))
y <- x %*% rotate3d(pi/4, 0, 1, 0)
as.euclidean(y)

}
\keyword{ dynamic }
