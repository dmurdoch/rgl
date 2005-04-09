#ifndef GL_GUI_H
#define GL_GUI_H

// C++ header
// This file is part of rgl
//
// $Id$

#include "opengl.hpp"

//
// CLASS
//   GLBitmapFont
//

class GLBitmapFont
{
public:
  GLBitmapFont() {};

  void enable() {
    glListBase(listBase);
  };

  void draw(char* text, int length, double adj);

  GLuint listBase;
  GLuint firstGlyph;
  GLuint nglyph;
  unsigned int* widths;

};


#endif /* GL_GUI_H */

