\name{persp3d}
\alias{persp3d}
\title{ Surface plots }
\description{
  This function draws plots of surfaces over the
  x-y plane. \code{persp3d} is a generic function.}
\usage{
persp3d(x, \dots)

\method{persp3d}{default}(x = seq(0, 1, len = nrow(z)), y = seq(0, 1, len = ncol(z)),
    z, xlim = range(x), ylim = range(y), zlim = range(z, na.rm = TRUE),
    xlab = NULL, ylab = NULL, zlab = NULL, main = NULL, sub = NULL, box = TRUE, axes = TRUE,
    add = FALSE, top = TRUE, aspect = !add, ...)
}
\arguments{
  \item{x, y}{locations of grid lines at which the values in \code{z} are
    measured.  These must be in ascending order.  By default, equally
    spaced values from 0 to 1 are used.  If \code{x} is a \code{list},
    its components \code{x$x} and \code{x$y} are used for \code{x}
    and \code{y}, respectively.}
  \item{z}{a matrix containing the values to be plotted (\code{NA}s are
    not allowed).  Note that \code{x} can be used instead of \code{z} for
    convenience.}
  \item{xlim, ylim, zlim}{x-, y-  and z-limits.  The plot is produced
    so that the rectangular volume defined by these limits is visible.}
  \item{xlab, ylab, zlab}{titles for the axes.  N.B. These must be
    character strings; expressions are not accepted.  Numbers will be
    coerced to character strings.}
  \item{main, sub}{main and sub title, as for \code{\link{title}}.}
  \item{box}{should the bounding box for the surface be displayed.
    The default is \code{TRUE}.}
  \item{axes}{should ticks and labels be added to the box.  The
    default is \code{TRUE}.  If \code{box} is \code{FALSE} then no
    ticks or labels are drawn.}
  \item{add}{whether to add the points to an existing plot.}    
  \item{top}{whether to bring the window to the top when done.}
  \item{aspect}{either a logical indicating whether to adjust the aspect ratio, or a new ratio}
    
  \item{\dots}{additional material parameters to be passed to \code{\link{surface3d}}.}
}
\details{
  This is similar to \code{\link{persp}} with user interaction.  See \code{\link{plot3d}}
  for more details.
}
\value{
  This function is called for the side effect of drawing the plot; no useful value is returned.
}
\author{Duncan Murdoch}
\seealso{\code{\link{plot3d}}, \code{\link{persp}}}
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
points3d(xy[,1], xy[,2], 6, col = 2, size = 3)
lines3d(x, y=10, z= 6 + sin(x), col = 3)

phi <- seq(0, 2*pi, len = 201)
r1 <- 7.725 # radius of 2nd maximum
xr <- r1 * cos(phi)
yr <- r1 * sin(phi)
lines3d(xr,yr, f(xr,yr), col = "pink", size = 2)

# (3) Visualizing a simple DEM model

z <- 2 * volcano        # Exaggerate the relief
x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

open3d()
bg3d("slategray")
material3d(col="black")
persp3d(x, y, z, col = "green3", aspect="iso",
      axes = FALSE, box = FALSE)
}
\keyword{ dynamic }
