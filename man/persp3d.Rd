\name{persp3d}
\alias{persp3d}
\alias{persp3d.default}
\title{ Surface plots }
\description{
  This function draws plots of surfaces in 3-space. \code{persp3d} is a generic function.}
\usage{
persp3d(x, \dots)

\method{persp3d}{default}(x = seq(0, 1, len = nrow(z)), y = seq(0, 1, len = ncol(z)), z,
    xlim = NULL, ylim = NULL, zlim = NULL,
    xlab = NULL, ylab = NULL, zlab = NULL, add = FALSE, aspect = !add, 
    forceClipregion = FALSE, ...)
}
\arguments{
  \item{x, y, z}{points to plot on surface.  See Details below.}
  \item{xlim, ylim, zlim}{x-, y-  and z-limits.  If present,
  the plot is clipped to this region.}
  \item{xlab, ylab, zlab}{titles for the axes.  N.B. These must be
    character strings; expressions are not accepted.  Numbers will be
    coerced to character strings.}
  \item{add}{whether to add the points to an existing plot.}    
  \item{aspect}{either a logical indicating whether to adjust the aspect ratio, or a new ratio.}
  \item{forceClipregion}{force a clipping region to be used,
whether or not limits are given.}
  \item{\dots}{additional material parameters to be passed to \code{\link{surface3d}}
  and \code{\link{decorate3d}}.}
}
\details{
The default method plots a surface defined as a grid of \code{(x,y,z)} locations in space.  The grid may be specified in several ways:
\itemize{
\item{As with \code{\link[graphics]{persp}}, \code{x} and \code{y} may be given as vectors in ascending order, with \code{z} given as a matrix. There
should be one \code{x} value for each row of \code{z} and
one \code{y} value for each column.  The surface drawn will
have \code{x} constant across rows and \code{y} constant
across columns.  This is the most convenient format when
\code{z} is a function of \code{x} and \code{y} which are
measured on a regular grid.}

\item{\code{x} and \code{y} may also be given as matrices, in which
case they should have the same dimensions as \code{z}.  The
surface will combine corresponding points in each matrix
into locations \code{(x,y,z)} and draw the surface through those.  This
allows general surfaces to be drawn, as in the example of a spherical Earth shown below.}

\item{If \code{x} is a \code{list}, its components \code{x$x}, \code{x$y} and \code{x$z} are used for \code{x}, \code{y} and
\code{z} respectively, though an explicitly specified
\code{z} value will have priority.}}
  
  One difference from \code{\link[graphics]{persp}} is that colors are specified on each
  vertex, rather than on each facet of the surface.  To emulate the \code{\link[graphics]{persp}}
  color handling, you need to do the following.  First, convert the color vector to 
  an \code{(nx - 1)} by \code{(ny - 1)} matrix; then add an extra row before row 1, 
  and an extra column after the last column, to convert it to \code{nx} by \code{ny}.
  (These extra colors will not be used).  For example, 
  \code{col <- rbind(1, cbind(matrix(col, nx - 1, ny - 1), 1))}.
  Finally, call \code{persp3d} with material property \code{smooth = FALSE}.
  
  See the \dQuote{Clipping} section in \code{\link{plot3d}}
for more details on \code{xlim, ylim, zlim} and \code{forceClipregion}.
}
\value{
  This function is called for the side effect of drawing the plot.  A vector 
  of shape IDs is returned invisibly.
}
\author{Duncan Murdoch}
\seealso{\code{\link{plot3d}}, \code{\link{persp}}. There is
a \code{\link{persp3d.function}} method for drawing functions, and \code{\link{persp3d.deldir}} can be used
to draw surfaces defined by an irregular collection of points.  A formula method \code{\link{persp3d.formula}} draws 
surfaces using this method.

The \code{\link{surface3d}} function is used to draw the surface without the axes etc. }
\examples{

# (1) The Obligatory Mathematical surface.
#     Rotated sinc function.

x <- seq(-10, 10, length = 30)
y <- x
f <- function(x, y) { r <- sqrt(x^2 + y^2); 10 * sin(r)/r }
z <- outer(x, y, f)
z[is.na(z)] <- 1
open3d()

# Draw the surface twice:  the first draws the solid part, 
# the second draws the grid.  Offset the first so it doesn't
# obscure the lines.

persp3d(x, y, z, aspect = c(1, 1, 0.5), col = "lightblue",
        xlab = "X", ylab = "Y", zlab = "Sinc( r )", 
        polygon_offset = 1)
persp3d(x, y, z, front = "lines", back = "lines", 
        lit = FALSE, add = TRUE)
highlevel()   # trigger the plot

# (2) Add to existing persp plot:

xE <- c(-10, 10); xy <- expand.grid(xE, xE)
points3d(xy[, 1], xy[, 2], 6, col = "red")
lines3d(x, y = 10, z = 6 + sin(x), col = "green")

phi <- seq(0, 2*pi, len = 201)
r1 <- 7.725 # radius of 2nd maximum
xr <- r1 * cos(phi)
yr <- r1 * sin(phi)
lines3d(xr, yr, f(xr, yr), col = "pink", lwd = 2)

# (3) Visualizing a simple DEM model

z <- 2 * volcano        # Exaggerate the relief
x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

open3d()
invisible(bg3d("slategray")) # suppress display
material3d(col = "black")
persp3d(x, y, z, col = "green3", aspect = "iso",
      axes = FALSE, box = FALSE)

# (4) A globe

lat <- matrix(seq(90, -90, len = 50)*pi/180, 50, 50, byrow = TRUE)
long <- matrix(seq(-180, 180, len = 50)*pi/180, 50, 50)

r <- 6378.1 # radius of Earth in km
x <- r*cos(lat)*cos(long)
y <- r*cos(lat)*sin(long)
z <- r*sin(lat)

open3d()
persp3d(x, y, z, col = "white", 
       texture = system.file("textures/worldsmall.png", package = "rgl"), 
       specular = "black", axes = FALSE, box = FALSE, xlab = "", ylab = "", zlab = "",
       normal_x = x, normal_y = y, normal_z = z)
if (!rgl.useNULL())
  play3d(spin3d(axis = c(0, 0, 1), rpm = 16), duration = 2.5)

\dontrun{
# This looks much better, but is slow because the texture is very big
persp3d(x, y, z, col = "white", 
       texture = system.file("textures/world.png", package = "rgl"), 
       specular = "black", axes = FALSE, box = FALSE, xlab = "", ylab = "", zlab = "",
       normal_x = x, normal_y = y, normal_z = z)
}


}
\keyword{ dynamic }
\keyword{ graphics }
