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
  \item{type}{Possible types are
    \itemize{
      \item \code{"shapes"} to clear all model datas
      \item \code{"lights"} to clear all lights
      \item \code{"bbox"}   remove bounding box
    }
  }
}
\details{
rgl holds a stack for shapes and lights. \code{rgl.clear} clears the stack,
while \code{rgl.pop} pops off the top-most (last added) node on the stack.
}
\seealso{
\code{\link{rgl}}
}
\keyword{dynamic}
