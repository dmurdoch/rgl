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
    coordinates is acceptable.  See the function \code{\link{xyz.coords}}
    for details.}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
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
in one plane, or the results are undefined.

These functions call the lower level functions \code{\link{rgl.points}}, \code{\link{rgl.linestrips}},
and so on, and are provided for convenience.

The appearance of the new objects are defined by the material properties.
See \code{\link{rgl.material}} for details.
}
\author{
  Ming Chen and Duncan Murdoch
}

\examples{
# Show 12 random vertices in various ways. 
x <- rnorm(12)
y <- rnorm(12)
z <- rnorm(12)

# Force 4-tuples into planes so that quads3d works.

M<-cbind(x,y,z)
i<-c(1,5,9)
A<-(M[i,]-M[i+1,])
C<-(M[i+2,]-M[i+1,])
D<-(M[i+3,]-M[i+1,])

coeffs <- matrix(NA, 3, 2)

for(t in c(1:3))
    coeffs[t,]<-pmax(1, abs(coefficients(lm(D[t,] ~ A[t,]+C[t,]-1))))
    
M[i+3,] <- coeffs[,1]*A + coeffs[,2]*C + M[i+1,]
x <- M[,1]
y <- M[,2]
z <- M[,3]

rgl.open()

points3d(x,y,z)
lines3d(x-3,y+3,z)
segments3d(x-6,y+6,z)
triangles3d(x-9,y+9,z,col='red')
quads3d(x-12,y+12,z,col='green')  
text3d(x-15,y+15,z,1:12)

# Add labels

text3d(-3*(0:5)+3, 3*(0:5), 0, 
       c('points3d','lines3d','segments3d',
         'triangles3d', 'quads3d','text3d'),
       adj = 0)
 rgl.bringtotop()
}
\keyword{dynamic}
