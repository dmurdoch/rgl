#include "TextSet.hpp"

#include "glgui.hpp"
#ifdef HAVE_FREETYPE
#include "Viewpoint.hpp"
#include "R.h"
#include <map>
#endif
//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   TextSet
//
// INTERNAL TEXTS STORAGE
//   texts are copied to a buffer without null byte
//   a separate length buffer holds string lengths in order
//

TextSet::TextSet(Material& in_material, int in_ntexts, char** in_texts, double *in_center, 
                 double in_adjx, double in_adjy,
                 int in_ignoreExtent, FontArray& in_fonts)
 : Shape(in_material, in_ignoreExtent), textArray(in_ntexts, in_texts)
{
  int i;

  material.lit = false;
  material.colorPerVertex(false);

  adjx = in_adjx;
  adjy = in_adjy;

  // init vertex array

  vertexArray.alloc(in_ntexts);

  for (i=0;i<in_ntexts;i++) {

    vertexArray[i].x = (float) in_center[i*3+0];
    vertexArray[i].y = (float) in_center[i*3+1];
    vertexArray[i].z = (float) in_center[i*3+2];

    boundingBox += vertexArray[i];
  }
  fonts = in_fonts;
#ifdef HAVE_FREETYPE  
  blended = true;
#endif
}

TextSet::~TextSet()
{
}

void TextSet::render(RenderContext* renderContext) 
{
  draw(renderContext);
}

void TextSet::drawBegin(RenderContext* renderContext) 
{
  material.beginUse(renderContext);
}

void TextSet::drawElement(RenderContext* renderContext, int index) 
{
  GLFont* font;

  if (!vertexArray[index].missing()) {
    GLboolean valid;
    material.useColor(index);
    glRasterPos3f( vertexArray[index].x, vertexArray[index].y, vertexArray[index].z );
    glGetBooleanv(GL_CURRENT_RASTER_POSITION_VALID, &valid);
    if (valid) {
      font = fonts[index % fonts.size()];
      if (font) {
        String text = textArray[index];
        font->draw( text.text, text.length, adjx, adjy, *renderContext );
      }
    }
  }
}

void TextSet::drawEnd(RenderContext* renderContext)
{
  material.endUse(renderContext);
}
