\name{extrude3d}
\alias{extrude3d}
\title{
Generate extrusion mesh
}
\description{
Given a two-dimensional polygon, this generates a three-dimensional extrusion
of the shape by triangulating the polygon and creating a cylinder with
that shape as the end faces.
}
\usage{
extrude3d(x, y = NULL, thickness = 1, smooth = FALSE, ...)
}
\arguments{
  \item{x, y}{
A polygon description in one of the forms supported by \code{\link{triangulate}}.
}
  \item{thickness}{
The extrusion will have this thickness.
}
  \item{smooth}{
logical; should normals be added so that the edges of the extrusion appear
smooth?
}
  \item{\dots}{
Other parameters to pass to \code{\link{tmesh3d}} when constructing the
mesh.
}
}
\details{
The extrusion is always constructed with the polygon in the xy plane at
\code{z = 0} and another copy at \code{z = thickness}.  Use
the transformation functions (e.g. \code{\link{rotate3d}}) to 
obtain other orientations and placements.
}
\value{
A mesh object containing a triangulation of the polygon
for each face, and quadrilaterals for the sides.
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link{polygon3d}} for a simple polygon, \code{\link{triangulate}} for
the triangulation, \code{\link{turn3d}} for a solid of rotation.
}
\examples{
x <- c(1:10, 10:1)
y <- rev(c(rep(c(0,2), 5), rep(c(1.5,-0.5),5)))
plot(x, y, type="n")
polygon(x, y)
open3d()
shade3d( extrude3d(x, y), col = "red" )
}
\keyword{ graphics }
