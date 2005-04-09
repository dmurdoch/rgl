// C++ source
// This file is part of RGL.
//
// $Id$

#include "types.h"
#include "glgui.h"

//
// CLASS
//   GLBitmapFont
//

void GLBitmapFont::draw(char* text, int length, double adj) {

  if (adj > 0) {
    unsigned int textWidth = 0;

    for(int i=0;i<length;i++)
      textWidth += widths[(text[i]-firstGlyph)];

    glBitmap(0,0, 0.0f,0.0f, - (float)(textWidth * adj), 0.0f, NULL);
  }

  glCallLists(length, GL_UNSIGNED_BYTE, text);
}

