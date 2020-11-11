\name{show2d}
\alias{show2d}
\title{
Draw a 2D plot on a rectangle in a 3D scene.
}
\description{
This function uses a bitmap of a standard 2D graphics plot
as a texture on a quadrilateral.  Default arguments are
set up so that it will appear on the face of the bounding
box of the current 3D plot, but optional arguments allow
it to be placed anywhere in the scene.
}
\usage{
show2d(expression, 
  face = "z-", line = 0, 
  reverse = FALSE, rotate = 0, 
  x = NULL, y = NULL, z = NULL, 
  width = 480, height = 480, 
  filename = NULL, 
  ignoreExtent = TRUE, 
  color = "white", specular = "black", lit = FALSE, 
  texmipmap = TRUE, texminfilter = "linear.mipmap.linear",
  expand = 1.03,
  texcoords = matrix(c(0, 1, 1, 0, 0, 0, 1, 1), ncol = 2),  ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{expression}{
Any plotting commands to produce a plot in standard graphics.
Ignored if \code{filename} is not \code{NULL}.
}
  \item{face}{
A character string defining which face of the bounding
box to use.  See Details below.
}
  \item{line}{
How far out from the bounding box should the quadrilateral
be placed?  Uses same convention as \code{\link{mtext3d}}:
not lines of text, but fraction of the bounding box size.
}
  \item{reverse, rotate}{ 
Should the image be reversed or rotated?  See Details below.
}
  \item{x, y, z}{
Specific values to use to override \code{face}.
}
  \item{width,height}{
Parameters to pass to \code{\link{png}} when creating the
bitmap.  See Details below.
}
  \item{filename}{
A \file{.png} file image to use as the texture.
}
  \item{ignoreExtent}{
Whether the quadrilateral should be ignored when computing
the bounding box of the scene.
}
  \item{color, specular, lit, texmipmap, texminfilter, \dots}{
Material properties to use for the quadrilateral.
}
  \item{expand}{Amount by which the quadrilateral is 
expanded outside the bounding box of the data.
}
  \item{texcoords}{Coordinates on the image.  Lower left
of the bitmap is \code{c(0,0)}, upper right is \code{c(1,1)}.}
}  
\details{
The default arguments are chosen to make it easy to place
a 2D image on the face of the bounding box.  If \code{x}, 
\code{y} and \code{z} are \code{NULL} (the defaults),
\code{face} will be used as a code for one of the
six faces of the bounding box.  The first letter should
be \code{"x"}, \code{"y"} or \code{"z"}; this defines 
the axis perpendicular to the desired face.  If the
second letter is \code{"-"} or is missing, the face
will be chosen to be the face with the lower value 
on that axis.  Any other letter will use the opposite 
face.

If any of  \code{x}, \code{y} or \code{z} is given, the
specified value will be used to replace the value calculated 
above.  Usually four values should be given, corresponding to
the coordinates of the lower left, lower right, upper right
and upper left of the destination for the image before
\code{reverse} and \code{rotate} are used.  Fewer values
can be used for one or two coordinates; \code{\link{cbind}}
will be used to put together all 3 coordinates into
a 4 by 3 matrix (which will be returned as an attribute
of the result).

The bitmap plot will by default be oriented so that it is
properly oriented when viewed from the
direction of the higher values of the perpendicular coordinate,
and its lower left corner is at the lower value of the two
remaining coordinates.  The argument \code{reverse} causes
the orientation to be mirrored, and \code{rotate} causes it
to be rotated by multiples of 90 degrees.  \code{rotate} should be an integer,
with \code{0} for no rotation, \code{1} for a 90 degree
counter-clockwise rotation, etc.

The \code{width} and \code{height} arguments control the shape
and resolution of the bitmap.  The defaults give a square
bitmap, which is appropriate with the usual \code{c(1,1,1)}
aspect ratios (see \code{aspect3d}).  Some tuning may be 
needed to choose the resolution.  The plot will look best when
displayed at its original size; shrinking it smaller tends to make
it look faded, while expanding it bigger will make it look 
blurry.  If \code{filename} is given, the width and height
will be taken from the file, and \code{width} and \code{height}
arguments will be ignored.
}
\value{
Invisibly returns the id value of the quadrilateral,
with the following attributes:
\item{value}{The value returned by \code{expression}.}
\item{xyz}{A 4 by 3 matrix giving the coordinates of the corners
as used in plotting.}
\item{texcoords}{A 4 by 2 matrix giving the texture coordinates
of the image.}
\item{filename}{The filename for the temporary file holding
the bitmap image.}
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{bgplot3d}} uses a plot as the background for the window.
}
\examples{
example(plot3d, ask = FALSE)
show2d({
  par(mar=c(0,0,0,0))
  plot(x, y, col = rainbow(1000), axes=FALSE)
  })
}