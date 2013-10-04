#include "gl2ps.h"
#include "Material.hpp"
#include "opengl.hpp"
#include "Texture.hpp"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Material
//

Material::Material(Color bg, Color fg)
: 
  ambient(0.0f,0.0f,0.0f,1.0f),
  specular(1.0f,1.0f,1.0f,1.0f),
  emission(0.0f,0.0f,0.0f,0.0f),
  shininess(50.0f),
  size(3.0f),
  lwd(1.0f),
  colors(bg,fg),
  texture(),
  front(FILL_FACE),
  back(FILL_FACE),
  smooth(true),
  lit(true), 
  fog(true),
  useColorArray(false),
  point_antialias(false),
  line_antialias(false),
  depth_mask(true),
  depth_test(1),  // "less"
  glVersion(-1.0)
{
  alphablend = ( ( bg.getAlphaf() < 1.0f ) || ( fg.getAlphaf() < 1.0f ) ) ? true : false;
}

void Material::setup()
{
  const char* version = (const char*)glGetString(GL_VERSION);
  if (version) glVersion = atof(version);
  else glVersion = 1.0;
}

void Material::beginUse(RenderContext* renderContext)
{
  int ncolor = colors.getLength();
  
  GLenum depthfunc[] = { GL_NEVER, GL_LESS, GL_EQUAL, GL_LEQUAL, GL_GREATER,
                         GL_NOTEQUAL, GL_GEQUAL, GL_ALWAYS };
  
  SAVEGLERROR;
  
  glDepthFunc(depthfunc[depth_test]);
  glDepthMask(depth_mask ? GL_TRUE : GL_FALSE);
  
  SAVEGLERROR;

  glPushAttrib( GL_DEPTH_BUFFER_BIT | GL_ENABLE_BIT | GL_POLYGON_BIT );
  
  SAVEGLERROR;

  if (!alphablend) 
    glDepthMask(GL_TRUE);

  SAVEGLERROR;

  if (point_antialias) glEnable(GL_POINT_SMOOTH);
  if (line_antialias)  glEnable(GL_LINE_SMOOTH);
  
  SAVEGLERROR;

  glDisable(GL_CULL_FACE);

  for (int i=0;i<2;i++) {
    
    PolygonMode mode = (i==0) ? front : back;
    
    GLenum face = (i==0) ? GL_FRONT : GL_BACK;

    SAVEGLERROR;

    switch (mode) {
      case FILL_FACE:
        glPolygonMode( face, GL_FILL);
        break;
      case LINE_FACE:
        glPolygonMode( face, GL_LINE);
        break;
      case POINT_FACE:
        glPolygonMode( face, GL_POINT);
        break;
      case CULL_FACE:
        glEnable(GL_CULL_FACE);
        glCullFace(face);
        break;
    }
  }

  SAVEGLERROR;

  glShadeModel( (smooth) ? GL_SMOOTH : GL_FLAT );

  SAVEGLERROR;

  if (lit) {
    glEnable(GL_LIGHTING);
 
    SAVEGLERROR;

#ifdef GL_VERSION_1_2
    if (glVersion < 0.0) setup();
    
    if (glVersion >= 1.2)
      glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, (texture) ? GL_SEPARATE_SPECULAR_COLOR : GL_SINGLE_COLOR ); 
#endif

    SAVEGLERROR;
    
    glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);
    glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT, ambient.data);
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR, specular.data);
    glMaterialf (GL_FRONT_AND_BACK,GL_SHININESS, shininess);
    glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION, emission.data);
  }

  SAVEGLERROR;

  if ( (useColorArray) && ( ncolor > 1 ) ) {
    glEnableClientState(GL_COLOR_ARRAY);
    colors.useArray();
  } else
    colors.useColor(0);

  SAVEGLERROR;

  if (renderContext->gl2psActive == GL2PS_NONE) {
    glPointSize( size );
    glLineWidth( lwd );
  } else {
    gl2psPointSize( size );
    gl2psLineWidth( lwd );
  }
  
  if (texture)
    texture->beginUse(renderContext);

  SAVEGLERROR;

  if (!fog)
    glDisable(GL_FOG);
  
  SAVEGLERROR;    
}

void Material::useColor(int index)
{
  if (colors.getLength() > 0)
    colors.useColor( index % colors.getLength() );
}

void Material::endUse(RenderContext* renderContext)
{
  int ncolor = colors.getLength();

  if ( (useColorArray) && ( ncolor > 1 ) ) {
    glDisableClientState(GL_COLOR_ARRAY);
    SAVEGLERROR;
  }

  if (texture) {
    texture->endUse(renderContext);
    SAVEGLERROR;
  }
  #if USE_GLGETERROR
  saveGLerror(__FILE__, __LINE__);
  #endif
  glPopAttrib();
  #if USE_GLGETERROR
  if (SaveErrnum == GL_NO_ERROR) glGetError(); /* work around bug in some glX implementations */
  #endif
  SAVEGLERROR;
  
  glDepthFunc(GL_LESS);
  glDepthMask(GL_TRUE);
}

void Material::colorPerVertex(bool enable, int numVertices)
{
  useColorArray = enable;
  if (enable)
    colors.recycle(numVertices);
}




