\name{arrow3d}
\alias{arrow3d}
\title{
Draw an arrow in a scene.
}
\description{
Draws various types of arrows in a scene.
}
\usage{
arrow3d(p0 = c(1, 1, 1), p1 = c(0, 0, 0), 
        barblen, s = 1/3, theta = pi/12, 
        type = c("extrusion", "lines", "flat", "rotation"), 
        n = 3, width = 1/3, thickness = 0.618 * width, 
        spriteOrigin = NULL, 
        plot = TRUE, ...)
}
\arguments{
  \item{p0}{
The base of the arrow.
}
  \item{p1}{
The head of the arrow.
}
  \item{barblen}{
The length of the barbs (in display coordinates).
Default given by \code{s}.
}
  \item{s}{
The length of the barbs as a fraction of line length.  Ignored if \code{barblen} is present.
}
  \item{theta}{
Opening angle of barbs
}
  \item{type}{
Type of arrow to draw.  Choose one from the list
of defaults.  Can be abbreviated.  See below.
}
  \item{n}{
Number of barbs.
}
  \item{width}{
Width of shaft as fraction of barb width.
}
  \item{thickness}{
Thickness of shaft as fraction of barb width.
}
  \item{spriteOrigin}{
If arrow is to be replicated as sprites, the origins relative
to which the sprites are drawn.
}
  \item{plot}{
If \code{TRUE} (the default), plot the object;
otherwise return the computed data that
would be used to plot it.
}
  \item{\dots}{
Material properties passed to \code{\link{polygon3d}}, \code{\link{shade3d}} or \code{\link{segments3d}}.
}
}
\details{
Four types of arrows can be drawn.  The shapes
of all of them are affected by \code{p0}, \code{p1}, \code{barblen},
\code{s}, \code{theta}, material properties
in \code{...}, and \code{spriteOrigin}.  Other parameters 
only affect some of the types, as shown.
\describe{
\item{\code{"extrusion"}}{(default) A 3-dimensional
flat arrow, drawn with \code{\link{shade3d}}.  Affected by \code{width}, \code{thickness} and
\code{smooth}.}
\item{\code{"lines"}}{Drawn with lines, similar to \code{\link{arrows}}, drawn with \code{\link{segments3d}}.  Affected by \code{n}.}
\item{\code{"flat"}}{A flat arrow, drawn with \code{\link{polygon3d}}.  Affected by \code{width} and \code{smooth}.}
\item{\code{"rotation"}}{A solid of rotation, 
drawn with \code{\link{shade3d}}.  Affected by 
\code{n} and \code{width}.}
}

Normally this function draws just one arrow from
\code{p0} to \code{p1}, but
if \code{spriteOrigin} is given (in any form
that \code{\link{xyz.coords}(spriteOrigin)} can
handle), arrows will be drawn for each point
specified, with \code{p0} and \code{p1} 
interpreted relative to those origins.  The
arrows will be drawn as 3D sprites which will
maintain their orientation as the scene is rotated, so this is a good way to indicate
particular locations of interest in the scene.
}
\value{
If \code{plot = TRUE} (the default), this is
called mainly for the side effect of drawing
the arrow; invisibly returns the id(s) of 
the objects drawn.

If \code{plot = FALSE}, the data that would be
used in the plot (not including material
properties) is returned.
}
\author{
Design based on \code{heplots::\link[heplots]{arrow3d}}, which contains modifications by Michael Friendly
to a function posted by Barry Rowlingson to R-help on 1/10/2010.  Additions by Duncan Murdoch.
}
\examples{
% For some reason, this fails on R-forge:
\donttest{
xyz <- matrix(rnorm(300), ncol = 3)
plot3d(xyz)
arrow3d(xyz[1,], xyz[2,], type = "extrusion", col = "red")
arrow3d(xyz[3,], xyz[4,], type = "flat",      col = "blue")
arrow3d(xyz[5,], xyz[6,], type = "rotation",  col = "green")
arrow3d(xyz[7,], xyz[8,], type = "lines",     col = "black")
arrow3d(spriteOrigin = xyz[9:12,],            col = "purple")
}
}