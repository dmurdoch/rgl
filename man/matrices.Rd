\name{matrices}
\alias{matrices}
\alias{identityMatrix}
\alias{scaleMatrix}
\alias{translationMatrix}
\alias{rotationMatrix}
\alias{scale3d}
\alias{translate3d}
\alias{rotate3d}
\alias{transform3d}
\alias{asHomogeneous}
\alias{asEuclidean}
\title{Work with homogeneous coordinates }
\description{
These functions construct 4x4 matrices for transformations
in the homogeneous coordinate system used by OpenGL, and translate
vectors between homogeneous and Euclidean coordinates.
}
\usage{
identityMatrix()
scaleMatrix(x, y, z)
translationMatrix(x, y, z)
rotationMatrix(angle, x, y, z, matrix)
asHomogeneous(x)
asEuclidean(x)

scale3d(obj, x, y, z, ...)
translate3d(obj, x, y, z, ...)
rotate3d(obj, angle, x, y, z, matrix, ...)

transform3d(obj, matrix, ...)

}
\arguments{
  \item{x, y, z, angle, matrix}{See details} 
  \item{obj}{An object to be transformed}
  \item{...}{Additional parameters to be passed to methods}
}
\details{
OpenGL uses homogeneous coordinates to handle perspective and affine
transformations.  The homogeneous point \code{(x, y, z, w)} corresponds
to the Euclidean point \code{(x/w, y/w, z/w)}.  The matrices produced by
the functions \code{scaleMatrix}, \code{translationMatrix}, and \code{rotationMatrix}
are to be left-multiplied by a row vector 
of homogeneous coordinates; alternatively, the transpose of the result
can be right-multiplied by a column vector.  The generic functions
\code{scale3d}, \code{translate3d} and \code{rotate3d} apply these transformations
to the \code{obj} argument.  The \code{transform3d} function is a synonym 
for \code{rotate3d(obj, matrix=matrix)}.

By default, it is assumed that \code{obj} is a row vector
(or a matrix of row vectors) which will be multiplied on the right by
the corresponding matrix, but users may write methods for these generics
which operate differently.  Methods are supplied for \code{\link{qmesh3d}}
objects.

To compose transformations, use matrix multiplication.  The effect is
to apply the matrix on the left first, followed by the one on the right.

\code{identityMatrix} returns an identity matrix.

\code{scaleMatrix} scales each coordinate by the given factor.  In Euclidean
coordinates, \code{(u, v, w)} is transformed to \code{(x*u, y*v, z*w)}.

\code{translationMatrix} translates each coordinate by the given translation, i.e.
\code{(u,v,w)} is transformed to \code{(u+x,v+y,w+z)}.

\code{rotationMatrix} can be called in three ways.  With 
arguments \code{angle, x, y, z} it represents a rotation 
of \code{angle} radians about the axis 
\code{x, y, z}.  If a 3x3 rotation matrix can be given;
it will be converted into the corresponding matrix in 4x4 homogeneous
coordinates.  Finally, if a 4x4 matrix is given, it will be returned unchanged.
(The latter behaviour is used to allow \code{transform3d} to act like a 
generic function, even though it is not.)

Use \code{asHomogeneous(x)} to convert the Euclidean vector \code{x} to
homogeneous coordinates, and \code{asEuclidean(x)} for the reverse transformation.

}
\value{
\code{identityMatrix},
\code{scaleMatrix}, \code{translationMatrix}, and \code{rotationMatrix} produce
a 4x4 matrix representing the requested transformation
in homogeneous coordinates.  

\code{scale3d}, \code{translate3d} and \code{rotate3d} transform the object
and produce a new object of the same class.
}
\author{ Duncan Murdoch }
\seealso{\code{\link{par3d}} for a description of how rgl uses matrices in
rendering.}

\examples{
# A 90 degree rotation about the x axis:

rotationMatrix(pi/2, 1, 0, 0)

# Find what happens when you rotate (2,0,0) by 45 degrees about the y axis:

x <- asHomogeneous(c(2,0,0))
y <- x %*% rotationMatrix(pi/4, 0, 1, 0)
asEuclidean(y)

# or more simply...

rotate3d(c(2,0,0), pi/4, 0, 1, 0)

}
\keyword{ dynamic }
