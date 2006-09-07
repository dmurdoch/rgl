\name{bg}
\alias{rgl.bg}
\alias{bg3d}
\title{Set up Background}
\description{
  Setup the background environment of the scene.
}
\usage{
bg3d(...) 
rgl.bg( sphere = FALSE, fogtype = "none", color=c("black","white"), back="lines", ...)

}
\arguments{
  \item{fogtype}{fog type:
    \describe{
      \item{"none"}{no fog}
      \item{"linear"}{linear fog function}
      \item{"exp"}{exponential fog function}
      \item{"exp2"}{squared exponential fog function}
    }
  }
  \item{sphere}{
  logical, if true, an environmental sphere geometry is used for the background decoration.
  }
  \item{color}{
  Primary color is used for background clearing and as fog color.
  Secondary color is used for background sphere geometry. See \code{\link{rgl.material}} for details.
  }
  \item{back}{
  Specifies the fill style of the sphere geometry. See \code{\link{rgl.material}} for details.
  }
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}  
}
\details{
  If sphere is set to TRUE, an environmental sphere enclosing the whole scene is drawn.
}
\examples{
  rgl.open()
  
  # a simple white background
  
  bg3d("white")

  # the holo-globe (inspired by star trek):

  rgl.bg(sphere=TRUE, color=c("black","green"), lit=FALSE, back="lines" )

  # an environmental sphere with a nice texture.

  rgl.bg(sphere=TRUE, texture=system.file("textures/sunsleep.png", package="rgl"), back="filled" )
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
