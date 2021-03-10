\name{tkspin3d}
\alias{tkspin3d}
\title{Create TCL/TK controller for rgl window}
\description{
  This function creates a TCL/TK window containing buttons to spin and 
  resize one or more rgl windows.
}
\usage{
tkspin3d(dev = cur3d(), ...)
}
\arguments{
  \item{dev}{A vector of one or more rgl device numbers to control }
  \item{...}{Named parameters in that match named formal arguments
to \code{\link{tkspinControl}} are passed there, while others are passed to \code{\link[tcltk:TkWidgets]{tktoplevel}}}}
\author{ Ming Chen and Duncan Murdoch }
\seealso{ \code{\link{tkspinControl}}}
\examples{
if (interactive() && !in_pkgdown_example()) {
    open3d()
    points3d(rnorm(100), rnorm(100), rnorm(100), size=3)
    axes3d()
    box3d()
    tkspin3d()
}
}
