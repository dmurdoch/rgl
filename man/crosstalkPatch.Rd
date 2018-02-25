\name{crosstalkPatch}
\alias{crosstalkPatch}
\title{
Patch for \pkg{crosstalk} compatibility issue.
}
\description{
This function arranges the dependencies in an R Markdown
document so it works with the \pkg{crosstalk} package.
}
\usage{
crosstalkPatch(deps)
}
\arguments{
  \item{deps}{
A list of dependencies
}
}
\details{
Users never need to call this function directly.  Instead, in
an R Markdown document using \code{\link[rmarkdown]{html_document}} or
related formats that
makes use of \pkg{crosstalk} functions (or any other package
that depends on the Javascript \code{jQuery} library), add the optional argument
\verb{
  dependency_resolver:  !expr rgl::crosstalkPath
}
which will force \code{jQuery} to appear after \code{htmlwidgets} in the output file.
}
\value{
A possibly re-ordered list of dependencies.
}
\references{
See \url{https://github.com/ramnathv/htmlwidgets/issues/300}
for more explanation of the need for the patch.
}
\author{
Duncan Murdoch
}
