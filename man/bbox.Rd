\name{rgl.bbox}
\alias{rgl.bbox}
\title{setup Bounding Box decoration}
\description{
  Setup the bounding box decoration.
}
\usage{
rgl.bbox( 
  xat=NULL, xlab=NULL, xunit=0, xlen=5, 
  yat=NULL, ylab=NULL, yunit=0, ylen=5,
  zat=NULL, zlab=NULL, zunit=0, zlen=5,
  marklen=15.0, marklen.rel=TRUE, ...)
}
\arguments{
  \item{xat,yat,zat}{vector specifying the tickmark positions}
  \item{xlab,ylab,zlab}{character vector specifying the tickmark labeling}
  \item{xunit,yunit,zunit}{value specifying tick mark base for uniform tick mark layout}
  \item{xlen,ylen,zlen}{value specifying the number of tickmarks}
  \item{marklen}{value specifying the length of the tickmarks}
  \item{marklen.rel}{logical, if TRUE tick mark length is calculated using 1/\code{marklen} * axis length, otherwise tick mark length is \code{marklen} in coordinate space}
  \item{ ... }{Material properties. See \code{\link{rgl.material}} for details.}
}
\details{
  Three different types of tick mark layout are possible.
  If at is not NULL, the ticks are setup at custom positions.
  If unit is not zero, it defines the tick mark base.
  If length is not zero, it specifies the number of ticks that are automatically specified.
  Primary color specifies the bounding box, while secondary color specifies the tick mark and font color.
}
\examples{
  rgl.bbox(color="#333377", emission="#333377",specular="#3333FF", shininess=5, alpha=0.8 )
}
\seealso{
  \code{\link{rgl.material}}
}
\keyword{dynamic}
