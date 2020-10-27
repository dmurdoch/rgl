\name{contourLines3d}
\alias{contourLines3d}
\alias{contourLines3d.rglId}
\alias{contourLines3d.mesh3d}
\title{
Draw contour lines on a surface.
}
\description{
Draws contour lines on a surface.
}
\usage{
contourLines3d(obj, ...)
\method{contourLines3d}{rglId}(obj, ...)
\method{contourLines3d}{mesh3d}(obj, funs = "z", 
    nlevels = 10, 
    levels = NULL, 
    funArgs = NULL,
    minVertices = 0,
    draw = TRUE, ... )
}
\arguments{
  \item{obj}{
The object(s) on which to draw contour lines.
}
  \item{funs}{
The function(s) to be contoured.  See Details.
  }
  \item{nlevels}{
Suggested number of contour levels if \code{levels} is not given.
  }
  \item{levels}{
Specified contour values.
  }
  \item{funArgs}{
A list of additional arguments to pass to the functions.
  }
  \item{minVertices}{
See Details below.  
  }
  \item{draw}{
Whether to draw the lines or return them in a dataframe.
  }
  \item{\dots}{
Additional parameters to pass to \code{\link{segments3d}}
when drawing the contour lines.
}
}
\details{
The \code{funs} argument can be a character variable naming
functions or a list of functions (or a list containing a
mixture of names and functions). 

The functions should have
header \code{function(x, y, z, ...)}, where the \code{...}
part will be filled in with the entries from \code{funArgs}.

The special names \code{"x", "y", "z"} may be used in
\code{funs} to specify functions returning one of those
coordinates.  (If you have existing functions \code{x()}, \code{y()}
or \code{z()} they will be masked by this choice; specify
such functions by value rather than name, e.g. \code{funs = x}
instead of \code{funs = "x"}.)

These functions should be vectorized, returning a vector of values of the
same length as \code{x}, \code{y}, and \code{z} (which
will always be the same length on entry.)

Each of the functions will be evaluated at each vertex
of the surface specified by \code{obj}, and contours will
be drawn assuming the function is linear between vertices.
If contours of a nonlinear function are needed, you may
want to increase \code{minVertices} as described below.

If \code{levels} is not specified, values will be set
separately for each entry in \code{funs}, using 
\code{pretty(range(values, na.rm = TRUE), nlevels)} where
\code{values} are the values on the vertices.

The \code{minVertices} argument is used to improve the 
approximation to the contour when the function is non-linear.
In that case, the interpolation between vertices 
can be inaccurate.  If \code{minVertices} is set to a
positive
number (e.g. \code{10000}), then the mesh is modified
by subdivision to have at least that number of vertices, 
so that pieces are smaller and the linear interpolation
is more accurate. 
}
\note{
To draw contours on a surface, the surface should be drawn
with material property \code{polygon_offset = 1} (or perhaps
some larger positive value) so that the lines of the contour are not
obscured by the surface.
}
\value{
The \code{"rglId"} method converts the given id values to
a mesh, and calls the \code{"mesh3d"} method.  

The \code{"mesh3d"} method returns an object of class
\code{"rglId"} corresponding to the line segments that were
drawn if \code{draw} is \code{TRUE},

If \code{draw} is \code{FALSE}, it returns a dataframe containing 
columns \code{c("x", "y", "z", "fun", "level")} giving
the coordinates of the endpoints of each line segment, 
the name (or index) of the function for this contour, and the 
level of the contour.
}

\author{
Duncan Murdoch
}
\seealso{
The \pkg{misc3d} package contains the function \code{\link[misc3d]{contour3d}}
to draw contour surfaces instead of contour lines.
}
\examples{

# Add contourlines in "z" to a persp plot

z <- 2 * volcano        # Exaggerate the relief
x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

open3d()
id <- persp3d(x, y, z, col = "green3", aspect = "iso",
      axes = FALSE, box = FALSE, polygon_offset = 1)
contourLines3d(id)

# Draw longitude and latitude lines on a globe

lat <- matrix(seq(90, -90, len = 50)*pi/180, 50, 50, byrow = TRUE)
long <- matrix(seq(-180, 180, len = 50)*pi/180, 50, 50)

r <- 6378.1 # radius of Earth in km
x <- r*cos(lat)*cos(long)
y <- r*cos(lat)*sin(long)
z <- r*sin(lat)

open3d()
ids <- persp3d(x, y, z, col = "white", 
        texture = system.file("textures/worldsmall.png", package = "rgl"), 
        specular = "black", axes = FALSE, box = FALSE, xlab = "", ylab = "", zlab = "",
        normal_x = x, normal_y = y, normal_z = z, polygon_offset = 1)
        
contourLines3d(ids, list(latitude = function(x, y, z) asin(z/sqrt(x^2+y^2+z^2))*180/pi,
                         longitude = function(x, y, z) atan2(y, x)*180/pi))
}
