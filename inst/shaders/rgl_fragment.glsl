#line 2 2
// File 2 is the fragment shader
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif
varying vec4 vCol; // carries alpha
varying vec4 vPosition;
#if defined(HAS_TEXTURE) || defined (IS_TEXT)
varying vec2 vTexcoord;
uniform sampler2D uSampler;
#endif

#ifdef HAS_FOG
uniform int uFogMode;
uniform vec3 uFogColor;
uniform vec4 uFogParms;
#endif

#if defined(IS_LIT) && !defined(FIXED_QUADS)
varying vec4 vNormal;
#endif

#if NCLIPPLANES > 0
uniform vec4 vClipplane[NCLIPPLANES];
#endif

#if NLIGHTS > 0
uniform mat4 mvMatrix;
#endif

#ifdef IS_LIT
uniform vec3 emission;
uniform float shininess;
#if NLIGHTS > 0
uniform vec3 ambient[NLIGHTS];
uniform vec3 specular[NLIGHTS]; // light*material
uniform vec3 diffuse[NLIGHTS];
uniform vec3 lightDir[NLIGHTS];
uniform bool viewpoint[NLIGHTS];
uniform bool finite[NLIGHTS];
#endif
#endif // IS_LIT

#ifdef IS_TWOSIDED
uniform bool front;
varying float normz;
#endif

#ifdef FAT_LINES
varying vec2 vPoint;
varying float vLength;
#endif

#ifdef USE_ENVMAP
varying vec3 vReflection;
#endif

void main(void) {
  vec4 fragColor;
#ifdef FAT_LINES
  vec2 point = vPoint;
  bool neg = point.y < 0.0;
  point.y = neg ? (point.y + vLength)/(1.0 - vLength) :
                 -(point.y - vLength)/(1.0 - vLength);
#if defined(IS_TRANSPARENT) && defined(IS_LINESTRIP)
  if (neg && length(point) <= 1.0) discard;
#endif
  point.y = min(point.y, 0.0);
  if (length(point) > 1.0) discard;
#endif // FAT_LINES
  
#ifdef ROUND_POINTS
  vec2 coord = gl_PointCoord - vec2(0.5);
  if (length(coord) > 0.5) discard;
#endif
  
#if NCLIPPLANES > 0
  for (int i = 0; i < NCLIPPLANES; i++)
    if (dot(vPosition, vClipplane[i]) < 0.0) discard;
#endif
    
#ifdef FIXED_QUADS
    vec3 n = vec3(0., 0., 1.);
#elif defined(IS_LIT)
    vec3 n = normalize(vNormal.xyz);
#endif
    
#ifdef IS_TWOSIDED
    if ((normz <= 0.) != front) discard;
#endif

#ifdef IS_LIT
    vec3 eye = normalize(-vPosition.xyz/vPosition.w);
    vec3 lightdir;
    vec4 colDiff;
    vec3 halfVec;
    vec4 lighteffect = vec4(emission, 0.);
    vec3 col;
    float nDotL;
#ifdef FIXED_QUADS
    n = -faceforward(n, n, eye);
#endif
    
#if NLIGHTS > 0
    // Simulate two-sided lighting
    if (n.z < 0.0)
      n = -n;
    for (int i=0;i<NLIGHTS;i++) {
      colDiff = vec4(vCol.rgb * diffuse[i], vCol.a);
      lightdir = lightDir[i];
      if (!viewpoint[i]) {
        if (finite[i]) {
          lightdir = (mvMatrix * vec4(lightdir, 1.)).xyz;
        } else {
          lightdir = (mvMatrix * vec4(lightdir, 0.)).xyz;
        }
      }
      if (!finite[i]) {
        halfVec = normalize(lightdir + eye);
      } else {
        lightdir = normalize(lightdir - vPosition.xyz/vPosition.w);
        halfVec = normalize(lightdir + eye);
      }
      col = ambient[i];
      nDotL = dot(n, lightdir);
      col = col + max(nDotL, 0.) * colDiff.rgb;
      col = col + pow(max(dot(halfVec, n), 0.), shininess) * specular[i];
      lighteffect = lighteffect + vec4(col, colDiff.a);
    }
#endif
    
#else // not IS_LIT
    vec4 colDiff = vCol;
    vec4 lighteffect = colDiff;
#endif
    
#ifdef IS_TEXT
    vec4 textureColor = lighteffect*texture2D(uSampler, vTexcoord);
#endif
    
#ifdef HAS_TEXTURE

// These calculations use the definitions from 
// https://docs.gl/gl3/glTexEnv

#ifdef USE_ENVMAP
    float m = 2.0 * sqrt(dot(vReflection, vReflection) + 2.0*vReflection.z + 1.0);
    vec4 textureColor = texture2D(uSampler, vReflection.xy / m + vec2(0.5, 0.5));
#else
    vec4 textureColor = texture2D(uSampler, vTexcoord);
#endif

#ifdef TEXTURE_rgb

#if defined(TEXMODE_replace) || defined(TEXMODE_decal)
    textureColor = vec4(textureColor.rgb, lighteffect.a);
#endif 

#ifdef TEXMODE_modulate
    textureColor = lighteffect*vec4(textureColor.rgb, 1.);
#endif

#ifdef TEXMODE_blend
    textureColor = vec4((1. - textureColor.rgb) * lighteffect.rgb, lighteffect.a);
#endif

#ifdef TEXMODE_add
    textureColor = vec4(lighteffect.rgb + textureColor.rgb, lighteffect.a);
#endif

#endif //TEXTURE_rgb
        
#ifdef TEXTURE_rgba

#ifdef TEXMODE_replace
// already done
#endif 

#ifdef TEXMODE_modulate
    textureColor = lighteffect*textureColor;
#endif

#ifdef TEXMODE_decal
    textureColor = vec4((1. - textureColor.a)*lighteffect.rgb) +
                     textureColor.a*textureColor.rgb, 
                     lighteffect.a);
