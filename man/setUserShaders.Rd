\name{setUserShaders}
\alias{setUserShaders}
\alias{getShaders}
\title{
Set user-defined shaders for RGL objects, or get
shaders.
}
\description{

\code{getShaders} gets a user defined shader (a program
written in GLSL for customized display of RGL objects), or
if it is not present, the automatically generated one.
The deprecated function \code{setUserShaders} sets 
user-defined shaders.  Currently it is 
only supported in WebGL displays, as the recommended
method is to set shaders as part of the material
properties.
}
\usage{
getShaders(id, scene = scene3d(minimal), minimal = TRUE,
           subscene = currentSubscene3d(),
           useJavascript = FALSE)
           
setUserShaders(ids, vertexShader = NULL, fragmentShader = NULL, 
               attributes = NULL, uniforms = NULL, textures = NULL,
               scene = scene3d(minimal), minimal = TRUE)
}
\arguments{
  \item{ids, id}{
Which objects should receive the shaders, or which object
should be queried?
}
  \item{vertexShader, fragmentShader}{
The vertex and fragment shader source code.  If \code{NULL}, the
automatically generated shader will be used instead.
}
  \item{attributes}{
A named list of \dQuote{attributes} to attach to each vertex.
}
  \item{uniforms}{
A named list of \dQuote{uniforms}.
}
  \item{textures}{
A named list of textures.
  }
  \item{scene}{
A \code{\link{scene3d}} object to work with if \code{useJavascript}
is \code{TRUE} or \code{NA}.
}
  \item{minimal}{
See \code{\link{scene3d}}.  
}
  \item{subscene}{
Which subscene contains the object?  Only used if  \code{useJavascript}
is \code{FALSE} or \code{NA}.
  }
  \item{useJavascript}{If \code{TRUE}, use the same Javascript
code as is used in objects produced by \code{\link{rglwidget}}.  
This requires the \pkg{V8} package.  If \code{FALSE}, use the
internal C++ code.  If \code{NA}, do both, and signal an error
if the results don't match.}
}
\details{
Modern versions of OpenGL work with \dQuote{shaders}, 
programs written to run on the graphics processor.  The
vertex shader does the calculations to move vertices and
set their intrinsic colours.  The fragment shader
computes how each pixel in the display will be shown,
taking into account lighting, material properties, etc.
(More precisely, it does the computation for each \dQuote{fragment}; a fragment is a pixel within an object to display.
There may be many objects at a particular location, and
each will result in a fragment calculation unless culled
by z-buffering or being discarded in some other way.)

There are several other types of shaders in modern OpenGL,
but currently \pkg{rgl} only uses these two.

Normally the code uses the default shaders stored in 
\code{system.file("shaders", package = "rgl")}.  
User shaders may be written
for testing new features, hand optimization, etc.
The defines used by the default shaders will also be prepended
to user shaders, which can use them for customization on
an object-by-object basis.

The names used for the \code{attributes}, \code{uniforms}
and \code{textures} should match names in the shaders
for corresponding variables.  (The texture names should be
names of \code{uniform sampler2D} variables.)
}
\value{
A modified version of the \code{scene}.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{rglwidget}} for display of the scene in WebGL.
}
\examples{

# For each triangle, set weights on the 3 vertices.
# This will be replicated to the appropriate size before
# drawing.
wts <- diag(3)

# This leaves out the centres of each face
vs <- "
  // User defined vertex shader
  attribute vec3 aPos;
  attribute vec4 aCol;
  uniform mat4 mvMatrix;
  uniform mat4 prMatrix;
  varying vec4 vCol;
  varying vec4 vPosition;
  attribute vec3 aNorm;
  uniform mat4 normMatrix;
  varying vec3 vNormal;
  attribute vec3 wts;
  varying vec3 vwts;
  void main(void) {
    vPosition = mvMatrix * vec4(aPos, 1.);
    gl_Position = prMatrix * vPosition;
    vCol = aCol;
    vNormal = normalize((normMatrix * vec4(aNorm, 1.)).xyz);
    vwts = wts;
  }
"  
fs <- "
  // user defined fragment shader
  #ifdef GL_ES
  precision highp float;
  #endif
  varying vec4 vCol; // carries alpha
  varying vec4 vPosition;
  varying vec3 vNormal;
  uniform mat4 mvMatrix;
  uniform vec3 emission;
  uniform float shininess;
  uniform vec3 ambient[NLIGHTS];
  uniform vec3 specular[NLIGHTS]; // light*material
  uniform vec3 diffuse[NLIGHTS];
  uniform vec3 lightDir[NLIGHTS];
  uniform bool viewpoint[NLIGHTS];
  uniform bool finite[NLIGHTS];
  varying vec3 vwts;
  uniform vec2 wtrange;
  void main(void) {
    float minwt = min(vwts.x, min(vwts.y, vwts.z));
    if (minwt < wtrange.x || minwt > wtrange.y) discard;
    vec3 eye = normalize(-vPosition.xyz);
    vec3 lightdir;
    vec4 colDiff;
    vec3 halfVec;
    vec4 lighteffect = vec4(emission, 0.);
    vec3 col;
    float nDotL;
    vec3 n = normalize(vNormal);
    n = -faceforward(n, n, eye);
    colDiff = vec4(vCol.rgb * diffuse[0], vCol.a);
    lightdir = lightDir[0];
    if (!viewpoint[0])
      lightdir = (mvMatrix * vec4(lightdir, 1.)).xyz;
    if (!finite[0]) {
      halfVec = normalize(lightdir + eye);
    } else {
      lightdir = normalize(lightdir - vPosition.xyz);
      halfVec = normalize(lightdir + eye);
    }
    col = ambient[0];
    nDotL = dot(n, lightdir);
    col = col + max(nDotL, 0.) * colDiff.rgb;
    col = col + pow(max(dot(halfVec, n), 0.), shininess) * specular[0];
    lighteffect = lighteffect + vec4(col, colDiff.a);
    gl_FragColor = lighteffect;
  }
"

open3d()
id <- shade3d(octahedron3d(), col = "red", 
              vertex_shader = vs, 
              fragment_shader = fs, 
              user_attributes = list(wts=wts),
              user_uniforms = list(wtrange = c(-0.01, 0.15))
)

if (interactive() || in_pkgdown_example())
  rglwidget()
}
