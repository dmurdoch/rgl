\name{rgl-package}
\title{3D visualization device system}
\alias{rgl-package}
\alias{rgl}
\alias{RGL}
\description{
  3D real-time rendering system.
}
\details{
  RGL is a 3D real-time rendering system for R.
  Multiple windows are managed at a time. Windows
  may be divided into \dQuote{subscenes}, where one has the current focus
  that receives instructions from the R command-line. 
  The device design is oriented towards the R device metaphor. If you send
  scene management instructions, and there's no device open, it will be opened
  automatically.
  Opened devices automatically get the current device focus. The focus may be
  changed by using \code{\link{set3d}()} or \code{\link{useSubscene3d}()}.
  
RGL provides medium to high level functions for 3D interactive graphics, including
  functions modelled on base graphics (\code{\link{plot3d}()}, etc.) as well as functions for 
  constructing geometric objects (\code{\link{cube3d}()}, etc.).  Output
  may be on screen using OpenGL, or to various standard 3D file formats including 
  WebGL, PLY, OBJ, STL as well as 2D image formats, including PNG, Postscript, SVG, PGF.
  
  The \code{\link{open3d}()} function attempts to open a new RGL window,
  using default settings specified by the user.

  See the first example below to display the ChangeLog.
}
\seealso{\link{r3d} for a description of the \code{*3d} interface;
\code{\link{par3d}} for a description of scene properties and the rendering
pipeline; \code{\link{rgl.useNULL}} for a description of how to 
use RGL on a system with no graphics support.}
\examples{
if (!in_pkgdown_example())
  file.show(system.file("NEWS", package = "rgl"))
example(surface3d)
example(plot3d)
}
\keyword{dynamic}
