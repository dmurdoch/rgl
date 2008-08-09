#ifndef TEXTSET_HPP
#define TEXTSET_HPP

#include "Shape.hpp"

//
// TEXTSET
//

#include "render.h"
#include "String.hpp"
#include "glgui.hpp"
#ifdef HAVE_FREETYPE
#include "FTGL/ftgl.h"
#endif

class TextSet : public Shape {
public:
  TextSet(Material& in_material, int in_ntexts, char** in_texts, double *in_center, 
          double in_adjx, double in_adjy,
          int in_ignoreExtent, FontArray& in_fonts);
  ~TextSet();
  /* Can't use display lists */
  void render(RenderContext* renderContext);
  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "text", buflen); };

  int getElementCount(void){ return textArray.size(); }
  
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

#endif // TEXTSET_HPP

