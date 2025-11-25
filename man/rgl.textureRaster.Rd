\name{rgl.textureRaster}
\alias{rgl.textureRaster}
\title{
Get Texture as Raster
}
\description{
If a texture has been set globally or for a particular
item, this function can be used to retrieve it as a
raster object.
}
\usage{
rgl.textureRaster(id = NULL)
}
\arguments{
  \item{id}{
The id of an object, or \code{NULL} for the default
material.
}
}
\details{
Textures are bitmaps that are displayed on surfaces
in OpenGL.  Currently \pkg{rgl} supports a single
texture per item.  This function retrieves the bitmap
being used as the texture.
}
\value{
A raster object holding the bitmap.
}
\examples{
id <- text3d(1:4, 1:4, 1:4, c("This is text.", "This too.", "And this.", "And this."), col=rainbow(4), cex=3)
plot(rgl.textureRaster(id))
}