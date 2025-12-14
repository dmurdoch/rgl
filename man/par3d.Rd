\name{par3d}
\alias{par3d}
\alias{rgl.par3d.names}
\alias{rgl.par3d.readonly}
\concept{activeSubscene}
\concept{antialias}
\concept{bbox}
\concept{cex}
\concept{family}
\concept{font}
\concept{fontname}
\concept{FOV}
\concept{ignoreExtent}
\concept{maxClipPlanes}
\concept{modelMatrix}
\concept{listeners}
\concept{mouseMode}
\concept{projMatrix}
\concept{scale}
\concept{skipRedraw}
\concept{useFreeType}
\concept{userMatrix}
\concept{userProjection}
\concept{viewport}
\concept{windowRect}
\concept{zoom}

\title{Set or query RGL parameters}

\description{
  \code{par3d} can be used to set or query graphical parameters in RGL.
  Parameters can be set by specifying them as arguments to \code{par3d} in
  \code{name = value} form, or by passing them as a list of named
  values.
}
\usage{
par3d(\dots, no.readonly = FALSE, dev = cur3d(), 
      subscene = currentSubscene3d(dev))
rgl.par3d.names
rgl.par3d.readonly
}

\arguments{
  \item{\dots}{arguments in \code{name = value} form, or a list of tagged
    values.  The names must come from the graphical parameters described
    below.}
  \item{no.readonly}{logical; if \code{TRUE} and there are no other
    arguments, only those parameters which can be set by a
    subsequent \code{par3d()} call are returned.}
  \item{dev}{integer; the RGL device.}
  \item{subscene}{integer; the subscene.}
}

