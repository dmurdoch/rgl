#line 2 1
// File 1 is the vertex shader
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

#ifdef needs_vnormal
attribute vec3 aNorm;
uniform mat4 normMatrix;
varying vec4 vNormal;
#endif

#if defined(has_texture) || defined (is_text)
attribute vec2 aTexcoord;
varying vec2 vTexcoord;
#endif

#ifdef fixed_size
uniform vec3 textScale;
#endif

#ifdef fixed_quads
attribute vec3 aOfs;
#endif

#ifdef is_twosided
#ifdef has_normals
/* normz should be calculated *after* projection */
normz = (invPrMatrix*vNormal).z;
#else
vec4 pos1 = prMatrix*(mvMatrix*vec4(aPos1, 1.));
pos1 = pos1/pos1.w - gl_Position/gl_Position.w;
vec4 pos2 = prMatrix*(mvMatrix*vec4(aPos2, 1.));
pos2 = pos2/pos2.w - gl_Position/gl_Position.w;
normz = pos1.x*pos2.y - pos1.y*pos2.x;
#endif
#endif

#ifdef fat_lines
attribute vec3 aNext;
attribute vec2 aPoint;
varying vec2 vPoint;
varying float vLength;
uniform float uAspect;
uniform float uLwd;
#endif


void main(void) {
  
#ifndef is_brush
#if defined(nclipplanes) || !defined(fixed_quads) || defined(has_fog)
  vPosition = mvMatrix * vec4(aPos, 1.);
#endif
  
#ifndef fixed_quads
  gl_Position = prMatrix * vPosition;
#endif
#endif // !is_brush
  
#ifdef is_points
  gl_PointSize = POINTSIZE;
#endif
  
  vCol = aCol;
  
#ifdef needs_vnormal
  vNormal = normMatrix * vec4(-aNorm, dot(aNorm, aPos));
#endif
  
#ifdef is_twosided
#ifdef has_normals
  /* normz should be calculated *after* projection */
  normz = (invPrMatrix*vNormal).z;
#else
  vec4 pos1 = prMatrix*(mvMatrix*vec4(aPos1, 1.));
  pos1 = pos1/pos1.w - gl_Position/gl_Position.w;
  vec4 pos2 = prMatrix*(mvMatrix*vec4(aPos2, 1.));
  pos2 = pos2/pos2.w - gl_Position/gl_Position.w;
  normz = pos1.x*pos2.y - pos1.y*pos2.x;
#endif
#endif // is_twosided
  
#ifdef needs_vnormal
  vNormal = vec4(normalize(vNormal.xyz/vNormal.w), 1);
#endif
  
#if defined(has_texture) || defined(is_text)
  vTexcoord = aTexcoord;
#endif
  
#if defined(fixed_size) && !defined(rotating)
  vec4 pos = prMatrix * mvMatrix * vec4(aPos, 1.);
  pos = pos/pos.w;
  gl_Position = pos + vec4(aOfs*textScale, 0.);
#endif
  
#if defined(is_sprites) && !defined(fixed_size)
  vec4 pos = mvMatrix * vec4(aPos, 1.);
  pos = pos/pos.w + vec4(aOfs,  0.);
  gl_Position = prMatrix*pos;
#endif
  
#ifdef fat_lines
  /* This code was inspired by Matt Deslauriers' code in 
   https://mattdesl.svbtle.com/drawing-lines-is-hard */
  vec2 aspectVec = vec2(uAspect, 1.0);
  mat4 projViewModel = prMatrix * mvMatrix;
  vec4 currentProjected = projViewModel * vec4(aPos, 1.0);
  currentProjected = currentProjected/currentProjected.w;
  vec4 nextProjected = projViewModel * vec4(aNext, 1.0);
  vec2 currentScreen = currentProjected.xy * aspectVec;
  vec2 nextScreen = (nextProjected.xy / nextProjected.w) * aspectVec;
  float len = uLwd;
  vec2 dir = vec2(1.0, 0.0);
  vPoint = aPoint;
  vLength = length(nextScreen - currentScreen)/2.0;
  vLength = vLength/(vLength + len);
  if (vLength > 0.0) {
    dir = normalize(nextScreen - currentScreen);
  }
  vec2 normal = vec2(-dir.y, dir.x);
  dir.x /= uAspect;
  normal.x /= uAspect;
  vec4 offset = vec4(len*(normal*aPoint.x*aPoint.y - dir), 0.0, 0.0);
  gl_Position = currentProjected + offset;
#endif
  
#ifdef is_brush
  gl_Position = vec4(aPos, 1.);
#endif
}
