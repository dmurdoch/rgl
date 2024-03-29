\name{bbox3d}
\alias{bbox3d}
\title{Set up bounding box decoration}
\description{
  Set up the bounding box decoration.
}
\usage{
bbox3d(xat = NULL, yat = NULL, zat = NULL, 
	xunit = "pretty", yunit = "pretty", zunit = "pretty", 
	expand = 1.03,
	draw_front = FALSE, 
	xlab=NULL, ylab=NULL, zlab=NULL,
  xlen=5, ylen=5, zlen=5,
  marklen=15.0, marklen.rel=TRUE, ...) 
}
\arguments{
  \item{xat, yat, zat}{vector specifying the tickmark positions}
  \item{xlab, ylab, zlab}{character vector specifying the tickmark labeling}
  \item{xunit, yunit, zunit}{value specifying the tick mark base for uniform tick mark layout}
  \item{xlen, ylen, zlen}{value specifying the number of tickmarks}
  \item{marklen}{value specifying the length of the tickmarks}
  \item{marklen.rel}{logical, if TRUE tick mark length is calculated using 1/\code{marklen} * axis length, otherwise tick mark length is \code{marklen} in coordinate space}
  \item{expand}{value specifying how much to expand the bounding box around the data}
  \item{draw_front}{draw the front faces of the bounding box}
  \item{ ... }{Material properties (or other \code{rgl.bbox} parameters
  in the case of \code{bbox3d}). See \code{\link{material3d}} for details.}
}
\details{
  Four different types of tick mark layouts are possible.
This description applies to the X axis; other axes are similar:
  If \code{xat} is not \code{NULL}, the ticks are set up at custom positions.
  If \code{xunit} is numeric but not zero, it defines the tick mark base.  If
  it is \code{"pretty"} (the default in \code{bbox3d}), ticks are set at \code{\link{pretty}}
  locations.
  If \code{xlen} is not zero, it specifies the number of ticks
  (a suggestion if \code{xunit} is \code{"pretty"}).

  The first color specifies the bounding box, while the second one specifies the tick mark and font color.
  
  \code{bbox3d} defaults to \code{\link{pretty}} locations for the axis labels and a slightly larger
  box, whereas \code{rgl.bbox} covers the exact range.
  
  \code{\link{axes3d}} offers more flexibility in the specification of the axes, but 
  they are static, unlike those drawn by \code{\link{bbox3d}}.
}
\value{
  This function is called for the side effect of setting the bounding box decoration.
  A shape ID is returned to allow \code{\link{pop3d}} to delete it.
}
\examples{
  open3d()
  points3d(rnorm(100), rnorm(100), rnorm(100))
  bbox3d(color = c("#333377", "black"), emission = "#333377", 
         specular = "#3333FF", shininess = 5, alpha = 0.8)
}
\seealso{
  \code{\link{material3d}}, \code{\link{axes3d}} 
}
\keyword{dynamic}
