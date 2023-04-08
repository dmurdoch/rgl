#ifndef TEXTSET_H
#define TEXTSET_H

#include <vector>
#include <string>

#include "Shape.h"

#include "render.h"
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
          double in_adjx, double in_adjy, double in_adjz,
          int in_ignoreExtent, FontArray& in_fonts,
          int in_npos, const int* in_pos);
  ~TextSet();
  /* Can't use display lists */
  void render(RenderContext* renderContext);
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "text", buflen); };

  int getElementCount(void){ return textArray.size(); }
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  std::string getTextAttribute(SceneNode* subscene, AttribID attrib, int index);
    
  Vertex getPrimitiveCenter(int index) { return vertexArray[index]; }

  void drawBegin(RenderContext* renderContext);
  void drawPrimitive(RenderContext* renderContext, int index);
  void drawEnd(RenderContext* renderContext);

private:

  VertexArray vertexArray;
  std::vector<std::string> textArray;
  FontArray fonts;

  double adjx;
  double adjy;
  double adjz;
  
  int npos;
  int* pos;
};

} // namespace rgl

#endif // TEXTSET_H

