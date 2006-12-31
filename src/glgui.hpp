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

#define GL_BITMAP_FONT_FIRST_GLYPH  32
#define GL_BITMAP_FONT_LAST_GLYPH   127
#define GL_BITMAP_FONT_COUNT       (GL_BITMAP_FONT_LAST_GLYPH-GL_BITMAP_FONT_FIRST_GLYPH+1)

#define GL2PS_FONT 	"Helvetica"
#define GL2PS_FONTSIZE 	12


#endif /* GL_GUI_H */