#endif

#ifdef TEXMODE_blend
    textureColor = vec4((1. - textureColor.rgb) * lighteffect.rgb,
                    lighteffect.a*textureColor.a);
#endif

#ifdef TEXMODE_add
    textureColor = vec4(lighteffect.rgb + textureColor.rgb,
                    lighteffect.a*textureColor.a);
#endif
    
#endif //TEXTURE_rgba
    
#ifdef TEXTURE_alpha
    float luminance = textureColor.r;

#if defined(TEXMODE_replace) || defined(TEXMODE_decal)
    textureColor = vec4(lighteffect.rgb, luminance);
#endif 

#if defined(TEXMODE_modulate) || defined(TEXMODE_blend) || defined(TEXMODE_add)
    textureColor = vec4(lighteffect.rgb, lighteffect.a*luminance);
#endif
 
#endif // TEXTURE_alpha
    
// The TEXTURE_luminance values are not from that reference    
#ifdef TEXTURE_luminance
    float luminance = textureColor.r;

#if defined(TEXMODE_replace) || defined(TEXMODE_decal)
    textureColor = vec4(luminance, luminance, luminance, lighteffect.a);
#endif 

#ifdef TEXMODE_modulate
    textureColor = vec4(luminance*lighteffect.rgb, lighteffect.a);
#endif

#ifdef TEXMODE_blend
    textureColor = vec4((1. - luminance)*lighteffect.rgb,
                        lighteffect.a);
#endif

#ifdef TEXMODE_add
    textureColor = vec4(luminance + lighteffect.rgb, lighteffect.a);
#endif

#endif // TEXTURE_luminance
 
    
#ifdef TEXTURE_luminance_alpha
    float luminance = dot(vec3(1.,1.,1.),textureColor.rgb)/3.;

#if defined(TEXMODE_replace) || defined(TEXMODE_decal)
    textureColor = vec4(luminance, luminance, luminance, textureColor.a);
#endif 

#ifdef TEXMODE_modulate
    textureColor = vec4(luminance*lighteffect.rgb, 
                        textureColor.a*lighteffect.a);
#endif

#ifdef TEXMODE_blend
    textureColor = vec4((1. - luminance)*lighteffect.rgb,
                        textureColor.a*lighteffect.a);
#endif

#ifdef TEXMODE_add
    textureColor = vec4(luminance + lighteffect.rgb, 
                        textureColor.a*lighteffect.a);

#endif

#endif // TEXTURE_luminance_alpha
    
    fragColor = textureColor;

#elif defined(IS_TEXT)
    if (textureColor.a < 0.1)
      discard;
    else
      fragColor = textureColor;
#else
    fragColor = lighteffect;
#endif // HAS_TEXTURE
    
#ifdef HAS_FOG
    // uFogParms elements: x = near, y = far, z = fogscale, w = (1-sin(FOV/2))/(1+sin(FOV/2))
    // In Exp and Exp2: use density = density/far
    // fogF will be the proportion of fog
    // Initialize it to the linear value
    float fogF;
    if (uFogMode > 0) {
      fogF = (uFogParms.y - vPosition.z/vPosition.w)/(uFogParms.y - uFogParms.x);
      if (uFogMode > 1)
        fogF = mix(uFogParms.w, 1.0, fogF);
      fogF = fogF*uFogParms.z;
      if (uFogMode == 2)
        fogF = 1.0 - exp(-fogF);
      // Docs are wrong: use (density*c)^2, not density*c^2
      // https://gitlab.freedesktop.org/mesa/mesa/-/blob/master/src/mesa/swrast/s_fog.c#L58
      else if (uFogMode == 3)
        fogF = 1.0 - exp(-fogF*fogF);
      fogF = clamp(fogF, 0.0, 1.0);
      gl_FragColor = vec4(mix(fragColor.rgb, uFogColor, fogF), fragColor.a);
    } else gl_FragColor = fragColor;
#else
    gl_FragColor = fragColor;
#endif // HAS_FOG
    
}
