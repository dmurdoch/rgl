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
                 double in_adjx, double in_adjy, double in_adjz,
                 int in_ignoreExtent, FontArray& in_fonts,
                 int in_npos,
                 const int* in_pos)
 : Shape(in_material, in_ignoreExtent),
   npos(in_npos)
{
  int i;

  material.lit = false;
  material.colorPerVertex(false);

  adjx = in_adjx;
  adjy = in_adjy;
  adjz = in_adjz;

  // init vertex array

  vertexArray.alloc(in_ntexts);
  for (i = 0; i < in_ntexts; i++) {
  	textArray.push_back(in_texts[i]);
  }

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
      Rf_error("font not available");
    if (!fonts[i % fonts.size()]->valid(textArray[i].c_str()))
      Rf_error("text %d contains unsupported character", i+1);
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
#ifndef RGL_NO_OPENGL
  /* We use FTGL, which uses the old OpenGL 1.x fixed function scheme.
   * This temporarily restores that scheme just
   * to draw the text.
   */ 
  if (doUseShaders)
    glUseProgram(0);
  glPushAttrib(GL_ENABLE_BIT | GL_TEXTURE_BIT | GL_COLOR_BUFFER_BIT
                 | GL_DEPTH_BUFFER_BIT | GL_LIGHTING_BIT);
  glPushClientAttrib(GL_CLIENT_VERTEX_ARRAY_BIT | GL_CLIENT_PIXEL_STORE_BIT);
#endif
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
    pt = bboxdeco->marginVecToDataVec(pt, renderContext, &material);
  if (!pt.missing()) {
    GLboolean valid;
    material.useColor(index);
    glRasterPos3f( pt.x, pt.y, pt.z );
    glGetBooleanv(GL_CURRENT_RASTER_POSITION_VALID, &valid);
    if (valid) {
      font = fonts[index % fonts.size()];
      if (font) {
        std::string text = textArray[index];
        font->draw( text.c_str(), static_cast<int>(text.size()), adjx, adjy, adjz,
                    pos[index % npos], *renderContext );
      }
    }
  }
#endif
}

void TextSet::drawEnd(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  glPopClientAttrib();
  glPopAttrib();
#endif
  material.endUse(renderContext);
  Shape::drawEnd(renderContext);
}

int TextSet::getAttributeCount(SceneNode* subscene, AttribID attrib) 
{
  switch (attrib) {
    case FAMILY: 
    case FONT:
    case CEX: return static_cast<int>(fonts.size());
    case TEXTS:
    case VERTICES: return static_cast<int>(textArray.size());
    case ADJ: return 1;
    case POS: return pos[0] ? npos : 0;
  }
  return Shape::getAttributeCount(subscene, attrib);
}

void TextSet::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
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
      *result++ = adjz;
      return;
    case POS:
      while (first < n)
        *result++ = pos[first++];
      return;
    }
    Shape::getAttribute(subscene, attrib, first, count, result);
  }
}

std::string TextSet::getTextAttribute(SceneNode* subscene, AttribID attrib, int index)
{
  int n = getAttributeCount(subscene, attrib);
  if (index < n) {
    switch (attrib) {
    case TEXTS: 
      return textArray[index];
    case FAMILY:
      char* family = fonts[index]->family;
      return family;
    }
  }
  return Shape::getTextAttribute(subscene, attrib, index);
}
