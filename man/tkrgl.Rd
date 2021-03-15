\name{tkrgl}
\alias{tkrgl}
\title{
The former tkrgl package
}
\description{
Functions from the former \pkg{tkrgl} package.
}
\details{
The \pkg{tkrgl} package contained functions to use TCL/TK to control
an RGL scene on screen.  These functions have now been merged
into the \pkg{rgl} package, and the \pkg{tkrgl} package has
been archived.

To avoid conflicts with RGL names and to indicate the TCL/TK 
nature of these functions, they have all been prefixed with \code{tk}:

\describe{
\item{\code{\link{tkpar3dsave}}}{Formerly \code{tkrgl::par3dsave}, allows interactive
saving of scene parameters.}
\item{\code{\link{tkspin3d}, \link{tkspinControl}}}{Formerly 
\code{tkrgl::spin3d} and \code{tkrgl::spinControl}, create buttons
to spin the scene.}
}

History:
\tabular{ll}{
0.2-2 \tab First public release \cr
0.3   \tab Added possibility to control multiple windows \cr
0.4   \tab Compatibility with 2.0.0 tcltk package \cr
0.5   \tab Added continuous rotation \cr
0.6   \tab Added par3dsave \cr
0.7   \tab Added parameters to \code{\link{tkspinControl}}, fixed startup \cr
0.8   \tab Minor fixes to pass checks \cr
0.9   \tab Merge functions into \pkg{rgl} \cr
}
}