\details{
  Parameters are queried by giving one or more character vectors to
  \code{par3d}.

  \code{par3d()} (no arguments) or \code{par3d(no.readonly = TRUE)} is used to
  get \emph{all} the graphical parameters (as a named list).  

  By default, queries and modifications apply to the current subscene
  on the current device; specify \code{dev} and/or \code{subscene} to 
  change this.  Some parameters apply to the device as a whole;
  these are marked in the list below.

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

The \code{rgl.par3d.names} variable contains the
full list of names of \code{par3d} properties.
\code{rgl.par3d.readonly} contains the list of
read-only properties.

In the list below, \emph{\bold{R.O.}} indicates the
read-only arguments: These may only be used in
queries, they do not set anything.
  
  \describe{
    \item{\code{activeSubscene}}{\emph{\bold{R.O.}} integer.  Used
    with \code{\link{rgl.setMouseCallbacks}}:  during a 
    callback, indicates the id of the subscene that was clicked.}
    \item{\code{antialias}}{\emph{\bold{R.O.}} in \code{par3d}, may be
    set in \code{open3d}. The (requested) number of hardware
    antialiasing planes to use (with multisample antialiasing).  The
    OpenGL driver may not support the requested number, in which case
    \code{par3d("antialias")} will report what was actually set. Applies to the whole device.}    
    \item{\code{cex}}{real.  The default size for text.}
    \item{\code{family}}{character.  The default device independent family name; see \code{\link{text3d}}.
    Applies to the whole device.}
   \item{\code{font}}{integer.  The default font number (from 1 to 4; see \code{\link{text3d}}).
    Applies to the whole device.}
    \item{\code{useFreeType}}{logical.  Should the
    FreeType fonts fonts specified in \code{\link{rglFonts}} be used? Applies to the whole device.}
    \item{\code{fontname}}{\emph{\bold{R.O.}}; the system-dependent name of the current font.
    Applies to the whole device.}
    \item{\code{FOV}}{real.  The field of view, from 0 to 179 degrees.  This controls
      the degree of parallax in the perspective view.
      Isometric perspective corresponds to \code{FOV = 0}.}
    \item{\code{ignoreExtent}}{logical.  Set to \code{TRUE} so that subsequently plotted objects
      will be ignored in calculating the bounding box of the scene.  Applies to the
      whole device.}
    \item{\code{maxClipPlanes}}{\emph{\bold{R.O.}}; an integer giving the maximum
      number of clip planes that can be defined in the current system. Applies to the whole device.}
    \item{\code{modelMatrix}}{\emph{\bold{R.O.}}; a 4 by 4 matrix describing the position
      of the user data.  See the Note below.}
    \item{\code{listeners}}{integer.  A vector of subscene id values.  If a subscene receives
      a mouse event (see \code{mouseMode} just below), the same action will be carried out
      on all subscenes in this list.  (The subscene itself is normally listed as a listener.
      If it is not listed, it will not respond to its own mouse events.)}
    \item{\code{mouseMode}}{character.  A vector of 5 strings describing
      mouse actions. The 5 entries are named
      \code{c("none", "left", "right", "middle", "wheel")}, corresponding to actions for no button, 
      the left, right or middle button, and the 
      mouse wheel.
      Partial matching to action names is used.  Possible values for the actions are:
	\describe{
	 \item{\code{"none"}}{No action for this button.}
	 \item{\code{"trackball"}}{Mouse acts as a virtual trackball, rotating the scene.}
	 \item{\code{"xAxis"}}{Similar to \code{"trackball"}, but restricted to X axis rotation.}
	 \item{\code{"yAxis"}}{Y axis rotation.}
	 \item{\code{"zAxis"}}{Z axis rotation.}
	 \item{\code{"polar"}}{Mouse rotates the scene by moving in polar coordinates.}
	 \item{\code{"selecting"}}{Mouse is used for selection.  This is not normally set by the
	 user, but is used internally by the \code{\link{select3d}} function.}
	 \item{\code{"zoom"}}{Mouse is used to zoom the display.}
	 \item{\code{"fov"}}{Mouse changes the field of view of the display.}
	 \item{\code{"user"}}{Used  when a user handler is set by 
	 \code{\link{rgl.setMouseCallbacks}}.}
	}
      Possible values for the last entry corresponding to the mouse wheel also include
        \describe{
	  \item{\code{"pull"}}{Pulling on the mouse wheel increases magnification, i.e. \dQuote{pulls the scene closer}.}
	  \item{\code{"push"}}{Pulling on the mouse wheel decreases magnification, i.e. \dQuote{pushes the scene away}.}
	  \item{\code{"user2"}}{Used when a user handler is set by 
	    \code{\link{rgl.setWheelCallback}}.}
	}
      A common default on Mac OSX is to convert a two finger drag on a trackpad to a mouse wheel rotation.
      
      The first entry is for actions to take when
no mouse button is pressed.  Legal values are the same
as for the mouse buttons.

      The first entry was added after \pkg{rgl} version 0.106.8.  For back compatibility, if the vector
      of actions is less than 5 entries, \code{"none"}
      will be added at the start of it.
    }
    \item{\code{observer}}{\emph{\bold{R.O.}}; the position of the observer relative to
      the model.  Set by \code{\link{observer3d}}.  See the Note below.}
    \item{\code{projMatrix}}{\emph{\bold{R.O.}}; a 4 by 4 matrix describing the current
      projection of the scene.}
    \item{\code{scale}}{real.  A vector of 3 values indicating the amount by which to
      rescale each axis before display.  Set by \code{\link{aspect3d}}.}
    \item{\code{skipRedraw}}{whether to update the display.  Set to \code{TRUE} to suspend
      updating while making multiple changes to the scene.  See \code{demo(hist3d)} for an example.
      Applies to the whole device.}
    \item{\code{userMatrix}}{a 4 by 4 matrix describing user actions to
      display the scene.}
    \item{\code{userProjection}}{a 4 by 4 matrix describing
changes to the projection.}
    \item{\code{viewport}}{real.  A vector giving the dimensions of the
      window in pixels.  The entries are taken to be \code{c(x, y, width, height)} where
      \code{c(x, y)} are the coordinates in pixels of the lower left corner within the window.}
    \item{\code{zoom}}{real. A positive value indicating the current
      magnification of the scene.}
      \item{\code{bbox}}{\emph{\bold{R.O.}}; real. A vector of six values indicating the current values of the
      bounding box of the scene (xmin, xmax, ymin, ymax, zmin, zmax)}
    \item{\code{windowRect}}{integer.  A vector of four values indicating the left, top, right and 
      bottom of the displayed window (in pixels).  Applies to the whole device.}
  }
}

