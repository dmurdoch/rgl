\name{rgl.material}
\alias{rgl.material}
\title{generic Appearance setup}
\description{
  Set material properties for geometry appearance.
}
\usage{
rgl.material(
  color = "white",  alpha = 1.0,
  lit = TRUE, ambient = "black",  specular="white", emission = "black", shininess = 50.0, 
  smooth = TRUE,  texture = NULL, textype = "rgb",
  front = "fill", back = "fill",
  size = 1.0, fog = TRUE
)
}
\arguments{
  \item{color}{
    vector of R color character vectors. Represents the diffuse component in case of lighting calculation (lit = TRUE),
    otherwise it describes the solid color characteristics.
  }
  \item{lit}{
    logical, specifying if lighting calculation should take place on geometry
  }
  \item{ambient, specular, emission, shininess}{
    properties for lighting calculation. ambient, specular, emission are R color character string values, shininess represents a
    numerical.
  }
  \item{alpha}{ 
    vector of alpha values between 0.0 (full transparency) .. 1.0 (opaque).
  }
  \item{smooth}{
    logical, specifying whether gourad shading(smooth) or flat shading should be used
  }
  \item{texture}{ 
    path to a texture image file (currently 256 x 256 is a must!) Supported formats: png.
  }
  \item{textype}{
    specifies the texture type:
    \itemize{
      \item \"alpha\"           alpha texture
      \item \"luminance\"       luminance texture
      \item \"luminance.alpha\" luminance/alpha texture
      \item \"rgb\"             color texture
      \item \"rgba\"            color/alpha texture
    }
  }
  \item{front, back}{
    Specifies the polygon mode for the specified side:
    \itemize{
      \item \"fill\" fill polygon
      \item \"line\" wireframe polygon
      \item \"points\" point polygon
      \item \"cull\" cull (hide) polygon
    }
  }
  \item{size}{ 
    numeric, specifying the line and point size.
  }
  \item{fog}{logical, specifying if fog effect should take place on associated shape}
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
