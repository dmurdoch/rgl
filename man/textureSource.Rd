\name{textureSource}
\alias{textureSource}
\title{
Retrieve source code used to produce texture file.
}
\description{
Internally, \pkg{rgl} mainly works with PNG files for textures.
If a texture is requested using a different format, a temporary
PNG file of the image will be saved.  This function allows
you to retrieve the original expression used to produce
the texture.

Note that some textures have no corresponding PNG file.
For those, use \code{\link{rgl.textureRaster}}.
}
\usage{
textureSource(texture)
}
\arguments{
  \item{texture}{
The filename of a texture file.  If missing, the directory
where texture files are stored will be returned.
}
}
\details{
\pkg{rgl} creates a new file in the temporary directory
whenever a non-PNG texture is used.  It will delete them
when it knows there are no references and 
at the end of the session, but conceivably there will be 
situations where you need to delete them earlier.  Calling
\code{textureSource()} with no arguments will give
you the directory holding the textures so that they can
be deleted sooner.
}
\value{
If \code{texture} is specified and it is the name of a 
temporary PNG texture file produced by \pkg{rgl}, the 
expression used to specify the texture will be returned.  
If it is the name of some other file, \code{texture} will
be returned.

If no argument is given, the session-specific directory
holding the temporary texture files will be returned.
}

\seealso{
\code{\link{material3d}}
}
\examples{
xyz <- cbind(c(0,1,1,0), c(0,0,1,1), c(0,0,0,0))
st <- xyz[,1:2]

open3d()
id <- quads3d(xyz, texcoords = st, 
               texture = as.raster(matrix(colors()[1:120], ncol = 10)), 
               col="white")
material3d(id = id, "texture")
textureSource(material3d(id = id, "texture"))
}