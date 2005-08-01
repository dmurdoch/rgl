#ifndef RENDERCONTEXT_HPP
#define RENDERCONTEXT_HPP

class Scene;
class Viewpoint;
class GLBitmapFont;

#include "math.h"

class RenderContext
{
public:
  RenderContext()
  : scene(0)
  , rect(0,0,0,0)
  , viewpoint(0)
  , font(0)
  , time(0.0)
  , lastTime(0.0)
  , deltaTime(0.0)
  , cop()
  { }
  Scene* scene;
  Rect   rect;
  // RectSize size;
  Viewpoint* viewpoint;
  GLBitmapFont* font;
  double time;
  double lastTime;
  double deltaTime;
  Vertex cop;
};

#endif // RENDERCONTEXT_HPP
