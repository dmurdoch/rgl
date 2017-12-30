\name{rglShared}
\alias{rglShared}
\title{
Create shared data from an rgl object.
}
\description{
The \pkg{crosstalk} package provides a way for
different parts of an interactive display to 
communicate about datasets, using \dQuote{shared data} objects.  When selection or filtering
is performed in one view, the result is mirrored 
in all other views.

This function allows vertices of rgl objects
to be treated as shared data.
}
\usage{
rglShared(id, key = NULL, group = NULL)
}
\arguments{
  \item{id}{
An existing rgl id.
}
  \item{key}{
Optional unique labels to apply to each vertex.
If missing, numerical keys will be used.
}
  \item{group}{
Optional name of the shared group to which
this data belongs.  If missing, a random name
will be generated.
}
}
\details{
Some functions which normally work on 
dataframe-like datasets will accept shared data
objects in their place. 
}
\value{
An object of class \code{"SharedData"} which 
contains the x, y and z coordinates of the rgl object 
with the given \code{id}.
}
\references{
\url{https://rstudio.github.io/crosstalk/index.html}
}
\author{
Duncan Murdoch
}

\examples{
  open3d()
  x <- sort(rnorm(1000))
  y <- rnorm(1000)
  z <- rnorm(1000) + atan2(x, y)
  ids <- plot3d(x, y, z, col = rainbow(1000))
  sharedData <- rglShared(ids["data"])
  if (interactive()) {
    htmltools::browsable(htmltools::tagList(
      rglwidget(shared = sharedData, width = 400, height = 300), 
      crosstalk::filter_slider("x", "x", sharedData, ~x, width = 400)))
  } 
  }