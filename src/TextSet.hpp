#ifndef TEXTSET_HPP
#define TEXTSET_HPP

#include "Shape.hpp"

#include "render.h"
#include "String.hpp"
#include "glgui.hpp"
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
          int in_ignoreExtent, FontArray& in_fonts);
  ~TextSet();
  /* Can't use display lists */
  void render(RenderContext* renderContext);
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "text", buflen); };

  int getElementCount(void){ return textArray.size(); }
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  String getTextAttribute(AABox& bbox, AttribID attrib, int index);
    
  Vertex getElementCenter(int index) { return vertexArray[index]; }

  void drawBegin(RenderContext* renderContext);
  void drawElement(RenderContext* renderContext, int index);
  void drawEnd(RenderContext* renderContext);

private:

  VertexArray vertexArray;
  StringArray textArray;
  FontArray fonts;

  double adjx;
  double adjy;

};

} // namespace rgl

#endif // TEXTSET_HPP

