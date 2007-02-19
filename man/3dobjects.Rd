\name{points3d}
\alias{points3d}
\alias{lines3d}
\alias{segments3d}
\alias{triangles3d}
\alias{quads3d}
\title{add primitive set shape}
\description{
Adds a shape node to the current scene
}
\usage{
points3d(x, y = NULL, z = NULL,  ...)
lines3d(x, y = NULL, z = NULL,  ...)
segments3d(x, y = NULL, z = NULL, ...)
triangles3d(x, y = NULL, z = NULL, ...)
quads3d(x, y = NULL, z = NULL, ...)
}
\arguments{
  \item{x, y, z}{coordinates. Any reasonable way of defining the
    coordinates is acceptable.  See the function \code{\link[grDevices]{xyz.coords}}
    for details.}
  \item{ ... }{Material properties (see \code{\link{rgl.material}}), normals and 
  texture coordinates (see \code{\link{rgl.primitive}}).}  
}
\details{

The functions \code{points3d}, \code{lines3d}, \code{segments3d},
\code{triangles3d} and \code{quads3d} add points, joined lines, line segments,
filled triangles or quadrilaterals to the plots.  They correspond to the OpenGL types
\code{GL_POINTS, GL_LINE_STRIP, GL_LINES, GL_TRIANGLES} and \code{GL_QUADS} respectively.  

Points are taken in pairs by \code{segments3d}, triplets as the vertices
of the triangles, and quadruplets for the quadrilaterals.  Colours are applied vertex by vertex; 
if different at each end of a line segment, or each vertex of a polygon, the colours
are blended over the extent of the object.  Quadrilaterals must be entirely 
in one plane and convex, or the results are undefined.

These functions call the lower level functions \code{\link{rgl.points}}, \code{\link{rgl.linestrips}},
and so on, and are provided for convenience.  

The appearance of the new objects are defined by the material properties.
See \code{\link{rgl.material}} for details.

The principal difference between the \code{rgl.*} functions and the \code{*3d} functions 
is that the former make persistent changes to material properties with each call, 
whereas the latter make temporary changes only for the duration of the call.
}
\value{
   Each function returns the integer object ID of the shape that
   was added to the scene.  These can be passed to \code{\link{rgl.pop}}
   to remove the object from the scene.
}
\author{
  Ming Chen and Duncan Murdoch
}

\examples{
# Show 12 random vertices in various ways. 

M <- matrix(rnorm(36), 3, 12, dimnames=list(c('x','y','z'), 
                                       rep(LETTERS[1:4], 3)))

# Force 4-tuples to be convex in planes so that quads3d works.

for (i in c(1,5,9)) {
    quad <- as.data.frame(M[,i+0:3])
    coeffs <- runif(2,0,3)
    if (mean(coeffs) < 1) coeffs <- coeffs + 1 - mean(coeffs)
    quad$C <- with(quad, coeffs[1]*(B-A) + coeffs[2]*(D-A) + A)
    M[,i+0:3] <- as.matrix(quad)
}

open3d()

# Rows of M are x, y, z coords; transpose to plot

M <- t(M)
shift <- matrix(c(-3,3,0), 12, 3, byrow=TRUE)

points3d(M, size=2)
lines3d(M + shift)
segments3d(M + 2*shift)
triangles3d(M + 3*shift, col='red')
quads3d(M + 4*shift, col='green')  
text3d(M + 5*shift, texts=1:12)

# Add labels

shift <- outer(0:5, shift[1,])
shift[,1] <- shift[,1] + 3
text3d(shift, 
       texts = c('points3d','lines3d','segments3d',
         'triangles3d', 'quads3d','text3d'),
       adj = 0)
 rgl.bringtotop()
}
\keyword{dynamic}
