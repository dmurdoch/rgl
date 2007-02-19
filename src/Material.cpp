#include "Material.hpp"

#include "opengl.hpp"
#include "Texture.hpp"
#include "R.h"

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
  size(1.0f),
  colors(bg,fg),
  texture(),
  front(FILL_FACE),
  back(FILL_FACE),
  smooth(true),
  lit(true), 
  fog(true),
  useColorArray(false)
{
  alphablend = ( ( bg.getAlphaf() < 1.0f ) || ( fg.getAlphaf() < 1.0f ) ) ? true : false;
}

void Material::setup()
{
}

void Material::beginUse(RenderContext* renderContext)
{
  int ncolor = colors.getLength();

  glPushAttrib( /* GL_DEPTH_BUFFER_BIT | */ GL_ENABLE_BIT | GL_POLYGON_BIT );

#if 0
  if (alphablend) {    
    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    // glBlendFunc(GL_SRC_ALPHA, GL_ONE );
  } else {
    glDepthMask(GL_TRUE);
  }
#endif

  glDisable(GL_CULL_FACE);

  for (int i=0;i<2;i++) {
    
    PolygonMode mode = (i==0) ? front : back;
    
    GLenum face = (i==0) ? GL_FRONT : GL_BACK;

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

  glShadeModel( (smooth) ? GL_SMOOTH : GL_FLAT );

  if (lit) {
    glEnable(GL_LIGHTING);
 
#ifdef GL_VERSION_1_2
    glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, (texture) ? GL_SEPARATE_SPECULAR_COLOR : GL_SINGLE_COLOR );
#endif

    glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);
    glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT, ambient.data);
    glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR, specular.data);
    glMaterialf (GL_FRONT_AND_BACK,GL_SHININESS, shininess);
    glMaterialfv(GL_FRONT_AND_BACK,GL_EMISSION, emission.data);
  }

  if ( (useColorArray) && ( ncolor > 1 ) ) {
    glEnableClientState(GL_COLOR_ARRAY);
    colors.useArray();
  } else
    colors.useColor(0);

  glPointSize( size );
  glLineWidth( size );

  if (texture)
    texture->beginUse(renderContext);

  if (!fog)
    glDisable(GL_FOG);
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
  }

  if (texture)
    texture->endUse(renderContext);

  glPopAttrib();
}

void Material::colorPerVertex(bool enable, int numVertices)
{
  useColorArray = enable;
  if (enable)
    colors.recycle(numVertices);
}




