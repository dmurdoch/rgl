#ifndef BACKGROUND_HPP
#define BACKGROUND_HPP

#include "Shape.hpp"

#include "opengl.h"

//
// CLASS
//   Background
//

#include "SphereMesh.hpp"

class Background : public Shape
{
public:
  enum {
    FOG_NONE=1, FOG_LINEAR, FOG_EXP, FOG_EXP2
  };
  Background( Material& in_material = defaultMaterial, bool sphere=false, int fogtype=FOG_NONE);
  void render(RenderContext* renderContext);
  void draw(RenderContext* renderContext);
  GLbitfield getClearFlags(RenderContext* renderContext);
protected:
  bool clearColorBuffer;
  bool sphere;
  int  fogtype;
  SphereMesh sphereMesh;
//  GLuint displayList;
  friend class Scene;
private:
  static Material defaultMaterial;
};

#endif // BACKGROUND_HPP
