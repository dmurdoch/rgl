\name{shapelist3d}
\alias{shapelist3d}
\title{ Create and plot a list of shapes }
\description{
 These functions create and plot a list of shapes.
}
\usage{
shapelist3d(shapes, x = 0, y = NULL, z = NULL, size = 1, matrix = NULL, override = TRUE, 
            ..., plot = TRUE)  
}
\arguments{
  \item{shapes}{ A single \code{shape3d} object, or a list of them. }
  \item{x, y, z}{ Translation(s) to apply }
  \item{size}{ Scaling(s) to apply }
  \item{matrix}{ A single matrix transformation, or a list of them. }
  \item{override}{ Whether the material properties should override the ones in the shapes. }
  \item{\dots}{ Material properties to apply. }
  \item{plot}{ Whether to plot the result. }
}
\details{
 \code{shapelist3d} is a quick way to create a complex object made up of simpler ones.
Each of the arguments \code{shapes} through \code{override} may be a vector of 
values (a list in the case of \code{shapes} or \code{matrix}).  All values
will be recycled to produce a list of shapes as long as the longest of them.

The \code{\link{xyz.coords}} function will be used to process the \code{x},
\code{y} and \code{z} arguments, so a matrix may be used as \code{x} to 
specify all three.   If a vector is used for \code{x} but \code{y} or \code{z}
is missing, default values of \code{0} will be used.

The \code{"shapelist3d"} class is simply a list of \code{"shape3d"} objects.

Methods for \code{\link{dot3d}}, \code{\link{wire3d}}, \code{\link{shade3d}},
\code{\link{translate3d}}, \code{\link{scale3d}}, and \code{\link{rotate3d}}
are defined for these objects.

}
\value{
An object of class \code{c("shapelist3d", "shape3d")}.
}
\author{ Duncan Murdoch }
\seealso{ \code{\link{mesh3d}} }
\examples{

open3d() 
shapelist3d(icosahedron3d(), x = rnorm(10), y = rnorm(10), z = rnorm(10), col = 1:5, size = 0.3)

}
\keyword{ dynamic }
