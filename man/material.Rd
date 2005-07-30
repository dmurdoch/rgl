\name{rgl.material}
\alias{rgl.material}
\alias{material3d}
\title{generic Appearance setup}
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
  size         = 1.0, 
  fog          = TRUE
)
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
    logical, specifying whether gourad shading (smooth) or flat shading should be used.
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
    numeric, specifying the line and point size.
  }
  \item{fog}{logical, specifying if fog effect should be applied on the corresponding shape}
}
\details{
  Only one side at a time can be culled.
}
\seealso{
\code{\link{rgl.primitive}},
\code{\link{rgl.bbox}},
\code{\link{rgl.bg}},
\code{\link{rgl.light}}
}
\keyword{dynamic}

