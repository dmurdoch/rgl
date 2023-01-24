\name{checkDeldir}
\alias{checkDeldir}
\title{
Check for a compatible version of \pkg{deldir}
}
\description{
Version 1.0-2 of \pkg{deldir} is not compatible with \pkg{rgl}.
This allows code to avoid trying to call it.
}
\usage{
checkDeldir(error = FALSE)
}
\arguments{
  \item{error}{
If \code{TRUE}, stop with an error.
}
}
\value{
Returns \code{TRUE} if \pkg{deldir} is available in a compatible
version.
}
\examples{
checkDeldir()
}
