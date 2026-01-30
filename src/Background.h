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
  void draw(RenderContext* renderContext);
  void drawBegin(RenderContext* renderContext);
  void drawPrimitive(RenderContext* renderContext, int index = 0);  
  void drawEnd(RenderContext* renderContext);
  void initialize();
  int getElementCount(void) { return 1; }
  GLbitfield getClearFlags(RenderContext* renderContext);
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  std::string getTextAttribute(SceneNode* subscene, AttribID attrib, int index);
  virtual std::string getTypeName() { return "background"; };
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
  friend class Shape;
private:
  static Material defaultMaterial;
};

} // namespace rgl

#endif // BACKGROUND_H
