\name{scene}
\alias{clear3d}
\alias{pop3d}
\alias{ids3d}
\title{Scene management}
\description{
Clear shapes, lights, bbox
}
\usage{
clear3d( type = c("shapes", "bboxdeco", "material"), defaults, subscene = 0 ) 
pop3d( type = "shapes", id = 0, tag = NULL)
ids3d( type = "shapes", subscene = NA, tags = FALSE )
}
\arguments{
  \item{type}{Select subtype(s):
    \describe{
      \item{"shapes"}{shape stack}
      \item{"lights"}{light stack}
      \item{"bboxdeco"}{bounding box}
      \item{"userviewpoint"}{user viewpoint}
      \item{"modelviewpoint"}{model viewpoint}
      \item{"material"}{material properties}
      \item{"background"}{scene background}
      \item{"subscene"}{subscene list}
      \item{"all"}{all of the above}
    }
  }
  \item{defaults}{default values to use after clearing}
  \item{subscene}{which subscene to work with.  \code{NA} means the current one, 
                  \code{0} means the whole scene}  
  \item{id}{vector of ID numbers of items to remove}
  \item{tag}{override \code{id} with objects matching
  these \code{tag} material properties}
  \item{tags}{logical; whether to return \code{tag} column.}
}
\details{
RGL holds several lists of objects in each scene. 
There are lists for shapes, lights, bounding box decorations, subscenes, etc.
\code{clear3d} clears the specified stack, or restores
the defaults for the bounding box (not visible) or viewpoint. 
With \code{id = 0} \code{pop3d} removes 
the last added node on the list (except for subscenes:  there it
removes the active subscene).  The \code{id} argument
may be used to specify arbitrary item(s) to remove; if \code{id != 0}, 
the \code{type} argument is ignored.

\code{clear3d} may also be used to clear material properties
back to their defaults.  

\code{clear3d} has an optional \code{defaults} argument, which defaults to 
\code{\link{r3dDefaults}}.  Only the \code{materials} component of this argument
is currently used by \code{clear3d}.

\code{ids3d} returns a dataframe containing the IDs in the currently active subscene
by default, or a specified subscene, or if \code{subscene = 0}, in the whole
rgl window along with an indicator of their type and if \code{tags = TRUE}, the
\code{tag} value for each.

Note that clearing the light stack leaves the scene in darkness; it should normally
be followed by a call to \code{\link{light3d}}.
}
\seealso{
\code{\link{rgl}},
\code{\link{bbox3d}},
\code{\link{light3d}},
\code{\link{open3d}} to open a new window.
}
\examples{
  x <- rnorm(100)
  y <- rnorm(100)
  z <- rnorm(100)
  p <- plot3d(x, y, z, type = 's', tag = "plot")
  ids3d()
  lines3d(x, y, z)
  ids3d(tags = TRUE)
  if (interactive() && !rgl.useNULL() && !in_pkgdown_example()) {
    readline("Hit enter to change spheres")
    pop3d(id = p["data"])
    spheres3d(x, y, z, col = "red", radius = 1/5)
    box3d()
  }
}
\keyword{dynamic}
