#include "Material.h"
#include "gl2ps.h"
#include "opengl.h"
#include "Texture.h"
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
  polygon_offset_factor(0.0f),
  polygon_offset_units(0.0f),
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
  textype(Texture::RGB),
  texmode(Texture::BLEND),
  mipmap(false),
  minfilter(1),
  magfilter(1),
  envmap(false),
  marginCoord(-1),
  floating(false),
  tag(),
  glVersion(-1.0)
{
  alphablend = ( ( bg.getAlphaf() < 1.0f ) || ( fg.getAlphaf() < 1.0f ) ) ? true : false;
  edge[0] = -2;
  edge[1] = -2;
  edge[2] = -2;
  blend[0] = 6;  // GL_SRC_ALPHA
  blend[1] = 7;  // GL_ONE_MINUS_SRC_ALPHA
}

void Material::setup()
{
#ifndef RGL_NO_OPENGL
  const char* version = (const char*)glGetString(GL_VERSION);
  if (version) glVersion = atof(version);
  else 
#endif
    glVersion = 1.0;
}

void Material::beginSide(bool drawfront)
{
#ifndef RGL_NO_OPENGL
	GLenum face = GL_FRONT_AND_BACK;
	
	// FIXME:  why is this set backwards??
	PolygonMode mode = !drawfront ? front : back;
	
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
#endif
}

void Material::beginUse(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  int ncolor = colors.getLength();
  
  GLenum depthfunc[] = { GL_NEVER, GL_LESS, GL_EQUAL, GL_LEQUAL, GL_GREATER,
                         GL_NOTEQUAL, GL_GEQUAL, GL_ALWAYS };
  
  GLenum blendfunc[] = { GL_ZERO, GL_ONE, 
                         GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR, 
                         GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR,
                         GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA,
                         GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA,
                         GL_CONSTANT_COLOR, GL_ONE_MINUS_CONSTANT_COLOR,
                         GL_CONSTANT_ALPHA, GL_ONE_MINUS_CONSTANT_ALPHA,
                         GL_SRC_ALPHA_SATURATE};
  SAVEGLERROR;
  
  glDepthFunc(depthfunc[depth_test]);
  glDepthMask(depth_mask ? GL_TRUE : GL_FALSE);
  
  SAVEGLERROR;

  if (!alphablend)
    glDepthMask(GL_TRUE);
  else {
    if (renderContext->gl2psActive == GL2PS_NONE)
      glBlendFunc(blendfunc[blend[0]], blendfunc[blend[1]]);
    else
      gl2psBlendFunc(blendfunc[blend[0]], blendfunc[blend[1]]);
  }

  SAVEGLERROR;

  if (line_antialias)  glEnable(GL_LINE_SMOOTH);
  
  SAVEGLERROR;

  glDisable(GL_CULL_FACE);

  beginSide(true);  // back set in Shape::beginSideTwo

  SAVEGLERROR;

  /* FIXME:  needs invPrMatrix to be set */

  SAVEGLERROR;

  if (lit) {
  		
#ifdef GL_VERSION_1_2
  		if (glVersion < 0.0) setup();
#endif

  }

  if ( (useColorArray) && ( ncolor > 1 ) ) {
    colors.useArray();
  } else
    colors.useColor(0);

  SAVEGLERROR;

  /* FIXME:  these need to be done in the shader */
  
  if (renderContext->gl2psActive == GL2PS_NONE) {
    glPointSize( size );
    glLineWidth( lwd );
  } else {
    gl2psPointSize( size );
    gl2psLineWidth( lwd );
  }
  
  /* FIXME:  these too? */
  
  if (polygon_offset) {
    glPolygonOffset(polygon_offset_factor, polygon_offset_units);
    glEnable(GL_POLYGON_OFFSET_FILL);
  }
  
  SAVEGLERROR;
  
  if (texture)
    texture->beginUse(renderContext);
 
#endif
}

void Material::useColor(int index)
{
  if (colors.getLength() > 0)
    colors.useColor( index % colors.getLength() );
}

void Material::endUse(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  int ncolor = colors.getLength();

  if ( (useColorArray) && ( ncolor > 1 ) ) {
  	colors.enduseArray();
    SAVEGLERROR;
  }

  if (texture) {
    texture->endUse(renderContext);
    SAVEGLERROR;
  }
  SAVEGLERROR;

  #if USE_GLGETERROR
  if (SaveErrnum == GL_NO_ERROR) glGetError(); /* work around bug in some glX implementations */
  #endif
  SAVEGLERROR;
  
  glDepthFunc(GL_LESS);
  glDepthMask(GL_TRUE);
  
  if (polygon_offset)
    glDisable(GL_POLYGON_OFFSET_FILL);
#endif
}

void Material::colorPerVertex(bool enable, int numVertices)
{
  useColorArray = enable;
  if (enable)
    colors.recycle(numVertices);
}




