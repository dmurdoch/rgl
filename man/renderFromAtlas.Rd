\name{renderFromAtlas}
\alias{renderFromAtlas}
\title{Render strings from atlas}
\usage{
renderFromAtlas(
  atlas,
  num,
  x = 0,
  y = 0,
  verbose = FALSE,
  interpolate = FALSE,
  showBaselines = FALSE,
  ...
)
}
\arguments{
\item{atlas}{The glyph atlas holding the glyphs,
produced by \code{\link{glyphAtlas}}.}

\item{num}{Which glyph numbers to plot?}

\item{x, y}{The origin at which to plot each string.}

\item{verbose}{Print information about each string?}

\item{interpolate}{Smooth the rendering?}

\item{showBaselines}{Show the baselines for each string?}

\item{...}{Additional plot parameters.}
}
\description{
The glyph atlas holds one copy of each glyph, and
information about where each should be rendered.  This
function uses that information to render selected
strings.
}
\examples{
example(glyphAtlas)
renderFromAtlas(atlas_monochrome, 1:2, y = c(0, 30), showBaselines=TRUE)
renderFromAtlas(atlas_color, 1:2, y = c(0, 30), showBaselines=TRUE)
}
