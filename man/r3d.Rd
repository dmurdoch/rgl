\name{r3d}
\alias{r3d}
\title{Generic 3D interface}
\description{Generic 3D interface for 3D rendering and computational geometry.}
\details{  
  R3D provide an interface for 3d rendering and computation without dependency
  to a specific rendering implementation. Additionally, R3D comes up with a collection
  of 3D objects and geometry algorithms that can be applied.
  All r3d interface functions represent generic functions that delegate to implementation functions and
  are suffixed with '3d'.
  The interface can be grouped into 8 categories: Scene Management, Primitive Shapes,
  High-level Shapes, Geometry Objects, Visualization, Interaction, Transformation,
  Subdivision.  
  The rendering interface gives an abstraction to the underlying rendering model. It can
  be grouped into four categories:    
  \enumerate{
    \item{Scene Management:}{A 3D scene consists of shapes, lights and background environment.} 
    \item{Primitive Shapes:}{Generic primitive 3D graphics shapes such as points, lines, triangles, quadrangles and texts.} 
    \item{High-level Shapes:}{Generic high-level 3D graphics shapes such as spheres, sprites and terrain.}
    \item{Interaction:}{Generic interface to select points in 3D space using the pointer device.}
  }
  This interface comes up with a default rendering model implementation using rgl. 
  3D computation is supported through the use of object structures that live entirely in R.
  \enumerate{
    \item{Geometry Objects:}{Geometry and mesh objects allow to define high-level geometry for computational purpose such as quadrangle meshes (qmesh3d).}
    \item{Transformation:}{Generic interface to transform 3d objects.}
    \item{Visualization:}{Generic rendering of 3d objects such as dotted, wired or shaded.}
    \item{Computation:}{Generic subdivision of 3d objects.}
  }
}

\seealso{
\code{\link{points3d}}
\code{\link{lines3d}}
\code{\link{segments3d}}
\code{\link{triangles3d}}
\code{\link{quads3d}}
\code{\link{texts3d}}
\code{\link{spheres3d}}
\code{\link{sprites3d}}
\code{\link{terrain3d}}
\code{\link{select3d}}
\code{\link{dot3d}}
\code{\link{wire3d}}
\code{\link{shade3d}}
\code{\link{transform3d}}
\code{\link{rotate3d}}
\code{\link{subdivision3d}}
\code{\link{qmesh3d}}
\code{\link{cube3d}}
\code{\link{rgl}}
}

