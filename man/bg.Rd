\name{rgl.bg}
\alias{rgl.bg}
\title{setup Background}
\description{
  Setup the background environment in the scene.
}
\usage{
rgl.bg( sphere = FALSE, fogtype = "none", color=c("black","white"), back="lines", ...)
}
\arguments{
  \item{fogtype}{fog type:
    \itemize{
      \item \code{"none"}   no fog
      \item \code{"linear"} linear fog function
      \item \code{"exp"}    exponential fog function
      \item \code{"exp2"}   squared exponential fog function
    }
  }
  \item{sphere}{
  logical, if true, an environmental sphere geometry is used for background decoration
  }
  \item{color}{
  Primary color is used for background clearing.
  Secondary color is used for sphere geometry. See \code{\line{rgl.material}} for details.
  }
  \item{back}{
  Specifies the fill style of the sphere geometry. See \code{\line{rgl.material}} for details.
  }
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
}
\details{
  If sphere is set TRUE, an environmental sphere enclosing the whole scene is drawn.
}
\examples{

  # the holo-globe (inspired by star trek):

  rgl.bg(sphere=TRUE, color=c("black","green"), lit=FALSE, back="lines" )

  # an environmental sphere with a nice texture.

  rgl.bg(sphere=TRUE, texture= system.file("textures/sunsleep.png",package="rgl"), back="filled" )
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
