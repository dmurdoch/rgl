#ifndef TEXTSET_H
#define TEXTSET_H

#include "Shape.h"

#include "render.h"
#include "String.h"
#include "glgui.h"
#ifdef HAVE_FREETYPE
#include "FTGL/ftgl.h"
#endif

namespace rgl {

//
// TEXTSET
//

class TextSet : public Shape {
public:
  TextSet(Material& in_material, int in_ntexts, char** in_texts, double *in_center, 
          double in_adjx, double in_adjy,
          int in_ignoreExtent, FontArray& in_fonts,
          int in_npos, const int* in_pos);
  ~TextSet();
  /* Can't use display lists */
  void render(RenderContext* renderContext);
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "text", buflen); };

  int getElementCount(void){ return textArray.size(); }
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  String getTextAttribute(AABox& bbox, AttribID attrib, int index);
    
  Vertex getPrimitiveCenter(int index) { return getVertex(index); }

  void drawBegin(RenderContext* renderContext);
  void drawPrimitive(RenderContext* renderContext, int index);
  void drawEnd(RenderContext* renderContext);
  
private:
  
  StringArray textArray;
  FontArray fonts;

  double adjx;
  double adjy;
  
  int npos;
  int* pos;
};

} // namespace rgl

#endif // TEXTSET_H

