
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif
varying vec4 vCol; // carries alpha
varying vec4 vPosition;
#ifdef texture_or_text
varying vec2 vTexcoord;
uniform sampler2D uSampler;
#endif

#ifdef has_fog
uniform int uFogMode;
uniform vec3 uFogColor;
uniform vec4 uFogParms;
#endif

#ifdef lit_and_not_fixed
varying vec4 vNormal;
#endif

#if NCLIPPLANES > 0
uniform vec4 vClipplane[NCLIPPLANES];
#endif

#if NLIGHTS > 0
uniform mat4 mvMatrix;
#endif

#ifdef is_lit
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
#endif // is_lit

#ifdef is_twosided
uniform bool front;
varying float normz;
#endif

#ifdef fat_lines
varying vec2 vPoint;
varying float vLength;
#endif

void main(void) {
  vec4 fragColor;
#ifdef fat_lines
  vec2 point = vPoint;
  bool neg = point.y < 0.0;
  point.y = neg ? (point.y + vLength)/(1.0 - vLength) :
                 -(point.y - vLength)/(1.0 - vLength);
#if defined(is_transparent) && defined(is_linestrip)
  if (neg && length(point) <= 1.0) discard;
#endif
  point.y = min(point.y, 0.0);
  if (length(point) > 1.0) discard;
#endif // fat_lines
  
#ifdef round_points
  vec2 coord = gl_PointCoord - vec2(0.5);
  if (length(coord) > 0.5) discard;
#endif
  
#if NCLIPPLANES > 0
  for (int i = 0; i < NCLIPPLANES; i++)
    if (dot(vPosition, vClipplane[i]) < 0.0) discard;
#endif
    
#ifdef fixed_quads
    vec3 n = vec3(0., 0., 1.);
#else
    vec3 n = normalize(vNormal.xyz);
#endif
    
#ifdef is_twosided
    if ((normz <= 0.) != front) discard;
#endif
    
#ifdef is_lit
    vec3 eye = normalize(-vPosition.xyz/vPosition.w);
    vec3 lightdir;
    vec4 colDiff;
    vec3 halfVec;
    vec4 lighteffect = vec4(emission, 0.);
    vec3 col;
    float nDotL;
#ifdef fixed_quads
    n = -faceforward(n, n, eye);
#endif
    
#if NLIGHTS > 0
    for (int i=0;i<NLIGHTS;i++) {
      colDiff = vec4(vCol.rgb * diffuse[i], vCol.a);
      lightdir = lightDir[i];
      if (!viewpoint[i])
        lightdir = (mvMatrix * vec4(lightdir, 1.)).xyz;
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
    
#else // not is_lit
    vec4 colDiff = vCol;
    vec4 lighteffect = colDiff;
#endif
    
#ifdef is_text
    vec4 textureColor = lighteffect*texture2D(uSampler, vTexcoord);
#endif
    
#ifdef has_texture
#ifdef texture_rgb
    vec4 textureColor = lighteffect*vec4(texture2D(uSampler, vTexcoord).rgb, 1.);
#endif
    
#ifdef texture_rgba
    vec4 textureColor = lighteffect*texture2D(uSampler, vTexcoord);
#endif
    
#ifdef texture_alpha
    vec4 textureColor = texture2D(uSampler, vTexcoord);
    float luminance = dot(vec3(1.,1.,1.), textureColor.rgb)/3.;
    textureColor =  vec4(lighteffect.rgb, lighteffect.a*luminance);
#endif
    
#ifdef texture_luminance
    vec4 textureColor = vec4(lighteffect.rgb*dot(texture2D(uSampler, vTexcoord).rgb, vec3(1.,1.,1.))/3., lighteffect.a);
#endif
    
#ifdef texture_luminance_alpha
    vec4 textureColor = texture2D(uSampler, vTexcoord);
    float luminance = dot(vec3(1.,1.,1.),textureColor.rgb)/3.;
    textureColor = vec4(lighteffect.rgb*luminance, lighteffect.a*textureColor.a);
#endif
    
    fragColor = textureColor;

#elif defined(is_text)
    if (textureColor.a < 0.1)
      discard;
    else
      fragColor = textureColor;
#else
    fragColor = lighteffect;
#endif // has_texture
    
#ifdef has_fog
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
#endif // has_fog
    
}