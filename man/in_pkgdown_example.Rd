\name{in_pkgdown_example}
\alias{in_pkgdown_example}
\alias{in_pkgdown}
\title{
Are we running in \pkg{pkgdown} or a \pkg{pkgdown} example?
}
\description{
This is mainly for internal use to decide whether results
should be automatically included in a \pkg{pkgdown} web
page.

See the \HTMLVignette{rgl}{pkgdown}{}{Using RGL in pkgdown web sites}
vignette for details about using \pkg{pkgdown}.
}
\usage{
in_pkgdown()
in_pkgdown_example()
}
\value{
\code{TRUE} or \code{FALSE}
}

\examples{
in_pkgdown_example()
}
