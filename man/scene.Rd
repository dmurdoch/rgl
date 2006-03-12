\name{scene}
\alias{rgl.clear}
\alias{rgl.pop}
\alias{clear3d}
\alias{pop3d}
\title{scene management}
\description{
Clear shapes, lights, bbox
}
\usage{
clear3d( type = c("shapes", "bboxdeco") ) 
rgl.clear( type = "shapes" )
pop3d( ... )
rgl.pop( type = "shapes" )  
}
\arguments{
  \item{type}{Select subtype(s):
    \describe{
      \item{"shapes"}{shape stack}
      \item{"lights"}{light stack}
      \item{"bboxdeco"}{bounding box}
      \item{"viewpoint"}{viewpoint}
      \item{"all"}{all of the above}
    }
  }
  \item{...}{generic arguments passed through to RGL-specific (or other) functions}
}
\details{
RGL holds two stacks. One is for shapes and the other is for lights. 
\code{clear3d} and \code{rgl.clear} clear the specified stack, or restore
the defaults for the bounding box (not visible) or viewpoint.  \code{rgl.pop} removes 
the top-most (last added) node on the shape stack.

Note that clearing the light stack leaves the scene in darkness; it should normally
be followed by a call to \code{\link{rgl.light}} or \code{\link{light3d}}.
}
\seealso{
\code{\link{rgl}}
\code{\link{rgl.bbox}}
\code{\link{rgl.light}}
}
\keyword{dynamic}
