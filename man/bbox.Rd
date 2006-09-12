\name{rgl.bbox}
\alias{rgl.bbox}
\alias{bbox3d}
\title{Set up Bounding Box decoration}
\description{
  Set up the bounding box decoration.
}
\usage{
rgl.bbox( 
  xat=NULL, xlab=NULL, xunit=0, xlen=5, 
  yat=NULL, ylab=NULL, yunit=0, ylen=5,
  zat=NULL, zlab=NULL, zunit=0, zlen=5,
  marklen=15.0, marklen.rel=TRUE, expand=1, ...)
bbox3d(xat, yat, zat, expand=1.03, nticks=5, ...)  
}
\arguments{
  \item{xat,yat,zat}{vector specifying the tickmark positions}
  \item{xlab,ylab,zlab}{character vector specifying the tickmark labeling}
  \item{xunit,yunit,zunit}{value specifying the tick mark base for uniform tick mark layout}
  \item{xlen,ylen,zlen}{value specifying the number of tickmarks}
  \item{marklen}{value specifying the length of the tickmarks}
  \item{marklen.rel}{logical, if TRUE tick mark length is calculated using 1/\code{marklen} * axis length, otherwise tick mark length is \code{marklen} in coordinate space}
  \item{expand}{value specifying how much to expand the bounding box around the data}
  \item{nticks}{suggested number of ticks to use on axes}
  \item{ ... }{Material properties (or other \code{rgl.bbox} parameters
  in the case of \code{bbox3d}). See \code{\link{rgl.material}} for details.}
}
\details{
  Three different types of tick mark layouts are possible.
  If \code{at} is not \code{NULL}, the ticks are set up at custom positions.
  If \code{unit} is not zero, it defines the tick mark base.
  If \code{length} is not zero, it specifies the number of ticks that are automatically specified.
  The first colour specifies the bounding box, while the second one specifies the tick mark and font colour.
  
  \code{bbox3d} defaults to \code{\link{pretty}} locations for the axis labels and a slightly larger
  box, whereas \code{rgl.bbox} covers the exact range.
  
  \code{\link{axes3d}} offers more flexibility in the specification of the axes, but 
  they are static, unlike those drawn by \code{\link{rgl.bbox}} and \code{\link{bbox3d}}.
}
\value{
  This function is called for the side effect of setting the bounding box decoration.
  A shape ID is returned to allow \code{\link{rgl.pop}} to delete it.
}
\examples{
  rgl.open()
  rgl.points(rnorm(100), rnorm(100), rnorm(100))
  rgl.bbox(color=c("#333377","white"), emission="#333377", 
           specular="#3333FF", shininess=5, alpha=0.8 )
  
  open3d()
  points3d(rnorm(100), rnorm(100), rnorm(100))
  bbox3d(color=c("#333377","white"), emission="#333377", 
         specular="#3333FF", shininess=5, alpha=0.8)
}
\seealso{
  \code{\link{rgl.material}}, \code{\link{axes3d}} 
}
\keyword{dynamic}
