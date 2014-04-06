#ifndef RENDERCONTEXT_HPP
#define RENDERCONTEXT_HPP

namespace rgl {
class Subscene;
class Viewpoint;
class GLFont;
} // namespace rgl

#include "rglmath.h"
#include "opengl.hpp"

namespace rgl {

class RenderContext
{
public:
  RenderContext()
  : subscene(0)
  , rect(0,0,0,0)
  , viewpoint(0)
  , font(0)
  , time(0.0)
  , lastTime(0.0)
  , deltaTime(0.0)
  , Zrow()
  , Wrow()
  , gl2psActive(0)
  , NULLActive(0)
  { }
  Subscene* subscene;
  Rect2   rect;  // This is the full window rectangle in pixels
  // RectSize size;
  Viewpoint* viewpoint;
  GLFont* font;
  double time;
  double lastTime;
  double deltaTime;
  float getDistance(const Vertex& v) const;
  GLdouble modelview[16];
  GLdouble projection[16];
  GLint viewport[4];
  Vec4 Zrow;
  Vec4 Wrow;
  int gl2psActive;
  bool NULLActive;
};

} // namespace rgl

#endif // RENDERCONTEXT_HPP