\note{
The \code{"xAxis"}, \code{"yAxis"} and \code{"zAxis"} mouse modes rotate 
relative to the coordinate system of the data, regardless of the current 
orientation of the scene.

When multiple parameters are set, they are set in the order given.  In some 
cases this may lead to warnings and ignored values; for example, some font 
families only support \code{cex = 1}, so changing both \code{cex} and 
\code{family} needs to be done in the right order.  For example, when using the
\code{"bitmap"} family on Windows, \code{par3d(family = "sans", cex = 2)}
will work, but \code{par3d(cex = 2, family = "sans")} will leave \code{cex}
at 1 (with a warning that the \code{"bitmap"} family only supports that size).

Although \code{par3d("viewport")} names the entries of the reported vector,
names are ignored when setting the viewport and entries must be specified
in the standard order.

In \pkg{rgl} versions 0.94.x the \code{modelMatrix} entry had a changed meaning; 
before and after that it contains a copy of the OpenGL MODELVIEW matrix. 

As of version 0.100.32, when changing the \code{"windowRect"} parameter, the 
\code{"viewport"} for the root (or specified) subscene
is changed immediately.  This fixes a bug where in earlier
versions it would only be changed when the window was redrawn, potentially after another command making use of the value.

Default values are not described here, as several of them
are changed by the \code{\link{r3dDefaults}} variable when
the window is opened by \code{\link{open3d}}.
}

\section{Rendering}{
The parameters returned by \code{par3d} are sufficient to determine where RGL would render
a point on the screen.  Given a column vector \code{(x, y, z)} in a subscene \code{s}, 
it performs the equivalent of 
the following operations:
\enumerate{
\item It converts the point to homogeneous coordinates by appending \code{w = 1}, giving
the vector \code{v = (x, y, z, 1)}.
\item It calculates the \code{M = par3d("modelMatrix")} as a product from right to left
of several matrices:
  \itemize{  
  \item A matrix to translate the centre of the bounding box to the origin.
  \item A matrix to rescale according to \code{par3d("scale")}.
  \item The \code{par3d("userMatrix")} as set by the user.
  \item A matrix which may be set by mouse movements.
  \item The description above applies to the usual case where there 
  is just one subscene, or where the subscene's \code{"model"} is set to
  \code{"replace"}.  If it is set to \code{"modify"}, the first step is
  skipped, and at the end the procedure is followed for the parent subscene.  If it is set to \code{"inherit"} only the parent settings
  are used.
  }
\item It multiplies the point by \code{M} giving \code{u = M \%*\% v}. 
\item It multiplies that point by a matrix based on the observer position
to translate the origin to the centre of the viewing region.
\item Using this location and information on the
normals (which have been similarly transformed), it performs lighting calculations. 
\item It obtains the projection matrix \code{P = par3d("projMatrix")} based on the bounding box and field of view
or observer location, multiplies that by the \code{userProjection} matrix to give \code{P}.  It multiplies the point
by it giving \code{P \%*\% u = (x2, y2, z2, w2)}.
\item It converts back to Euclidean coordinates by dividing the first 3 coordinates by \code{w2}.
\item The new value \code{z2/w2} represents the depth into the scene of the point.  Depending
on what has already been plotted, this depth might be obscured, in which case nothing more is plotted.
\item If the point is not culled due to depth, the \code{x2} and \code{y2} values are used
to determine the point in the image.  The \code{par3d("viewport")} values are used to translate
from the range \code{(-1, 1)} to pixel locations, and the point is plotted.
\item If hardware antialiasing is enabled, then the whole process is
repeated multiple times (at least conceptually) with different
locations in each pixel sampled to determine what is plotted there,
and then the images are combined into what is displayed.
}
See ?\link{matrices} for more information on homogeneous and Euclidean coordinates.

Note that many of these calculations are done on the graphics card using single precision;
you will likely see signs of rounding error if your scene requires more than 4 or 5 
digit precision to distinguish values in any coordinate.  
}

\seealso{
\code{\link{view3d}} to set \code{FOV} and \code{zoom}.

\code{\link{open3d}} for how to open a new window
with default settings for these parameters.
}

\references{
OpenGL Architecture Review Board (1997).  OpenGL Programming Guide.  Addison-Wesley.
}

\examples{
    open3d()
    shade3d(cube3d(color = rainbow(6), meshColor = "faces"))
    save <- par3d(userMatrix = rotationMatrix(90*pi/180, 1, 0, 0))
    highlevel()  # To trigger display
    save
    par3d("userMatrix")    
    par3d(save)
    highlevel()
    par3d("userMatrix")
}

\keyword{dynamic}
