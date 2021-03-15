\name{ageControl}
\alias{ageControl}
\title{
Set attributes of vertices based on their age
}
\description{
This is a function to produce actions in response to
a \code{\link{playwidget}} or Shiny input control.  The
mental model is that each of the vertices of some object has
a certain birth time; a control sets the current time, so that
vertices have ages depending on the control setting.
Attributes of those vertices can then be changed.
}
\usage{
ageControl(births, ages, objids, value = 0,
           colors = NULL, alpha = NULL, radii = NULL, vertices = NULL,
           normals = NULL, origins = NULL, texcoords = NULL,
           x = NULL, y = NULL, z = NULL,
           red = NULL, green = NULL, blue = NULL)
}
\arguments{
  \item{births}{Numeric birth times of vertices.}
  \item{ages}{Chosen ages at which the following attributes
  will apply.}
  \item{objids}{Object ids to which the changes apply.}
  \item{value}{Initial value; typically overridden by input.}
  \item{colors, alpha, radii, vertices, normals, origins, texcoords}{
  Attributes of the vertices that can be changed.  There should be
  one entry or row for each entry in \code{ages}.}
  \item{x, y, z, red, green, blue}{These one-dimensional
  components of vertices and colors are provided for convenience.}
}
\details{
All attributes must have the same number of entries (rows for the matrices)
as the ages vector. The births vector must have the same number of entries as
the number of vertices in the object.

Not all objects contain all attributes; if one is chosen that is
not a property of the corresponding object, a Javascript \code{alert()} will be
generated.  (This restriction may be removed in the future by attempting
to add the attribute when it makes sense.)

If a \code{births} entry is \code{NA}, no change will be made to that
vertex.
}
\value{
A list of class \code{"rglControl"} of cleaned up parameter
values, to be used in an RGL widget.
}
\author{
Duncan Murdoch
}

\examples{
  saveopts <- options(rgl.useNULL = TRUE)

  theta <- seq(0, 4*pi, len=100)
  xyz <- cbind(sin(theta), cos(theta), sin(theta/2))
  lineid <- plot3d(xyz, type="l", alpha = 0, lwd = 5, col = "blue")["data"]

  widget <- rglwidget() \%>\%
  playwidget(ageControl(births = theta,
                        ages = c(-4*pi, -4*pi, 1-4*pi, 0, 0, 1),
                        objids = lineid,
                        alpha = c(0, 1, 0, 0, 1, 0)),
             start = 0, stop = 4*pi,
             step = 0.1, rate = 4)
  if (interactive() || in_pkgdown_example())
    widget
  options(saveopts)
}
