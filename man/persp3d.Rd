\name{persp3d}
\alias{persp3d}
\alias{persp3d.default}
\title{ Surface plots }
\description{
  This function draws plots of surfaces over the
  x-y plane. \code{persp3d} is a generic function.}
\usage{
persp3d(x, \dots)

\method{persp3d}{default}(x = seq(0, 1, len = nrow(z)), y = seq(0, 1, len = ncol(z)), z,
    xlim = range(x, na.rm = TRUE), 
    ylim = range(y, na.rm = TRUE), 
    zlim = range(z, na.rm = TRUE),
    xlab = NULL, ylab = NULL, zlab = NULL, add = FALSE, aspect = !add, ...)
}
\arguments{
  \item{x, y}{locations of grid lines at which the values in \code{z} are
    measured.  These may be given as vectors or matrices.
    If vectors, they must be in ascending order.   Either one or both may be matrices.
    If \code{x} is a \code{list},
    its components \code{x$x} and \code{x$y} are used for \code{x}
    and \code{y}, respectively.}
  \item{z}{a matrix containing the values to be plotted.  
    Note that \code{x} can be used instead of \code{z} for
    convenience.}
  \item{xlim, ylim, zlim}{x-, y-  and z-limits.  The plot is produced
    so that the rectangular volume defined by these limits is visible.}
  \item{xlab, ylab, zlab}{titles for the axes.  N.B. These must be
    character strings; expressions are not accepted.  Numbers will be
    coerced to character strings.}
  \item{add}{whether to add the points to an existing plot.}    
  \item{aspect}{either a logical indicating whether to adjust the aspect ratio, or a new ratio}
    
  \item{\dots}{additional material parameters to be passed to \code{\link{surface3d}}
  and \code{\link{decorate3d}}.}
}
\details{
  This is similar to \code{\link[graphics]{persp}} with user interaction.  See \code{\link{plot3d}}
  for more general details.
  
  One difference from \code{\link[graphics]{persp}} is that colors are specified on each
  vertex, rather than on each facet of the surface.  To emulate the \code{\link[graphics]{persp}}
  color handling, you need to do the following.  First, convert the color vector to 
  an \code{(nx-1)} by \code{(ny-1)} matrix; then add an extra row before row 1, 
  and an extra column after the last column, to convert it to \code{nx} by \code{ny}.
  (These extra colors will not be used).  For example, 
  \code{col <- rbind(1, cbind(matrix(col, nx-1, ny-1), 1))}.
  Finally, call \code{persp3d} with material property \code{smooth = FALSE}.
  
  If the \code{x} or \code{y} argument is a matrix, then it must be of the same
  dimension as \code{z}, and the values in the matrix will be used for the corresponding
  coordinates. This is used to plot shapes such as spheres or cylinders
  where z is not a function of x and y.  See the fourth and fifth examples below.
}
\value{
  This function is called for the side effect of drawing the plot.  A vector 
  of shape IDs is returned.
}
\author{Duncan Murdoch}
\seealso{\code{\link{plot3d}}, \code{\link{persp}}. The \code{\link[emdbook]{curve3d}}
function in the \code{emdbook} package draws surface plots of functions.}
\examples{

# (1) The Obligatory Mathematical surface.
#     Rotated sinc function.

x <- seq(-10, 10, length= 30)
y <- x
f <- function(x,y) { r <- sqrt(x^2+y^2); 10 * sin(r)/r }
z <- outer(x, y, f)
z[is.na(z)] <- 1
open3d()
bg3d("white")
material3d(col="black")
persp3d(x, y, z, aspect=c(1, 1, 0.5), col = "lightblue",
        xlab = "X", ylab = "Y", zlab = "Sinc( r )")

# (2) Add to existing persp plot:

xE <- c(-10,10); xy <- expand.grid(xE, xE)
points3d(xy[,1], xy[,2], 6, col = "red")
lines3d(x, y=10, z= 6 + sin(x), col = "green")

phi <- seq(0, 2*pi, len = 201)
r1 <- 7.725 # radius of 2nd maximum
xr <- r1 * cos(phi)
yr <- r1 * sin(phi)
lines3d(xr,yr, f(xr,yr), col = "pink", lwd = 2)

# (3) Visualizing a simple DEM model

z <- 2 * volcano        # Exaggerate the relief
x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

open3d()
bg3d("slategray")
material3d(col="black")
persp3d(x, y, z, col = "green3", aspect="iso",
      axes = FALSE, box = FALSE)

# (4) A cylindrical plot

z <- matrix(seq(0, 1, len=50), 50, 50)
theta <- t(z)
r <- 1 + exp( -pmin( (z - theta)^2, (z - theta - 1)^2, (z - theta + 1)^2 )/0.01 )
x <- r*cos(theta*2*pi)
y <- r*sin(theta*2*pi)

open3d()
persp3d(x, y, z, col="red")

# (5) A globe

lat <- matrix(seq(90,-90, len=50)*pi/180, 50, 50, byrow=TRUE)
long <- matrix(seq(-180, 180, len=50)*pi/180, 50, 50)

r <- 6378.1 # radius of Earth in km
x <- r*cos(lat)*cos(long)
y <- r*cos(lat)*sin(long)
z <- r*sin(lat)

open3d()
persp3d(x, y, z, col="white", 
       texture=system.file("textures/worldsmall.png",package="rgl"), 
       specular="black", axes=FALSE, box=FALSE, xlab="", ylab="", zlab="",
       normal_x=x, normal_y=y, normal_z=z)
if (!rgl.useNULL())
  play3d(spin3d(axis=c(0,0,1), rpm=8), duration=5)

\dontrun{
# This looks much better, but is slow because the texture is very big
persp3d(x, y, z, col="white", 
       texture=system.file("textures/world.png",package="rgl"), 
       specular="black", axes=FALSE, box=FALSE, xlab="", ylab="", zlab="",
       normal_x=x, normal_y=y, normal_z=z)
}
}
\keyword{ dynamic }
\keyword{ graphics }
