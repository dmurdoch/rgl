\name{bg3d}
\alias{bg3d}
\title{Set up background}
\description{
  Set up the background of the scene.
}
\usage{
bg3d(color,
    sphere=FALSE, 
    back="lines",
    fogtype="none",
    fogScale = 1, 
    col, ...)

}
\arguments{
  \item{color, col}{
  See Details below.
  }
  \item{sphere}{
  logical:  if \code{TRUE}, an environmental sphere geometry is used for the background decoration.
  }
  \item{back}{
  Specifies the fill style of the sphere geometry. See
  \code{\link{material3d}} for details.  For \code{sphere = FALSE}
  this parameter is ignored, and the background is always
  filled.
  }
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
  \item{fogScale}{
  Scaling for fog.  See Details.
  }
  \item{ ... }{Additional material properties. See \code{\link{material3d}} for details.}  
}
\details{

The background color is taken from \code{color} or \code{col}
if \code{color} is missing.
The first entry
is used for background clearing and as the fog color.
The second (if present) is used for background sphere geometry.

If \code{color} and \code{col} are both missing, the default is found in 
the \code{\link{r3dDefaults}$bg} list, or \code{"white"} is used
if nothing is specified there.

If \code{sphere} is set to \code{TRUE}, an environmental
sphere enclosing the whole scene is drawn.

If not, but the material properties include a bitmap as a texture, the bitmap is drawn in the 
background of the scene.  (The bitmap colors modify the general color setting.)

If neither a sphere nor a bitmap background is drawn, the background is filled with a 
solid color.

The \code{fogScale} parameter should be a positive value
to change the density of the fog in the plot.  For 
\code{fogtype = "linear"} it multiplies the density of the
fog; for the exponential fog types it multiplies the density
parameter used in the display.  

The following rules are used to compute the fog display.
These are designed for compatibility with
older versions of \pkg{rgl} which used the OpenGL fixed
pipeline.
\itemize{
\item{For \code{"linear"} fog, the near clipping plane is
taken as \eqn{c=0}, and the 
far clipping plane is taken as \eqn{c=1}.  The
amount of fog is \eqn{s * c} clamped to a 0 to 1
range, where \eqn{s = fogScale}.}
\item{For \code{"exp"} and \code{"exp2"} fog, the observer location
is negative at a distance depending on the field of view.
The formula for the distance is 
\deqn{c = [1-sin(theta)]/[1 + sin(theta)]}
where \eqn{theta = FOV/2}.
We calculate \deqn{c' = d(1-c) + c}
so \eqn{c'} runs from 0 at the observer to
1 at the far clipping plane.}
\item{For \code{"exp"} fog, the amount of fog is 
\eqn{1 - exp(-s * c')}.}
\item{For \code{"exp2"} fog, the amount of fog is
\eqn{1 - exp[-(s * c')^2]}.}
}
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
