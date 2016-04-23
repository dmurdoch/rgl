#ifndef BACKGROUND_H
#define BACKGROUND_H

#include "Shape.h"
#include "opengl.h"
#include "PrimitiveSet.h"
#include "SphereMesh.h"

namespace rgl {

//
// CLASS
//   Background
//

class Background : public Shape
{
public:
  enum {
    FOG_NONE=1, FOG_LINEAR, FOG_EXP, FOG_EXP2
  };
  Background( Material& in_material = defaultMaterial, bool sphere=false, int fogtype=FOG_NONE);
  ~Background();
  void render(RenderContext* renderContext);
  int getElementCount(void) { return 1; }
  void drawElement(RenderContext* renderContext, int index);  
  GLbitfield getClearFlags(RenderContext* renderContext);
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  String  getTextAttribute(AABox& bbox, AttribID attrib, int index);
  void getTypeName(char* buffer, int buflen) { strncpy(buffer, "background", buflen); };
  SceneNode* getQuad() { return quad; };

protected:
  bool clearColorBuffer;
  bool sphere;
  int  fogtype;
  SphereMesh sphereMesh;
  QuadSet* quad;
//  GLuint displayList;
  friend class Scene;
private:
  static Material defaultMaterial;
};

} // namespace rgl

#endif // BACKGROUND_H
