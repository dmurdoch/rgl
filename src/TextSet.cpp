#include "TextSet.h"

#include "glgui.h"
#include "R.h"
#include "BBoxDeco.h"
#include "subscene.h"
#ifdef HAVE_FREETYPE
#include <map>
#endif

using namespace rgl;

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
                 int in_ignoreExtent, FontArray& in_fonts,
                 int in_npos,
                 const int* in_pos)
 : Shape(in_material, in_ignoreExtent), textArray(in_ntexts, in_texts),
   npos(in_npos)
{
  int i;

  material.lit = false;
  material.colorPerVertex(false);

  adjx = in_adjx;
  adjy = in_adjy;

  // init vertex array

  vertexArray.alloc(in_ntexts);

  fonts = in_fonts;
#ifdef HAVE_FREETYPE  
  blended = true;
#endif  
    
  for (i=0;i<in_ntexts;i++) {

    vertexArray[i].x = (float) in_center[i*3+0];
    vertexArray[i].y = (float) in_center[i*3+1];
    vertexArray[i].z = (float) in_center[i*3+2];

    boundingBox += vertexArray[i];
      
    if (!fonts[i % fonts.size()])
      error("font not available");
    if (!fonts[i % fonts.size()]->valid(textArray[i].text))
      error("text %d contains unsupported character", i+1);
  }
  
  pos = new int[npos];
  for (i=0; i<npos; i++)
    pos[i] = in_pos[i];

}

TextSet::~TextSet()
{
  delete [] pos;
}

void TextSet::render(RenderContext* renderContext) 
{
  draw(renderContext);
}

void TextSet::drawBegin(RenderContext* renderContext) 
{
  Shape::drawBegin(renderContext);
  material.beginUse(renderContext);
}

void TextSet::drawPrimitive(RenderContext* renderContext, int index) 
{
#ifndef RGL_NO_OPENGL
  BBoxDeco* bboxdeco = 0;
  if (material.marginCoord >= 0) {
    Subscene* subscene = renderContext->subscene;
    bboxdeco = subscene->get_bboxdeco();
  } 
  
  GLFont* font;
  Vertex pt = vertexArray[index];
  if (bboxdeco)
    pt = bboxdeco->marginVecToDataVec(pt, renderContext, material.marginCoord, material.edge, material.floating);
  if (!pt.missing()) {
    GLboolean valid;
    material.useColor(index);
    glRasterPos3f( pt.x, pt.y, pt.z );
    glGetBooleanv(GL_CURRENT_RASTER_POSITION_VALID, &valid);
    if (valid) {
      font = fonts[index % fonts.size()];
      if (font) {
        String text = textArray[index];
        font->draw( text.text, text.length, adjx, adjy, pos[index % npos], *renderContext );
      }
    }
  }
#endif
}

void TextSet::drawEnd(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  material.endUse(renderContext);
  Shape::drawEnd(renderContext);
#endif
}

int TextSet::getAttributeCount(AABox& bbox, AttribID attrib) 
{
  switch (attrib) {
    case FAMILY: 
    case FONT:
    case CEX: return static_cast<int>(fonts.size());
    case TEXTS:
    case VERTICES: return textArray.size();
    case ADJ: return 1;
    case POS: return pos[0] ? npos : 0;
  }
  return Shape::getAttributeCount(bbox, attrib);
}

void TextSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
    case VERTICES:
      while (first < n) {
        *result++ = vertexArray[first].x;
        *result++ = vertexArray[first].y;
        *result++ = vertexArray[first].z;
        first++;
      }
      return;
    case CEX:
      while (first < n) 
        *result++ = fonts[first++]->cex;
      return;
    case FONT:
      while (first < n)
      	*result++ = fonts[first++]->style;
      return;
    case ADJ:
      *result++ = adjx;
      *result++ = adjy;
      return;
    case POS:
      while (first < n)
        *result++ = pos[first++];
      return;
    }
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}

String TextSet::getTextAttribute(AABox& bbox, AttribID attrib, int index)
{
  int n = getAttributeCount(bbox, attrib);
  if (index < n) {
    switch (attrib) {
    case TEXTS: 
      return textArray[index];
    case FAMILY:
      char* family = fonts[index]->family;
      return String(static_cast<int>(strlen(family)), family);
    }
  }
  return Shape::getTextAttribute(bbox, attrib, index);
}
