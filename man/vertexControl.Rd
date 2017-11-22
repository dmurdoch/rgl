\name{vertexControl}
\alias{vertexControl}
\title{
Set attributes of vertices.
}
\description{
This is a function to produce actions in a web display.  A
\code{\link{playwidget}} or Shiny
input control (e.g. a \code{\link[shiny]{sliderInput}} control)
sets a value which controls attributes of a selection of vertices.
}
\usage{
vertexControl(value = 0, values = NULL, vertices = 1, attributes,
              objid, param = seq_len(NROW(values)) - 1, interp = TRUE)
}
\arguments{
  \item{value}{The value to use for input (typically \code{input$value}
  in a Shiny app.)  Not needed with \code{\link{playwidget}}.}
  \item{values}{
A matrix of values, each row corresponding to an input value.
}
  \item{vertices}{
Which vertices are being controlled?  Specify \code{vertices} as a number from 1 to
the number of vertices in the \code{objid}.
}
  \item{attributes}{A vector of attributes of a vertex,
  from \code{c("x", "y", "z", "red", "green", "blue", "alpha", "nx", "ny", "nz",
               "radius", "ox", "oy", "oz", "ts", "tt", "offset")}.  See
               Details.}
  \item{objid}{
A single \pkg{rgl} object id.
}
  \item{param}{
Parameter values corresponding to each row of \code{values}.
}
  \item{interp}{
Whether to interpolate between rows of \code{values}.
}
}
\details{
This function
modifies attributes of vertices in a single
object.  The \code{attributes} are properties of each vertex
in a scene; not all are applicable to all objects. In order,
they are: coordinates of the vertex \code{"x", "y", "z"}, color
of the vertex \code{"red", "green", "blue", "alpha"}, normal at the vertex
\code{"nx", "ny", "nz"}, radius of a sphere at the vertex
\code{"radius"}, origin within a texture \code{"ox", "oy"} and
perhaps \code{"oz"}, texture coordinates \code{"ts", "tt"}.

Planes are handled specially.  The coefficients \code{a, b, c}
in the \code{\link{planes3d}} or \code{\link{clipplanes3d}} 
specification are controlled 
using \code{"nx", "ny", "nz"}, and \code{d} is handled as
\code{"offset"}.  The \code{vertices} argument is interpreted
as the indices of the planes when these attributes are set.

If only one attribute of one vertex is specified, \code{values} may
be given as a vector and will be treated as a one-column matrix.  Otherwise
\code{values} must be given as a matrix with \code{ncol(values) == max(length(vertices),
length(attributes))}.  The \code{vertices} and \code{attributes} vectors will be recycled to the same length, and entries from column \code{j} of \code{values} will be applied to 
vertex \code{vertices[j]}, attribute \code{attributes[j]}.

The \code{value} argument is translated into a row (or two rows if
\code{interp = TRUE}) of \code{values}
by finding its location in \code{param}.
}
\value{
A list of class \code{"rglControl"} of cleaned up parameter
values, to be used in an rgl widget.
}
\author{
Duncan Murdoch
}

\examples{
  saveopts <- options(rgl.useNULL = TRUE)

  theta <- seq(0, 6*pi, len=100)
  xyz <- cbind(sin(theta), cos(theta), theta)
  plot3d(xyz, type="l")
  id <- spheres3d(xyz[1,,drop=FALSE], col="red")

  widget <- rglwidget(width=500, height=300) \%>\%
  playwidget(vertexControl(values=xyz,
                           attributes=c("x", "y", "z"),
                           objid = id, param=1:100),
             start = 1, stop = 100, rate=10)
  if (interactive())
    widget
  options(saveopts)
}
