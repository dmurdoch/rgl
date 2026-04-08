\name{expect_known_scene}
\alias{expect_known_scene}
\alias{expect_snapshot_scene}
\title{
Helpers for \pkg{testthat} testing.
}
\description{
Gets the current scene using \code{\link{scene3d}}, and
compares the result to a saved value, optionally closing
the window afterwards.
}
\usage{
expect_known_scene(name, scene = scene3d(),
                   close = TRUE, 
                   file = paste0("testdata/", name, ".rds"),
                   ...)
                   
expect_snapshot_scene(scene = scene3d(), close = TRUE, style = "json2", ...)
}
\arguments{
  \item{name}{
By default, the base name of the file to save results in.
Not used if \code{file} is specified.
}
  \item{scene}{
The \pkg{rgl} scene to be checked.
  }
  \item{close}{
Whether to close the \pkg{rgl} window after the comparison.
}
  \item{file}{
The file in which to save the result.
}
  \item{style}{
The style of representation of the value to use.
  }
  \item{...}{
Other arguments which will be passed to \code{\link[testthat]{expect_known_value}} or
\code{\link[testthat]{expect_snapshot_value}}
}
}
\details{
These functions use \code{\link[testthat]{expect_known_value}} or
\code{\link[testthat]{expect_snapshot_value}} 
to save a representation of the scene.  During the comparison, the scene
is modified so that non-reproducible aspects are standardized
or omitted:  
\itemize{
\item{object ids are changed to start at 1.}
\item{system-specific font names and texture names are deleted.}
\item{the window is shifted to the top left of the screen.}
}

Calls to \code{expect_known_scene()} enable \code{testthat::\link[testthat]{local_edition}(2)} 
for the duration of the call, so it will work in \pkg{testthat} \dQuote{3rd edition}.  Calls to \code{expect_snapshot_scene()} enable \code{testthat::\link[testthat]{local_edition}(3)}.

}
\value{
A value describing the changes to the saved object,
suitable for use in \code{\link[testthat]{test_that}()}.
}
\examples{
\dontrun{
# These lines can be included in testthat::test_that() code.
plot3d(1:10, 1:10, 1:10)
expect_known_scene("plot")
expect_snapshot_scene()
}
}