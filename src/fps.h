#ifndef RGL_FPS_H
#define RGL_FPS_H

// C++ header file
// This file is part of RGL
//
// $Id: fps.h,v 1.2 2004/08/27 15:58:57 dadler Exp $

#include "scene.h"

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

#endif // RGL_FPS_H

