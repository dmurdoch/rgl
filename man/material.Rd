\name{rgl.material}
\alias{rgl.material}
\alias{material3d}
\title{Set material properties}
\description{
  Set material properties for geometry appearance.
}
\usage{
rgl.material(
  color        = "white",
  alpha        = 1.0,
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
  front        = "filled", 
  back         = "filled",
  size         = 3.0, 
  lwd          = 1.0,
  fog          = TRUE,
  point_antialias = FALSE,
  line_antialias = FALSE,
  depth_mask   = TRUE,
  depth_test   = "less",
  polygon_offset = c(0.0, 0.0),
  margin       = "",
  floating     = FALSE,
  tag          = "",
  blend        = c("src_alpha", "one_minus_src_alpha"),
  col,
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
      \item{"filled"}{filled polygon}
      \item{"lines"}{wireframed polygon}
      \item{"points"}{point polygon}
      \item{"culled"}{culled (hidden) polygon}
    }
  }
  \item{size}{ 
    numeric, specifying the size of points in pixels
  }
  \item{lwd}{
    numeric, specifying the line width in pixels
  }
  \item{fog}{logical, specifying if fog effect should be applied on the corresponding shape.  Fog type is set in \code{\link{bg3d}}.}
  \item{point_antialias, line_antialias}{logical, specifying if points should be round and lines 
     should be antialiased, but see Note below.}
  \item{depth_mask}{logical, specifying whether the object's depth
     should be stored.}
  \item{depth_test}{Determines which depth test is used to see if this
     object is visible, depending on its apparent depth in the scene
     compared to the stored depth. Possible values are \code{"never"},
     \code{"less"} (the default), \code{"equal"}, \code{"lequal"}
     (less than or equal), \code{"greater"}, \code{"notequal"},
     \code{"gequal"} (greater than or equal), \code{"always"}.}
  \item{polygon_offset}{If non-zero, offsets are added
  to the recorded depth of filled polygons.  See Details below.}
  \item{margin, floating}{Used mainly for text to
  draw annotations in the margins, but supported by
  most kinds of objects:  see \code{\link{mtext3d}}.}
  \item{tag}{A length 1 string value.  These
  may be used to identify objects, or encode other meta
  data about the object.}
  \item{blend}{Two string values from the list below
  describing how transparent objects are blended with
  colors behind them.
  The first determines the coefficient applied to the 
  color of the current object (the source); the second determines
  the coefficient applied to the existing color 
  (the destination). The resulting
  color will be the sum of the two resulting colors.
  The allowed strings
  correspond to OpenGL constants:
  \describe{
  \item{"zero"}{Zero; color has no effect.}
  \item{"one"}{One; color is added to the other term.}
  \item{"src_color", "one_minus_src_color"}{Multiply by source color or its opposite.}
  \item{"dst_color", "one_minus_dst_color"}{Multiply by destination color or its opposite.}
  \item{"src_alpha", "one_minus_src_alpha"}{Multiply by
source alpha or its opposite.  Default values.}
  \item{"dst_alpha", "one_minus_dst_alpha"}{Multiply by
destination alpha or its opposite.}
  \item{"constant_color", "one_minus_constant_color",
  "constant_alpha", "one_minus_constant_alpha",
  "src_alpha_saturate"}{These are allowed, but to be useful
  they require other settings which \pkg{rgl} doesn't
  support.}
  }
  }
  \item{col}{An allowed abbreviation of \code{color}.}
  \item{...}{Any of the arguments above can
  be passed to \code{material3d}; see Details below.  \code{rgl.material} will ignore others.}
}
\details{
  Values can be queried by specifying their names
in a character vector, e.g. \code{material3d("color")}.
There is one read-only property that can be queried
but not set:

\describe{
\item{isTransparent}{Is the current color transparent?}
}
  
  Only one side at a time can be culled.
  
  Object display colors are determined as follows:
\itemize{
\item{If \code{lit = FALSE}, an element of the \code{color} vector property is displayed without modification.  See documentation for individual objects for information on which element is chosen.}
\item{If \code{lit = TRUE}, the color is determined as follows.}
\enumerate{
\item{The color is set to the \code{emission} property
of the object. }
\item{For each defined light, the following are added:
\itemize{
\item{the product of the \code{ambient} color
of the light and the \code{ambient} color of the object is added.}
\item{the \code{color} of the
object is multiplied by the \code{diffuse} color
of the light and by a constant depending on
the angle between the surface and the direction to 
the light, and added.}
\item{the \code{specular} color of the object
is multiplied by the \code{specular} color of the 
light and a constant depending on the \code{shininess}
of the object and the direction to the light, and
added.  The \code{shininess} property mainly
determines the size of the shiny highlight; adjust
one or both of the \code{specular} colors to change
its brightness.}
}

}
}
}
  
  The \code{polygon_offset} property is a two element
vector giving the \samp{factor} and \samp{units} values
to use in a \code{glPolygonOffset()} call in OpenGL.  If
only one value is given, it is used for both elements.
The \samp{units} value is added to the depth of all pixels in
a filled polygon,
and the \samp{factor} value is multiplied by an estimate of
the slope of the polygon and then added to the depth.  Positive values \dQuote{push} polygons back slightly for the purpose
of depth testing, to allow points, lines or other polygons
to be drawn on the surface without being obscured due 
to rounding error.  Negative values pull the object forward.
A typical value to use is \code{1} (which
is automatically expanded to \code{c(1,1)}).
If values are too large, objects which should be behind
the polygon will show through, and if values are too small,
the objects on the surface will be partially obscured. 
Experimentation may be needed to get it right.  The first
example in \code{?\link{persp3d}} uses this property to add 
grid lines to a surface.
  
  \code{material3d} is an alternate interface to the material properties, modelled after
\code{\link{par3d}}:  rather than setting defaults for parameters that are not specified, 
they will be left unchanged.  \code{material3d} may also be used to query the material
properties; see the examples below.

  The current implementation does not return parameters for textures.

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
\note{
  If \code{point_antialias} is \code{TRUE}, points will be drawn as circles in WebGL; otherwise, they
will be drawn as squares.  Within R, the behaviour depends
on your graphics hardware:  for example, I see circles for 
both settings on my laptop.

Within R, lines tend to appear heavier with \code{line_antialias == TRUE}.  There's no difference at all
in WebGL.
}
\seealso{
\code{\link{rgl.primitive}},
\code{\link{rgl.bbox}},
\code{\link{rgl.bg}},
\code{\link{rgl.light}}
}
\examples{
save <- material3d("color")
material3d(color = "red")
material3d("color")
material3d(color = save)

# this illustrates the effect of depth_test
x <- c(1:3); xmid <- mean(x)
y <- c(2, 1, 3); ymid <- mean(y)
z <- 1
open3d()
tests <- c("never", "less", "equal", "lequal", "greater", 
                  "notequal", "gequal", "always")
for (i in 1:8) {
  triangles3d(x, y, z + i, col = heat.colors(8)[i])
  texts3d(xmid, ymid, z + i, paste(i, tests[i], sep = ". "), depth_test = tests[i]) 
}
highlevel()  # To trigger display

# this illustrates additive blending
open3d()
bg3d("darkgray")
quad <- cbind(c(-1, 1, 1, -1), 1, c(-1, -1, 1, 1))
quads3d(rbind(quad, 2*quad, 3*quad ), 
        col = rep(c("red", "green", "blue"), each = 4),
        alpha = 0.5, 
        blend = c("src_alpha", "one"))
}
\keyword{dynamic}

