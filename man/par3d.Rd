\name{par3d}
\alias{par3d}
\alias{open3d}
\alias{r3dDefaults}
\concept{FOV}
\concept{modelMatrix}
\concept{mouseMode}
\concept{projMatrix}
\concept{userMatrix}
\concept{viewport}
\concept{zoom}
\concept{bbox}

\title{Set or Query RGL Parameters}

\description{
  \code{par3d} can be used to set or query graphical parameters in rgl.
  Parameters can be set by specifying them as arguments to \code{par3d} in
  \code{tag = value} form, or by passing them as a list of tagged
  values.
}
\usage{
par3d(\dots, no.readonly = FALSE)

open3d(\dots, params=get("r3dDefaults", envir=.GlobalEnv))

}

\arguments{
  \item{\dots}{arguments in \code{tag = value} form, or a list of tagged
    values.  The tags must come from the graphical parameters described
    below.}
  \item{no.readonly}{logical; if \code{TRUE} and there are no other
    arguments, only those parameters which can be set by a
    subsequent \code{par3d()} call are returned.}
  \item{params}{a list of graphical parameters}
}

\details{
  Parameters are queried by giving one or more character vectors to
  \code{par3d}.

  \code{par3d()} (no arguments) or \code{par3d(no.readonly=TRUE)} is used to
  get \emph{all} the graphical parameters (as a named list).  

  \emph{\bold{R.O.}} indicates \emph{\bold{read-only arguments}}: These
  may only be used in queries, i.e., they do \emph{not} set anything.

  \code{open3d} opens a new rgl device, and sets the parameters as
  requested.  The \code{r3dDefaults} list will be used as default
  values for parameters.  As installed this sets the point of view to
  'world coordinates' (i.e. x running from left to right, y from front
  to back, z from bottom to top), the \code{mouseMode} to
  \code{(trackball, zoom, fov)}, and the field of view to 30 degrees.
  Users may create their own variable of that name in the global
  environment and it will override the installed one.
}

\value{
  When parameters are set, their former values are returned in an
  invisible named list.  Such a list can be passed as an argument to
  \code{par3d} to restore the parameter values.
  Use \code{par3d(no.readonly = TRUE)} for the full list of parameters
  that can be restored.

  When just one parameter is queried, its value is returned directly.
  When two or more parameters are queried, the result is a list of
  values, with the list names giving the parameters.

  Note the inconsistency: setting one parameter returns a list, but
  querying one parameter returns an object.
}

\section{Parameters}{
  \describe{
    \item{\code{FOV}}{real.  The field of view, from 1 to 179 degrees.  This controls
      the degree of parallax in the perspective view.
      Isometric perspective (which would
      correspond to \code{FOV=0}) is not currently possible, but one can
      approximate it by specifying \code{par3d(FOV=1)}.}
    \item{\code{modelMatrix}}{\emph{\bold{R.O.}}; a 4 by 4 matrix describing the position
      of the user data.}
    \item{\code{mouseMode}}{character.  A vector of 3 strings describing
      what the 3 mouse buttons do. Partial matching is used.  Possible values for \code{mouseMode} are 
	\describe{
	 \item{\code{"none"}}{No action for this button.}
	 \item{\code{"trackball"}}{Mouse acts as a virtual trackball, rotating the scene.}
	 \item{\code{"polar"}}{Mouse rotates the scene by moving in polar coordinates.}
	 \item{\code{"selecting"}}{Mouse is used for selection.  This is not normally set by the
	 user, but is used internally by the \code{\link{select3d}} function.}
	 \item{\code{"zoom"}}{Mouse is used to zoom the display.}
	 \item{\code{"fov"}}{Mouse changes the field of view of the display.}
	}
    }
    \item{\code{projMatrix}}{\emph{\bold{R.O.}}; a 4 by 4 matrix describing the current
      projection of the scene.}
    \item{\code{skipRedraw}}{whether to update the display.  Set to \code{FALSE} to suspend
      updating while making multiple changes to the scene.  See \code{demo(hist3d)} for an example.}
    \item{\code{userMatrix}}{a 4 by 4 matrix describing user actions to
      display the scene.}
    \item{\code{viewport}}{\emph{\bold{R.O.}}; real.  A vector giving the dimensions of the
      window in pixels.}
    \item{\code{zoom}}{real. A positive value indicating the current
      magnification of the scene.}
      \item{\code{bbox}}{\emph{\bold{R.O.}}; real. A vector of six values indicating the current values of the
      bounding box of the scene (xmin, xmax, ymin, ymax, zmin, zmax)}
  }
}

\section{Rendering}{
The parameters returned by \code{par3d} are sufficient to determine where rgl would render
a point on the screen.  Given a column vector \code{(x,y,z)}, it performs the equivalent of 
the following operations:
\enumerate{
\item It converts the point to homogeneous coordinates by appending \code{w=1}, giving
the vector \code{v = (x,y,z,1)}.
\item It obtains the model matrix \code{M = par3d("modelMatrix")} and multiplies
the point by this giving \code{u = M \%*\% v}.  Using this location and information on the
normals (which have been similarly transformed), it performs lighting calculations.
\item It obtains the projection matrix \code{P = par3d("projMatrix")} and
multiplies the point by it giving \code{P \%*\% u = (x2, y2, z2, w2)}.
\item It converts back to Euclidean coordinates by dividing the first 3 coordinates by \code{w2}.
\item The new value \code{z2/w2} represents the depth into the scene of the point.  Depending
on what has already been plotted, this depth might be obscured, in which case nothing more is plotted.
\item If the point is not culled due to depth, the \code{x2} and \code{y2} values are used
to determine the point in the image.  The \code{par3d("viewport")} values are used to translate
from the range \code{(-1, 1)} to pixel locations, and the point is plotted.
}
See ?\link{matrices} for more information on homogeneous and Euclidean coordinates.
}

\seealso{\code{\link{rgl.viewpoint}} to set \code{FOV} and \code{zoom}.
}

\references{
OpenGL Architecture Review Board (1997).  OpenGL Programming Guide.  Addison-Wesley.
}

\examples{
    open3d()
    
    save <- par3d(userMatrix = rotationMatrix(90*pi/180, 1,0,0))
    save
    par3d("userMatrix")    
    par3d(userMatrix = save)
    par3d("userMatrix")
}

\keyword{dynamic}
