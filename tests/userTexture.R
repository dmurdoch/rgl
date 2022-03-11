library(rgl)
open3d()
set.seed(3)
 x <- cube3d(col="white", texture = system.file("textures/rgl2.png",
                                                package = "rgl"),
             texcoords = matrix(runif(16), ncol=2))
id <- shade3d(x)
# rglwidget()



vShader <- "
/* ****** quads object 13 vertex shader ****** */
  #ifdef GL_ES
  #ifdef GL_FRAGMENT_PRECISION_HIGH
  precision highp float;
#else
precision mediump float;
#endif
#endif
attribute vec3 aPos;
attribute vec4 aCol;
uniform mat4 mvMatrix;
uniform mat4 prMatrix;
varying vec4 vCol;
varying vec4 vPosition;
attribute vec3 aNorm;
uniform mat4 normMatrix;
varying vec4 vNormal;
attribute vec2 aTexcoord;
varying vec2 vTexcoord;
void main(void) {
  vPosition = mvMatrix * vec4(aPos, 1.);
  gl_Position = prMatrix * vPosition;
  vCol = aCol;
  vNormal = normMatrix * vec4(-aNorm, dot(aNorm, aPos));
  vNormal = vec4(normalize(vNormal.xyz/vNormal.w), 1);
  vTexcoord = aTexcoord;
}
"
fShader <- "
/* ****** quads object 13 fragment shader ****** */
  #ifdef GL_ES
  #ifdef GL_FRAGMENT_PRECISION_HIGH
  precision highp float;
#else
precision mediump float;
#endif
#endif
varying vec4 vCol; // carries alpha
varying vec4 vPosition;
varying vec2 vTexcoord;
uniform sampler2D uSampler;
uniform sampler2D userSampler;
uniform int uFogMode;
uniform vec3 uFogColor;
uniform vec4 uFogParms;
varying vec4 vNormal;
uniform mat4 mvMatrix;
uniform vec3 emission;
uniform float shininess;
uniform vec3 ambient0;
uniform vec3 specular0; // light*material
uniform vec3 diffuse0;
uniform vec3 lightDir0;
uniform bool viewpoint0;
uniform bool finite0;
void main(void) {
  vec4 fragColor;
  vec3 n = normalize(vNormal.xyz + texture2D(userSampler, vTexcoord).rgb);
  vec3 eye = normalize(-vPosition.xyz/vPosition.w);
  vec3 lightdir;
  vec4 colDiff;
  vec3 halfVec;
  vec4 lighteffect = vec4(emission, 0.);
  vec3 col;
  float nDotL;
  n = -faceforward(n, n, eye);
  colDiff = vec4(vCol.rgb * diffuse0, vCol.a);
  lightdir = lightDir0;
  if (!viewpoint0)
    lightdir = (mvMatrix * vec4(lightdir, 1.)).xyz;
  if (!finite0) {
    halfVec = normalize(lightdir + eye);
  } else {
    lightdir = normalize(lightdir - vPosition.xyz/vPosition.w);
    halfVec = normalize(lightdir + eye);
  }
  col = ambient0;
  nDotL = dot(n, lightdir);
  col = col + max(nDotL, 0.) * colDiff.rgb;
  col = col + pow(max(dot(halfVec, n), 0.), shininess) * specular0;
  lighteffect = lighteffect + vec4(col, colDiff.a);
  vec4 textureColor = lighteffect*vec4(1.,1.,1.,1.);
  fragColor = textureColor;
  float fogF;
  if (uFogMode > 0) {
    fogF = (uFogParms.y - vPosition.z/vPosition.w)/(uFogParms.y - uFogParms.x);
    if (uFogMode > 1)
      fogF = mix(uFogParms.w, 1.0, fogF);
    fogF = fogF*uFogParms.z;
    if (uFogMode == 2)
      fogF = 1.0 - exp(-fogF);
    else if (uFogMode == 3)
      fogF = 1.0 - exp(-fogF*fogF);
    fogF = clamp(fogF, 0.0, 1.0);
    gl_FragColor = vec4(mix(fragColor.rgb, uFogColor, fogF), fragColor.a);
  } else gl_FragColor = fragColor;
}
"

s <- setUserShaders(id, vertexShader = vShader,
                        fragmentShader = fShader,
               textures = c(userSampler = system.file("textures/rgl2.png",
                                      package = "rgl"),
                            unusedSampler = system.file("textures/rgl2.png",
                                                        package = "rgl")),
               uniforms = list(unusedUniform = 3),
               attributes = list(unusedAttribute = 1:10))
rglwidget(s)
