\name{scene}
\alias{rgl.clear}
\alias{rgl.pop}
\alias{clear3d}
\alias{pop3d}
\alias{rgl.ids}
\title{scene management}
\description{
Clear shapes, lights, bbox
}
\usage{
clear3d( type = c("shapes", "bboxdeco", "material"), defaults ) 
rgl.clear( type = "shapes" )
pop3d( ... )
rgl.pop( type = "shapes", id = 0 )  
rgl.ids( type = "shapes" )
}
\arguments{
  \item{type}{Select subtype(s):
    \describe{
      \item{"shapes"}{shape stack}
      \item{"lights"}{light stack}
      \item{"bboxdeco"}{bounding box}
      \item{"userviewpoint"}{user viewpoint}
      \item{"modelviewpoint"}{model viewpoint}
      \item{"material"}{material properties}
      \item{"background"}{scene background}
      \item{"subscene"}{subscene list}
      \item{"all"}{all of the above}
    }
  }
  \item{defaults}{default values to use after clearing}
  \item{id}{vector of ID numbers of items to remove}
  \item{...}{generic arguments passed through to RGL-specific (or other) functions}
}
\details{
RGL holds several lists of objects in each scene. 
There are lists for shapes, lights, bounding box decorations, subscenes, etc.
\code{clear3d} and \code{rgl.clear} clear the specified stack, or restore
the defaults for the bounding box (not visible) or viewpoint. 
With \code{id=0} \code{rgl.pop} removes 
the last added node on the list (except for subscenes:  there it
removes the active subscene).  The \code{id} argument
may be used to specify arbitrary item(s) to remove; if \code{id != 0}, 
the \code{type} argument is ignored.

\code{rgl.clear} and \code{clear3d} may also be used to clear material properties
back to their defaults.  

\code{clear3d} has an optional \code{defaults} argument, which defaults to 
\code{\link{r3dDefaults}}.  Only the \code{materials} component of this argument
is currently used by \code{clear3d}.

\code{rgl.ids} returns a dataframe containing the IDs in the currently active
rgl window, along with an indicator of their type.

For convenience, \code{type="shapes"} and 
\code{id=1} signifies the bounding box.

Note that clearing the light stack leaves the scene in darkness; it should normally
be followed by a call to \code{\link{rgl.light}} or \code{\link{light3d}}.
}
\seealso{
\code{\link{rgl}},
\code{\link{rgl.bbox}},
\code{\link{rgl.light}},
\code{\link{open3d}} to open a new window.
}
\examples{
  x <- rnorm(100)
  y <- rnorm(100)
  z <- rnorm(100)
  p <- plot3d(x, y, z, type='s')
  rgl.ids()
  lines3d(x, y, z)
  rgl.ids()
  if (interactive()) {
    readline("Hit enter to change spheres")
    rgl.pop(id = p["data"])
    spheres3d(x, y, z, col="red", radius=1/5)
    box3d()
  }
}
\keyword{dynamic}
