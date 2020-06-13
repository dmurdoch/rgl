\name{bg3d}
\alias{rgl.bg}
\alias{bg3d}
\title{Set up Background}
\description{
  Set up the background of the scene.
}
\usage{
bg3d(...) 
rgl.bg( sphere = FALSE, fogtype = "none", color = c("black", "white"), 
	back = "lines", ...)

}
\arguments{
  \item{fogtype}{fog type:
    \describe{
      \item{"none"}{no fog}
      \item{"linear"}{linear fog function}
      \item{"exp"}{exponential fog function}
      \item{"exp2"}{squared exponential fog function}
    }
    Fog only applies to objects with \code{\link{material3d}} 
    property \code{fog} set to \code{TRUE}.
  }
  \item{sphere}{
  logical, if true, an environmental sphere geometry is used for the background decoration.
  }
  \item{color}{
  Primary color is used for background clearing and as fog color.
  Secondary color is used for background sphere geometry. See \code{\link{material3d}} for details.
  }
  \item{back}{
  Specifies the fill style of the sphere geometry. See \code{\link{material3d}} for details.
  }
  \item{ ... }{Material properties. See \code{\link{material3d}} for details.}  
}
\details{
If sphere is set to \code{TRUE}, an environmental sphere enclosing the whole scene is drawn.

If not, but the material properties include a bitmap as a texture, the bitmap is drawn in the 
background of the scene.  (The bitmap colors modify the general color setting.)

If neither a sphere nor a bitmap background is drawn, the background is filled with a 
solid color.
}
\examples{
  open3d()
  
  # a simple white background
  
  bg3d("white")

  # the holo-globe (inspired by star trek):

  bg3d(sphere = TRUE, color = c("black", "green"), lit = FALSE, back = "lines" )

  # an environmental sphere with a nice texture.

  bg3d(sphere = TRUE, texture = system.file("textures/sunsleep.png", package = "rgl"), 
         back = "filled" )
         
  # The same texture as a fixed background
  
  open3d()
  bg3d(texture = system.file("textures/sunsleep.png", package = "rgl"), col = "white")
}
\seealso{
  \code{\link{material3d}}, \code{\link{bgplot3d}} to add a 2D plot as background.
}
\keyword{dynamic}
