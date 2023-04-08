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
  Background( Material& in_material = defaultMaterial, bool sphere=false, int fogtype=FOG_NONE,
              float in_fogScale = 1.0);
  ~Background();
  void render(RenderContext* renderContext);
  int getElementCount(void) { return 1; }
  void drawPrimitive(RenderContext* renderContext, int index);  
  GLbitfield getClearFlags(RenderContext* renderContext);
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  std::string getTextAttribute(SceneNode* subscene, AttribID attrib, int index);
  void getTypeName(char* buffer, int buflen) { strncpy(buffer, "background", buflen); };
  SceneNode* getQuad() { return quad; };

protected:
  bool clearColorBuffer;
  bool sphere;
  int  fogtype;
  float fogScale;
  SphereMesh sphereMesh;
  QuadSet* quad;
//  GLuint displayList;
  friend class Scene;
private:
  static Material defaultMaterial;
};

} // namespace rgl

#endif // BACKGROUND_H
