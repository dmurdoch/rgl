\name{textureSource}
\alias{textureSource}
\title{
Retrieve source code used to produce texture file.
}
\description{
This function is deprecated.

Previous versions of \pkg{rgl} mainly worked with PNG files for textures.
If a texture was requested using a different format, a temporary
PNG file of the image was saved.  This function allows
you to retrieve the original expression used to produce
the texture in that case.

Note that in this version of \pkg{rgl} such textures have
no corresponding PNG file.
Use \code{\link{rgl.textureRaster}} instead.
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
temporary PNG texture file produced by an older version of 
\pkg{rgl}, the 
expression used to specify the texture will be returned.  
If it is the name of some other file, \code{texture} will
be returned.

If no argument is given, the session-specific directory
holding the temporary texture files will be returned.
}

\seealso{
\code{\link{material3d}}
}
