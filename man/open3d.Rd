\name{open3d}
\alias{open3d}
\alias{close3d}
\alias{cur3d}
\alias{set3d}
\alias{getr3dDefaults}
\alias{r3dDefaults}

\title{Work with RGL windows}

\description{
  \code{open3d} opens a new RGL window; \code{cur3d} returns the device number of the current
  window; \code{close3d} closes one or more windows.
}
\usage{
open3d(\dots, params = getr3dDefaults(), 
	    useNULL = rgl.useNULL(), silent = FALSE)
	    
close3d(dev = cur3d(), silent = TRUE)
	    
cur3d()

set3d(dev, silent = FALSE)

getr3dDefaults(class = NULL, value = NULL)

r3dDefaults
}

\arguments{
  \item{\dots}{arguments in \code{tag = value} form, or a list of tagged
    values.  The tags must come from the graphical
    parameters described in \code{\link{par3d}}.}
  \item{params}{a list of graphical parameters}
  \item{useNULL}{whether to use the null graphics device}
  \item{dev}{which device to close or use}
  \item{silent}{whether report on what was done}
  \item{class, value}{names of components to retrieve}
}

\details{
  \code{open3d} opens a new RGL device, and sets the parameters as
  requested.  The \code{r3dDefaults} list returned by the 
  \code{getr3dDefaults} function will be used as default
  values for parameters.  As installed this sets the point of view to
  'world coordinates' (i.e. x running from left to right, y from front
  to back, z from bottom to top), the \code{mouseMode} to
  \code{(zAxis, zoom, fov)}, and the field of view to 30 degrees.  \code{useFreeType} defaults to \code{FALSE} on 
  Windows; on other systems it indicates the availability
  of FreeType.
  Users may create their own variable named \code{r3dDefaults} in the global
  environment and it will override the installed one.  If there
  is a \code{bg} element in the list or the arguments, it should be
  a list of arguments to pass to the \code{\link{bg3d}} function to 
  set the background.  
  
  The arguments to \code{open3d} may include \code{material}, a list
  of material properties as in \code{\link{r3dDefaults}}, but note
  that high level functions such as \code{\link{plot3d}} normally use
  the \code{r3dDefaults} values in preference to this setting. 
  
  If \code{useNULL} is \code{TRUE}, RGL will use a \dQuote{null}
  device.  This device records objects as they are plotted, but 
  displays nothing. It is intended for use with \code{\link{rglwidget}}.
  

}

\value{
The \code{open3d} function returns the device that 
was opened.  If 
\code{silent = TRUE}, it is returned invisibly.

The \code{cur3d} function returns the current device,
or the value 0 if there isn't one.

\code{set3d} returns the device number of the
previously active device.

The \code{close3d} function returns the new current
device, invisibly.

  The \code{r3dDefaults} variable is a list containing default
  settings.  The \code{getr3dDefaults} function searches the user's
  global environment for \code{r3dDefaults} and returns the 
  one in the RGL namespace if it was not found there.
  The components of the list may include any settable \code{par3d}
  parameter, or \code{"material"}, which should include a list
  of default \code{\link{material3d}} properties, or \code{"bg"}, 
  which is a
  list of defaults to pass to the \code{\link{bg3d}} function.
}

\seealso{
\code{\link{rgl.useNULL}} for default usage of null device.
}

\examples{
    r3dDefaults
    open3d()
    shade3d(cube3d(color = rainbow(6), meshColor = "faces"))
    cur3d()
}

\keyword{dynamic}
