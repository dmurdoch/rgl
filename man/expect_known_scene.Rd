\name{expect_known_scene}
\alias{expect_known_scene}
\title{
Helper for \pkg{testthat} testing.
}
\description{
Gets the current scene using \code{\link{scene3d}}, and
compares the result to a saved value, optionally closing
the window afterwards.
}
\usage{
expect_known_scene(name, close = TRUE)
}
\arguments{
  \item{name}{
The base name of the file to save results in.
}
  \item{close}{
Whether to close the \pkg{rgl} window after the comparison.
}
}
\details{
This function uses \code{\link[testthat]{expect_known_value}} 
to save a representation of the scene into the subdirectory
named \file{testdata}.  During the comparison, the scene
is modified so that non-reproducible aspects are standardized
or omitted:  
\itemize{
\item{object ids are changed to start at 1.}
\item{system-specific font names and texture names are deleted.}
\item{the window is shifted to the top left of the screen.}
}
}
\value{
A value describing the changes to the saved object,
suitable for use in \code{\link[testthat]{test_that()}}.
}
\examples{
\dontrun{
# These lines can be included in testthat::test_that() code.
plot3d(1:10, 1:10, 1:10)
expect_known_scene("plot")
}
}