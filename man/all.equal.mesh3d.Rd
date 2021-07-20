\name{all.equal.mesh3d}
\alias{all.equal.mesh3d}
\alias{compare_proxy.mesh3d}
\title{
Compare mesh3d objects in a meaningful way.
}
\description{
These functions allow comparison of mesh3d objects, ignoring
irrelevant differences.  

\code{compare_proxy.mesh3d} can function as a \code{compare_proxy} method for the
\pkg{waldo} package, by stripping out \code{NULL} components
and ordering other components alphabetically by name.

\code{all.equal.mesh3d} compares mesh3d objects by using
\code{compare_proxy.mesh3d} to standardize them, then
using the regular \code{\link{all.equal}} function to
compare them.
}
\usage{
\method{all.equal}{mesh3d}(target, current, ...)
compare_proxy.mesh3d(x, path = "x")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{target, current}{
Two mesh3d objects to compare.  
}
  \item{x}{
A single mesh3d object to standardize.
}
  \item{path}{
The string to use in a \pkg{waldo} display of this object.
}
  \item{\dots}{
Additional parameters to pass to \code{\link{all.equal}}.
}
}
\value{
\code{all.equal.mesh3d} returns \code{TRUE}, or a character
vector describing (some of) the differences.

\code{compare_proxy.mesh3d} returns a list containing two
components:
\describe{
\item{object}{a copy of \code{x} with
relevant components in alphabetical order.}
\item{path}{a modification of the path label for \code{x}}
}
}
\note{
\pkg{waldo} is not an installation requirement for \pkg{rgl}
and \pkg{rgl} will never cause it to be loaded.
The \code{compare_proxy.mesh3d} function will only be 
registered as a method for \code{waldo::compare_proxy}
if you load \pkg{waldo} before \pkg{rgl}, as would normally 
happen during testing using \pkg{testthat}, or if you load
it before calling \code{\link{mesh3d}},
as might happen if you are doing manual tests.
}
