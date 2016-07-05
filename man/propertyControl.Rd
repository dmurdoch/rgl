\name{propertyControl}
\alias{subsetControl}
\alias{propertyControl}
\title{
Controls to use with playwidget().
}
\description{
These are setter functions to produce actions in a Shiny app,
or in an animation.
}
\usage{
subsetControl(value = 1, subsets, subscenes = NULL,
                         fullset = Reduce(union, subsets),
                         accumulate = FALSE)
propertyControl(value = 0, entries, properties, objids, values = NULL,
                param = seq_len(NROW(values)) - 1, interp = TRUE)
}
\arguments{
  \item{value}{The value to use for input (typically \code{input$value}
  in a Shiny app.)}
  \item{subsets}{A list of vectors of object identifiers; the value will
  choose among them.}
  \item{fullset}{Objects in the subscene which are not in \code{fullset}
  will not be touched.}
  \item{subscenes}{The subscenes to be controlled.  If \code{NULL}, the
  root subscene.}
  \item{accumulate}{If \code{TRUE}, the subsets will accumulate (by union)
  as the value increases.}
  \item{entries, properties, objids}{Which properties to set.}
  \item{values}{Values to set.}
  \item{param}{Parameter values corresponding to the rows of \code{value}}
  \item{interp}{Whether to use linear interpolation between \code{param}
  values}
}
\details{
\code{subsetControl} produces data for \code{\link{playwidget}} to
display subsets of the object in one or more subscenes.  This code will not
touch objects in the
subscenes if they
are not in \code{fullset}.  \code{fullset} defaults to the union of
all the object ids mentioned in \code{subsets}, so by default if an id is
not mentioned in one of the subsets, it will not be controlled by the slider.  If \code{value} is specified in R code, it will be a 1-based
index into the \code{subsets} list; when specified internally
in Javascript, 0-based indexing into the corresponding array
will be used.

\code{propertyControl} sets individual properties.  Here the row
of \code{values} is determined by the position of \code{value}
in \code{param}.
}
\value{
These functions return controller data in a list of class
\code{"rglControl"}.
}
\author{
Duncan Murdoch
}

\seealso{
\code{\link[rgl]{subsetSetter}} for a way to embed a pure Javascript
control, and \code{\link{playwidget}} for a way to use these
in animations (including Shiny).
}
