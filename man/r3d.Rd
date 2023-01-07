\name{r3d}
\alias{r3d}
\title{Generic 3D interface}
\description{Generic 3D interface for 3D rendering and computational geometry.}
\details{  
  R3d is a design for an interface for 3d rendering and computation without dependency
  on a specific rendering implementation. R3d includes a collection
  of 3D objects and geometry algorithms.
  All r3d interface functions are named \code{*3d}.  They represent generic functions that delegate 
  to implementation functions.
  
  The interface can be grouped into 8 categories: Scene Management, Primitive Shapes,
  High-level Shapes, Geometry Objects, Visualization, Interaction, Transformation,
  Subdivision.  
  
  The rendering interface gives an abstraction to the underlying rendering model. It can
  be grouped into four categories:    
  \describe{
    \item{Scene Management:}{A 3D scene consists of shapes, lights and background environment.} 
    \item{Primitive Shapes:}{Generic primitive 3D graphics shapes such as points, lines, triangles, quadrangles and texts.} 
    \item{High-level Shapes:}{Generic high-level 3D graphics shapes such as spheres, sprites and terrain.}
    \item{Interaction:}{Generic interface to select points in 3D space using the pointer device.}
  }
  
  In this package we include an implementation of r3d using the underlying \code{rgl.*} functions.
  
  3D computation is supported through the use of object structures that live entirely in R.
  \describe{
    \item{Geometry Objects:}{Geometry and mesh objects allow to define high-level geometry for computational purpose such as triangle or 
                             quadrangle meshes (see \code{\link{mesh3d}}).}
    \item{Transformation:}{Generic interface to transform 3d objects.}
    \item{Visualization:}{Generic rendering of 3d objects such as dotted, wired or shaded.}
    \item{Computation:}{Generic subdivision of 3d objects.}
  }
  
  At present, the main practical differences between the r3d functions
  and the \code{rgl.*} functions are as follows. 
  
  The r3d functions call
  \code{\link{open3d}} if there is no device open, and the
  \code{rgl.*} functions call \code{\link{rgl.open}}. By default
  \code{\link{open3d}} sets the initial orientation of the coordinate
  system in 'world coordinates', i.e. a right-handed coordinate system
  in which the x-axis increases from left to right, the y-axis
  increases with depth into the scene, and the z-axis increases from
  bottom to top of the screen.  \code{rgl.*} functions, on the other
  hand, use a right-handed coordinate system similar to that used in
  OpenGL.  The x-axis matches that of r3d, but the y-axis increases
  from bottom to top, and the z-axis decreases with depth into the
  scene.  Since the user can manipulate the scene, either system can
  be rotated into the other one.  
  
  The r3d functions also preserve the \code{rgl.material} setting across
  calls (except for texture elements, in the current implementation), whereas
  the deprecated \code{rgl.*} functions leave it as set by the last call.
  
  The example code below illustrates the two coordinate systems.
}

\seealso{
\code{\link{points3d}},
\code{\link{lines3d}},
\code{\link{segments3d}},
\code{\link{triangles3d}},
\code{\link{quads3d}},
\code{\link{text3d}},
\code{\link{spheres3d}},
\code{\link{sprites3d}},
\code{\link{terrain3d}},
\code{\link{select3d}},
\code{\link{dot3d}},
\code{\link{wire3d}},
\code{\link{shade3d}},
\code{\link{transform3d}},
\code{\link{rotate3d}},
\code{\link{subdivision3d}},
\code{\link{mesh3d}},
\code{\link{cube3d}},
\code{\link{rgl}}
}
\examples{
    
     x <- c(0, 1, 0, 0)
     y <- c(0, 0, 1, 0)
     z <- c(0, 0, 0, 1)
     labels <- c("Origin", "X", "Y", "Z")
     i <- c(1, 2, 1, 3, 1, 4)

     # *3d interface
     
     open3d()
     text3d(x, y, z, labels)
     text3d(1, 1, 1, "*3d coordinates")
     segments3d(x[i], y[i], z[i])
}

\keyword{dynamic}
