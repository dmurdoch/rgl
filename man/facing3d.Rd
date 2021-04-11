\name{facing3d}
\alias{facing3d}
\alias{projectDown}
\title{
Subset an object to parts facing in a particular direction
}
\description{
\code{facing3d} subsets an object by converting it to a triangle mesh,
then subsetting to those triangles that are counterclockwise
(for \code{front = TRUE}) when projected into a plane.

\code{projectDown} computes a projection that \dQuote{looks down} the specified direction.
}
\usage{
facing3d(obj, up = c(0, 0, 1), 
         P = projectDown(up), 
         front = TRUE, strict = TRUE)
projectDown(up)
}
\arguments{
  \item{obj}{
An object that can be converted to a triangular mesh object.
}
  \item{up}{
The direction that is to be considered \dQuote{up}.  It may
be either a 3 vector in Euclidean coordinates or a 4 vector in
homogeneous coordinates.
  }
  \item{P}{
The projection to use for draping, a 4x4 matrix.  See \code{\link{drape3d}} for details on how \code{P} is used.
}
  \item{front}{
If \code{front = TRUE}, retains triangles that are counterclockwise after projection by \code{P}, otherwise
retains those that are clockwise.
}
  \item{strict}{If \code{TRUE}, drops indeterminate triangles
(those that are annihilated by \code{P}).}
}
\details{
By default 
the returned subset will be those triangles whose upper side
matches \code{front}.  Change \code{up} or use an
arbitrary projection for different subsets.

\code{\link{drape3d}} and \code{\link{shadow3d}} project objects onto meshes; these functions can be used to
project only onto the top or front.
}
\value{
\code{facing3d} returns a mesh object made of those triangles which face in the 
desired direction.

\code{projectDown} computes a 4x4 matrix.   The first two
coordinates of \code{asEuclidean(x \%*\% projectDown(up))} 
give a projection of \code{x} from above into a plane, where 
\code{up} determines which direction is taken to be \dQuote{up}.
}
\seealso{\code{\link{drape3d}}, \code{\link{shadow3d}}}
\examples{
open3d()
d <- rnorm(3)
d <- d/sqrt(sum(d^2))
shade3d( facing3d( icosahedron3d(), up = d, strict = FALSE), 
         col = "yellow")
wire3d( facing3d( icosahedron3d(), up = d, front = FALSE), 
         col = "black")
# Show the direction:
arrow3d(-2*d , -d)
}
