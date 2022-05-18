\name{rgl.useNULL}
\alias{rgl.useNULL}
\alias{RGL_USE_NULL}
\title{
Report default use of null device
}
\description{
This function checks the \code{"rgl.useNULL"} option if present, or the
\env{RGL_USE_NULL} environment variable if it is not.  If the value is
\code{TRUE} or a string which matches \dQuote{yes} or \dQuote{true}
in a case-insensitive test, \code{TRUE} is returned.
}
\usage{
rgl.useNULL()
}
\note{
This function is checked by the initialization code when the \pkg{rgl} package
is loaded.  Thus if you want to run RGL on a system where there is no
graphics support, you should run \code{options(rgl.useNULL = TRUE)}
or set the environment variable \code{RGL_USE_NULL=TRUE} *before*
calling \code{library(rgl)} (or other code that 
loads \pkg{rgl}), and it will not fail in its attempt at initialization.
}
\value{
A logical value indicating the current default for use of the null
device.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{open3d}} and \code{\link{rgl.open}}.
}
\examples{
rgl.useNULL()
}
