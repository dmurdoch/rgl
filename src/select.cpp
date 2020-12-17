// C++ source
// This file is part of RGL.
//

#include "select.h"

#include <cstdio>

using namespace rgl;

void SELECT::render(double* position)
{
#ifndef RGL_NO_OPENGL  
  double llx, lly, urx, ury;
  llx = *position;
  lly = *(position+1);
  urx = *(position+2);
  ury = *(position+3);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0.0f,1.0f,0.0f,1.0f,0.0f,1.0f);

  glColor3f(0.5f,0.5f,0.5f);
  glLineWidth(2.0);

  glBegin(GL_LINE_LOOP);
  	glVertex2f(llx, lly);
  	glVertex2f(llx,	ury);
  	glVertex2f(urx, ury);
  	glVertex2f(urx, lly);
  glEnd();
#endif
}
