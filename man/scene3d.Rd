\name{scene3d}
\alias{scene3d}
\alias{rglscene-class}
\alias{rglobject-class}
\alias{plot3d.rglscene}
\alias{plot3d.rglobject}
\alias{print.rglscene}
\alias{print.rglobject}
\title{
Saves the current scene to a variable, and displays such variables.
}
\description{
This function saves a large part of the RGL state associated with the current
window to a variable.  
}
\usage{
scene3d(minimal = TRUE)
\S3method{plot3d}{rglscene}(x, add = FALSE, ...)
\S3method{plot3d}{rglobject}(x, ...)
\S3method{print}{rglscene}(x, ...)
\S3method{print}{rglobject}(x, ...)
}
\arguments{
\item{minimal}{Should attributes be skipped if they currently have
  no effect?  See Details.}
\item{x}{An object of class \code{"rglscene"}}
\item{add}{Whether to open a new window, or add to the existing one.}
\item{...}{Additional parameters, currently ignored.}
}
\details{
The components saved are:  the \code{\link{par3d}} settings, the \code{\link{material3d}}
settings, the \code{\link{bg3d}} settings, the lights and the objects in the scene.

In most cases, calling \code{\link{plot3d}} on that variable will
duplicate the scene.  (There are likely to be small differences, mostly internal, but
some aspects of the scene are not currently available.) If textures are used,
the name of the texture will be saved, rather than the contents of the 
texture file.

Other than saving the code
to recreate a scene, saving the result of \code{scene3d} to 
a file will allow it to be reproduced later most accurately.  In roughly decreasing order of fidelity,
\code{\link{writeWebGL}}, \code{\link{writePLY}}, \code{\link{writeOBJ}} and \code{\link{writeSTL}}
write the scene to a file in formats readable by other software.

If \code{minimal = TRUE} (the default), then attributes of objects
will not be saved if they currently have no effect on
the display, thereby reducing the file size.  
Set \code{minimal = FALSE} if the scene is intended
to be used in a context where the appearance could be changed.  
Currently this only affects the inclusion of normals; with 
\code{minimal = TRUE} they are
omitted for objects when the material is not lit.
}
\value{
The \code{scene3d} function returns an object of class
\code{"rglscene"}.  This is a list with some or all of the components:
\item{material}{The results returned from a \code{\link{material3d}} call.}
\item{rootSubscene}{A list containing information about
the main ("root") subscene.  This may include:
\describe{
\item{id}{The scene id.}
\item{type}{"subscene"}
\item{par3d}{The \code{\link{par3d}} settings for the
subscene.}
\item{embeddings}{The \code{\link{subsceneInfo}()$embeddings} for the main subscene.}
\item{objects}{The ids for objects in the subscene.}
\item{subscenes}{A recursive list of child subscenes.}}}
\item{objects}{A list containing the RGL lights, background and objects in the scene.}  

The objects in the \code{objects} component are of class
\code{"rglobject"}.  They are lists containing some or all of the
components
\item{id}{The RGL identifier of the object in the original scene.}
\item{type}{A character variable identifying the type of object.}
\item{material}{Components of the material that differ from the scene material.}
\item{vertices, normals, etc.}{Any of the attributes of the object retrievable by \code{\link{rgl.attrib}}.}
\item{ignoreExtent}{A logical value indicating whether this object contributes to the bounding box.
Currently this may differ from the object in the original scene.}
\item{objects}{Sprites may contain other objects; they will be stored here as a list of  \code{"rglobject"}s.}

Lights in the scene are stored similarly, mixed into the \code{objects} list.

The \code{plot3d} methods invisibly return a vector of RGL object ids
that were plotted.  The \code{print} methods invisibly return the
object that was printed.

}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{rglwidget}}, \code{\link{writePLY}}, \code{\link{writeOBJ}} and \code{\link{writeSTL}}
write the scene to a file in various formats.
}
\examples{
open3d()
z <- 2 * volcano        # Exaggerate the relief
x <- 10 * (1:nrow(z))   # 10 meter spacing (S to N)
y <- 10 * (1:ncol(z))   # 10 meter spacing (E to W)
persp3d(x, y, z, col = "green3", aspect = "iso")

s <- scene3d()
# Make it bigger
s$par3d$windowRect <- 1.5*s$par3d$windowRect
# and draw it again
plot3d(s)
}
\keyword{ graphics }

