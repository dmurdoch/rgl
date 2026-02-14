#ifndef RENDERCONTEXT_H
#define RENDERCONTEXT_H

namespace rgl {
class Subscene;
} // namespace rgl

#include <string>
#include "rglmath.h"
#include "opengl.h"

namespace rgl {

class RenderContext
{
public:
  RenderContext()
  : subscene(0)
  , rect(0,0,256,256)
  , family("sans")
  , style(1)
  , cex(1.0)
  , fontname("")
  , time(0.0)
  , lastTime(0.0)
  , deltaTime(0.0)
  , gl2psActive(0)
  { }
  Subscene* subscene;
  Rect2   rect;  // This is the full window rectangle in pixels
  // RectSize size;
  std::string family;
  int style;
  double cex;
  std::string fontname;
  double time;
  double lastTime;
  double deltaTime;

  int gl2psActive;
};

} // namespace rgl

#endif // RENDERCONTEXT_H
