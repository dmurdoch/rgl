#ifndef RGL_FPS_H
#define RGL_FPS_H

// C++ header file
// This file is part of RGL
//

#include "scene.h"

namespace rgl {

//
// FPS COUNTER
//

class FPS
{
private:
  double lastTime;
  int   framecnt;
  char  buffer[12];
public:
  inline FPS() { };
  void init(double t);
  void render(double t, RenderContext* ctx);
};

} // namespace rgl

#endif // RGL_FPS_H

