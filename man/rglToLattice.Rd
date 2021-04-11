\name{rglToLattice}
\alias{rglToLattice}
\alias{rglToBase}
\title{
Convert RGL userMatrix to lattice or base angles
}
\description{
These functions take a user orientation matrix
from an RGL scene and approximate the
parameters to either \pkg{lattice} or base
graphics functions.
}
\usage{
rglToLattice(rotm = par3d("userMatrix"))
rglToBase(rotm = par3d("userMatrix"))
}
\arguments{
  \item{rotm}{
A matrix in homogeneous coordinates to convert.
}
}
\details{
The \pkg{lattice} package can use Euler angles in
the ZYX scheme to describe the rotation of a scene
in its \code{\link[lattice:cloud]{wireframe}} or
\code{\link[lattice]{cloud}} functions.  The
\code{rglToLattice} function computes these angles
based on \code{rotm}, which defaults to the current
user matrix.  This allows RGL to be used
to interactively find a decent viewpoint and
then reproduce it in \pkg{lattice}.

The base graphics \code{\link{persp}} function does
not use full Euler angles; it
uses a viewpoint angle, and assume the z axis
remains vertical.  The \code{rglToBase} function
computes the viewpoint angle accurately if the
RGL scene is displayed with a vertical
z axis, and does an approximation otherwise.
}
\value{
\code{rglToLattice} returns a list suitable to
be used as the \code{screen} argument to 
\code{\link[lattice:cloud]{wireframe}}.

\code{rglToBase} returns a list containing
\code{theta} and \code{phi} components which
can be used as corresponding arguments in \code{\link{persp}}.
}
\author{
Duncan Murdoch
}
\examples{
persp3d(volcano, col = "green")
if ((hasorientlib <- requireNamespace("orientlib", quietly = TRUE)) && 
    requireNamespace("lattice", quietly = TRUE)) 
    lattice::wireframe(volcano, screen = rglToLattice())
if (hasorientlib) {
  angles <- rglToBase()
  persp(volcano, col = "green", border = NA, shade = 0.5,
        theta = angles$theta, phi = angles$phi)
}
}
