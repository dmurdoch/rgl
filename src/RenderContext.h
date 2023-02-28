#ifndef RENDERCONTEXT_H
#define RENDERCONTEXT_H

namespace rgl {
class Subscene;
class GLFont;
} // namespace rgl

#include "rglmath.h"
#include "opengl.h"

namespace rgl {

class RenderContext
{
public:
  RenderContext()
  : subscene(0)
  , rect(0,0,256,256)
  , font(0)
  , time(0.0)
  , lastTime(0.0)
  , deltaTime(0.0)
  , gl2psActive(0)
  { }
  Subscene* subscene;
  Rect2   rect;  // This is the full window rectangle in pixels
  // RectSize size;
  GLFont* font;
  double time;
  double lastTime;
  double deltaTime;

  int gl2psActive;
};

} // namespace rgl

#endif // RENDERCONTEXT_H
