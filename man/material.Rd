\name{material3d}
\alias{material3d}
\alias{rgl.material.names}
\alias{rgl.material.readonly}
\concept{color}
\concept{lit}
\concept{ambient}
\concept{specular}
\concept{emission}
\concept{shininess}
\concept{alpha}
\concept{smooth}
\concept{texture}
\concept{textype}
\concept{texmode}
\concept{texmipmap}
\concept{texmagfilter}
\concept{texminfilter}
\concept{texenvmap}
\concept{front}
\concept{back}
\concept{size}
\concept{lwd}
\concept{fog}
\concept{point_antialias}
\concept{line_antialias}
\concept{depth_mask}
\concept{depth_test}
\concept{polygon_offset}
\concept{margin}
\concept{floating}
\concept{tag}
\concept{blend}
\concept{isTransparent}
\concept{rgl.warnBlackTexture}

\title{Get or set material properties}
\description{
  Get or set material properties for geometry appearance.
}
\usage{
material3d(..., id = NULL)

rgl.material.names
rgl.material.readonly
}
\arguments{
  \item{...}{Material properties to set or query.}
  \item{id}{
  the \pkg{rgl} id of an object to query, or \code{NULL}
  to query or set the defaults.
  }
}
\details{
In an \pkg{rgl} scene, each object has \dQuote{material properties} that control how it is rendered and (in the case of \code{tag}) 
that can be used to store a 
label or other information.  \code{material3d} sets defaults
for these properties and queries the defaults or specific
values for an individual object.

To set values, use \code{name = value} settings, e.g.
\code{material3d(color = "red")}.  To query values, 
specify the property or properties in a character vector,
e.g. \code{material3d("color")}.  

  Only one side at a time can be culled.

  The \code{material} member of the \code{\link{r3dDefaults}} list may be used to 
set default values for material properties.
  
}

\section{Material Properties}{

The \code{rgl.material.names} variable contains the
full list of material names.
The following read-write material properties control
the appearance
of objects in an \pkg{rgl} scene.

\describe{

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
    vector of alpha values between 0.0 (fully transparent) and 1.0 (opaque).  See \HTMLVignette{transparency}{}{A Note on Transparency} 
for a discussion of some issues with transparency.
  }
  \item{smooth}{
    logical, specifying whether smooth shading or flat shading
    should be used.  For smooth shading, Gouraud shading is
    used in \pkg{rgl} windows, while Phong shading is used 
    in WebGL.
  }
  \item{texture}{ 
    path to a texture image file. See the Textures section
    below for details.
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
    Note that support for these modes is slightly different
in the display within R versus the WebGL display using
\code{rglwidget()}.  In particular, in WebGL 
\code{textype = "alpha"} will always take the alpha value from
the luminance (i.e. the average of the R, G and B channels) 
of the texture, whereas the R display bases
the choice on the internal format of the texture file.
  }
  \item{texmode}{
    specifies how the texture interacts with the existing
    color
    \describe{
      \item{"replace"}{texture value replaces existing value}
      \item{"modulate"}{default; texture value multiplies existing value}
      \item{"decal"}{for \code{textype = "rgba"}, texture
      is mixed with existing value}
      \item{"blend"}{uses the texture to blend the existing
      value with black}
      \item{"add"}{adds the texture value to the existing.
      May not be available in the R display with very old
      OpenGL drivers.}
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
  \item{polygon_offset}{A one or two element
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
grid lines to a surface.}
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
}

The \code{rgl.material.readonly} variable contains
the subset of material properties that are read-only
so they can be queried
but not set.
Currently there is only one:

\describe{
\item{isTransparent}{Is the current color transparent?}
}

}
\value{
\code{material3d()} returns values similarly
to \code{\link{par3d}}:
When setting properties, it returns the previous values
invisibly in a named list.  When querying multiple values, a
named list is returned. When a single value is queried it is
returned directly.
} 
\section{Textures}{
The \code{texture} material property may be \code{NULL} or the name of
a bitmap file to be displayed on the surface being rendered.
Currently only PNG format files are supported.

By default, the colors in the bitmap will modify the color of the
object being plotted.  If the color is black (a common default), you
won't see anything, so a warning may be issued.  You can
suppress the warning by specifying 
the color explicitly, or calling
\code{options{rgl.warnBlackTexture = FALSE}}.

Other aspects of texture display are controlled by the material
properties \code{textype, texmode, texmipmap, texmagfilter,
texminfilter} and \code{texenvmap} described above.

For an extensive discussion of textures, see the 
\HTMLVignette{rgl}{textures}{Textures} section of the 
\HTMLVignette{rgl}{}{rgl Overview}
vignette.
}
\section{Display of objects}{
  
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
  If \code{point_antialias} is \code{TRUE}, points will be drawn as circles in WebGL; otherwise, they
will be drawn as squares.  Within R, the behaviour depends
on your graphics hardware:  for example, I see circles for 
both settings on my laptop.

Within R, lines tend to appear heavier with \code{line_antialias == TRUE}.  There's no difference at all
in WebGL.
}
\seealso{
\code{\link{bbox3d}},
\code{\link{bg3d}},
\code{\link{light3d}}
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
quads3d(rbind(translate3d(quad, -0.5, 0, -0.5),
              translate3d(quad, 0.5,  0.5, -0.5),
              translate3d(quad, 0, 1, 0.5)), 
        col = rep(c("red", "green", "blue"), each = 4),
        alpha = 0.5, 
        blend = c("src_alpha", "one"))
}
\keyword{dynamic}
