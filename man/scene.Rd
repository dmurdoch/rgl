\name{rgl.clear}
\alias{rgl.clear}
\alias{rgl.pop}
\title{scene management}
\description{
Clear shapes, lights, bbox
}
\usage{
rgl.clear( type = "shapes" )
rgl.pop( type = "shapes" )  
}
\arguments{
  \item{type}{Select subtype:
    \describe{
      \item{"shapes"}{shape stack}
      \item{"lights"}{light stack}
      \item{"bbox"}{bounding box}
    }
  }
}
\details{
RGL holds two stacks. One for shapes and another for lights. 
\code{rgl.clear} clears the specified stack, while \code{rgl.pop} pops off 
the top-most (last added) node on the stack.
Additionally as the bounding box is an optional element, one can disable it 
by calling \code{rgl.clear} on it.
}
\seealso{
\code{\link{rgl}}
\code{\link{rgl.bbox}}
\code{\link{rgl.light}}
}
\keyword{dynamic}
