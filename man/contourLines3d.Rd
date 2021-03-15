\name{contourLines3d}
\alias{contourLines3d}
\alias{contourLines3d.rglId}
\alias{contourLines3d.mesh3d}
\alias{filledContour3d}
\alias{filledContour3d.rglId}
\alias{filledContour3d.mesh3d}
\title{
Draw contours on a surface
}
\description{
\code{contourLines3d} draws contour lines on a surface;
\code{filledContour3d} draws filled contours on it.
}
\usage{
contourLines3d(obj, ...)
\method{contourLines3d}{rglId}(obj, ...)
\method{contourLines3d}{mesh3d}(obj, fn = "z", 
    nlevels = 10, 
    levels = NULL, 
    minVertices = 0,
    plot = TRUE, ... )
filledContour3d(obj, ...)
\method{filledContour3d}{rglId}(obj, plot = TRUE, replace = plot, ...)
\method{filledContour3d}{mesh3d}(obj, fn = "z", 
    nlevels = 20, 
    levels = pretty(range(values), nlevels), 
    color.palette = function(n) hcl.colors(n, "YlOrRd", rev = TRUE),
    col = color.palette(length(levels) - 1),
    minVertices = 0,
    plot = TRUE, 
    keepValues = FALSE, ... )    
}
\arguments{
  \item{obj}{
The object(s) on which to draw contour lines.
}
  \item{fn}{
The function(s) to be contoured.  See Details.
  }
  \item{nlevels}{
Suggested number of contour levels if \code{levels} is not given.
  }
  \item{levels}{
Specified contour values.
  }
  \item{minVertices}{
See Details below.  
  }
  \item{plot}{
Whether to draw the lines or return them in a dataframe.
  }
  \item{\dots}{
For the \code{"mesh3d"} methods, additional parameters to pass to \code{\link{segments3d}}
when drawing the contour lines or to \code{\link{shade3d}}
when drawing the filled contours.  For the \code{"rglId"}
methods, additional parameters to pass to the \code{"mesh3d"}
methods.
}
  \item{replace}{
Whether to delete the objects that are being contoured.
  }
  \item{color.palette}{a color palette function to 
  assign colors in the plot}
  \item{col}{the actual colors to use in the plot.}
  \item{keepValues}{whether to save the function values at 
  each vertex when \code{plot = FALSE}}
}
\details{
For \code{contourLines3d}, the \code{fn} argument can be any
of the following:
\itemize{
\item{ a character vector naming
one or more functions} 
\item{a function}
\item{a numeric vector with one value per vertex}
\item{\code{NULL}, indicating that the numeric values
are saved in \code{obj$values}}
\item{a list containing any of the above.}
}
For \code{filledContour3d}, only one function can be specified.

The special names \code{"x", "y", "z"} may be used in
\code{fn} to specify functions returning one of those
coordinates.  (If you have existing functions \code{x()}, \code{y()}
or \code{z()} they will be masked by this choice; specify
such functions by value rather than name, e.g. \code{fn = x}
instead of \code{fn = "x"}.)

Functions in \code{fn} with formal arguments \code{x},
\code{y} and \code{z} will receive the coordinates of 
vertices in those arguments, otherwise they will receive 
the coordinates in a single n x 3 matrix.   They should
be vectorized and return one value per vertex.

Each of the functions will be evaluated at each vertex
of the surface specified by \code{obj}, and contours will
be drawn assuming the function is linear between vertices.
If contours of a nonlinear function are needed, you may
want to increase \code{minVertices} as described below.

If \code{levels} is not specified, values will be set
separately for each entry in \code{fn}, using 
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

In R versions prior to 3.6.0, the default \code{color.palette}
is \code{grDevices::cm.colors}.
}
\value{
For both \code{contourLines3d} and \code{filledContour3d}
the \code{"rglId"} method converts the given id values to
a mesh, and calls the \code{"mesh3d"} method.  

The \code{"mesh3d"} method returns an object of class
\code{"rglId"} corresponding to what was
drawn if \code{plot} is \code{TRUE},

If \code{plot} is \code{FALSE}, \code{contourLines3d} returns a dataframe containing 
columns \code{c("x", "y", "z", "fn", "level")} giving
the coordinates of the endpoints of each line segment, 
the name (or index) of the function for this contour, and the 
level of the contour.  

If \code{plot} is \code{FALSE}, \code{filledContour3d}
returns a \code{"\link{mesh3d}"} object holding the result.
If \code{keepValues} is \code{TRUE}, the mesh
will contain the values corresponding to each vertex
(with linear approximations at the boundaries).
}

\author{
Duncan Murdoch
}
\seealso{
The \pkg{misc3d} package contains the function \code{\link[misc3d]{contour3d}}
to draw contour surfaces in space instead of contour lines
on surfaces.
}
\examples{

# Add contourlines in "z" to a persp plot

z <- 2 * volcano        # Exaggerate the relief
x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)

open3d()
id <- persp3d(x, y, z, aspect = "iso",
      axes = FALSE, box = FALSE, polygon_offset = 1)
contourLines3d(id)     # "z" is the default function
filledContour3d(id, polygon_offset = 1, nlevels = 10, replace = TRUE)

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
