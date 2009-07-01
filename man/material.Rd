\name{rgl.material}
\alias{rgl.material}
\alias{material3d}
\title{Generic Appearance setup}
\description{
  Set material properties for geometry appearance.
}
\usage{
rgl.material(
  color        = c("white"),
  alpha        = c(1.0),
  lit          = TRUE, 
  ambient      = "black",
  specular     = "white", 
  emission     = "black", 
  shininess    = 50.0, 
  smooth       = TRUE,
  texture      = NULL, 
  textype      = "rgb", 
  texmipmap    = FALSE, 
  texminfilter = "linear", 
  texmagfilter = "linear",
  texenvmap    = FALSE,
  front        = "fill", 
  back         = "fill",
  size         = 3.0, 
  lwd          = 1.0,
  fog          = TRUE,
  point_antialias = FALSE,
  line_antialias = FALSE,
  ...
)
material3d(...)
}
\arguments{
  \item{color}{
    vector of R color characters. Represents the diffuse component in case of lighting calculation (lit = TRUE),
    otherwise it describes the solid color characteristics.
  }
  \item{lit}{
    logical, specifying if lighting calculation should take place on geometry
  }
  \item{ambient, specular, emission, shininess}{
    properties for lighting calculation. ambient, specular, emission are R color character string values; shininess represents a
    numerical.
  }
  \item{alpha}{ 
    vector of alpha values between 0.0 (fully transparent) .. 1.0 (opaque).
  }
  \item{smooth}{
    logical, specifying whether Gouraud shading (smooth) or flat shading should be used.
  }
  \item{texture}{ 
    path to a texture image file. Supported formats: png.
  }
  \item{textype}{
    specifies what is defined with the pixmap
    \describe{
      \item{"alpha"}{alpha values}
      \item{"luminance"}{luminance}
      \item{"luminance.alpha"}{luminance and alpha}
      \item{"rgb"}{color}
      \item{"rgba"}{color and alpha texture}
    }
  }
  \item{texmipmap}{
    Logical, specifies if the texture should be mipmapped.
  }
  \item{texmagfilter}{
    specifies the magnification filtering type (sorted by ascending quality):
    \describe{
      \item{"nearest"}{texel nearest to the center of the pixel}
      \item{"linear"}{weighted linear average of a 2x2 array of texels}
    }
  }
  \item{texminfilter}{
    specifies the minification filtering type (sorted by ascending quality):
    \describe{
      \item{"nearest"}{texel nearest to the center of the pixel}
      \item{"linear"}{weighted linear average of a 2x2 array of texels}
      \item{"nearest.mipmap.nearest"}{low quality mipmapping}
      \item{"nearest.mipmap.linear"}{medium quality mipmapping}
      \item{"linear.mipmap.nearest"}{medium quality mipmapping}
      \item{"linear.mipmap.linear"}{high quality mipmapping}
    }
  }
  \item{texenvmap}{
    logical, specifies if auto-generated texture coordinates for environment-mapping 
    should be performed on geometry.
  }
  \item{front, back}{
    Determines the polygon mode for the specified side:
    \describe{
      \item{"fill"}{filled polygon}
      \item{"line"}{wireframed polygon}
      \item{"points"}{point polygon}
      \item{"cull"}{culled (hidden) polygon}
    }
  }
  \item{size}{ 
    numeric, specifying the size of points in pixels
  }
  \item{lwd}{
    numeric, specifying the line width in pixels
  }
  \item{fog}{logical, specifying if fog effect should be applied on the corresponding shape}
  \item{point_antialias, line_antialias}{logical, specifying if points and lines 
     should be antialiased}
  \item{...}{Any of the arguments above; see Details below.}
}
\details{
  Only one side at a time can be culled.
  
  \code{material3d} is an alternate interface to the material properties, modelled after
\code{\link{par3d}}:  rather than setting defaults for parameters that are not specified, 
they will be left unchanged.  \code{material3d} may also be used to query the material
properties; see the examples below.

  The current implementation does not return parameters for textures.
  
  If \code{point_antialias} is \code{TRUE}, points will be drawn as circles; otherwise, they
will be drawn as squares.  Lines tend to appear heavier with \code{line_antialias==TRUE}.

  The \code{material} member of the \code{\link{r3dDefaults}} list may be used to 
set default values for material properties.
  
  The \code{...} parameter to \code{rgl.material} is ignored.
}
\value{
\code{rgl.material()} is called for the side effect of setting the material properties.
It returns a value invisibly which is not intended for use by the user.

Users should use \code{material3d()} to query material properties.  It returns values similarly
to \code{\link{par3d}} as follows:
When setting properties, it returns the previous values in a named list.  A named list is also
returned when more than one value is queried.  When a single value is queried it is returned 
directly.
} 
\seealso{
\code{\link{rgl.primitive}},
\code{\link{rgl.bbox}},
\code{\link{rgl.bg}},
\code{\link{rgl.light}}
}
\examples{
save <- material3d("color")
material3d(color="red")
material3d("color")
material3d(color=save)
}
\keyword{dynamic}

