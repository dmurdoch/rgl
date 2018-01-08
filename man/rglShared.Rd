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
rglShared(id, key = NULL, group = NULL,
          deselectedFade = 0.1, 
          deselectedColor = NULL,
	  selectedColor = NULL,
          selectedIgnoreNone = TRUE,
	  filteredFade = 0,
          filteredColor = NULL)
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
  \item{deselectedFade, deselectedColor}{
Appearance of points that are not selected. See Details.
}
  \item{selectedColor}{
Appearance of points that are selected.
}
  \item{selectedIgnoreNone}{
If no points are selected, should the points be shown
in their original colors (\code{TRUE}), or in the 
deselected colors (\code{FALSE})?
}
  \item{filteredFade, filteredColor}{
Appearance of points that have been filtered out.
}
}
\details{
Some functions which normally work on 
dataframe-like datasets will accept shared data
objects in their place. 

If a selection is in progress, the alpha value for
unselected points is multiplied by \code{deselectedFade}.
If \code{deselectedColor} is \code{NULL}, the color is left
as originally specified; if not, the point is changed to
the color given by \code{deselectedColor}.

If no points have been selected, then by default points
are shown in their original colors.  However, if 
\code{selectedIgnoreNone = FALSE}, all points are displayed
as if unselected.

The \code{selectedColor} argument is similarly used to 
change the color (or not) of selected points, and \code{filteredFade} 
and \code{filteredColor} are used for points that
have been filtered out of the display.
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
  save <- options(rgl.useNULL = TRUE)
  open3d()
  x <- sort(rnorm(100))
  y <- rnorm(100)
  z <- rnorm(100) + atan2(x, y)
  ids <- plot3d(x, y, z, col = rainbow(100))
  # The data will be selected and filtered, the the axes.
  sharedData <- rglShared(ids["data"])
  
  # Also add some labels that are only displayed
  # when points are selected
  
  sharedLabel <- rglShared(text3d(x, y, z, text = 1:100,
                                  adj = -0.5),
                           group = sharedData$groupName(),
                           deselectedFade = 0,
                           selectedIgnoreNone = FALSE) 
  if (interactive()) 
    htmltools::browsable(htmltools::tagList(
      rglwidget(shared = list(sharedData, sharedLabel), 
                width = 400, height = 300) 
      \%>\% rglMouse(), 
      crosstalk::filter_slider("x", "x", sharedData, ~x, width = 400)))
      
  options(save)
  }