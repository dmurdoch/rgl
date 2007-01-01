// C++ source
// This file is part of RGL.
//
// $Id$

#include "types.h"
#include "glgui.hpp"
#include "gl2ps.h"

//
// CLASS
//   GLBitmapFont
//

void GLBitmapFont::draw(char* text, int length, double adj, int gl2psActive) {
  
  int centering = GL2PS_TEXT_BL;
  
  if (adj > 0) {
    unsigned int textWidth = 0;
    double base = 0.0;
    double scaling = 1.0;

    if (gl2psActive > GL2PS_NONE) scaling = GL2PS_SCALING;
     
    if ( adj > 0.25 && gl2psActive == GL2PS_POSITIONAL) {
      if (adj < 0.75) {
        base = 0.5;
        centering = GL2PS_TEXT_B;
      } else {
        base = 1.0;
        centering = GL2PS_TEXT_BR;
      }
    }
    if (adj != base) {
      for(int i=0;i<length;i++)
        textWidth += widths[(text[i]-firstGlyph)];

      glBitmap(0,0, 0.0f,0.0f, (float)(scaling * textWidth * (base - adj)), 0.0f, NULL);
    }
  }
  if (gl2psActive == GL2PS_NONE)
    glCallLists(length, GL_UNSIGNED_BYTE, text);
  else
    gl2psTextOpt(text, GL2PS_FONT, GL2PS_FONTSIZE, centering, 0.0);
}
