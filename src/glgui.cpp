// C++ source
// This file is part of RGL.
//

#include <cstdio>
#ifdef HAVE_FREETYPE
#include "FTGL/ftgl.h"
#include "R.h"
#endif
#include "types.h"
#include "glgui.h"
#include "gl2ps.h"
#include "opengl.h"
#include "RenderContext.h"
#include "subscene.h"
#include "platform.h"

using namespace rgl;

//
// CLASS
//   GLFont
//

GLboolean GLFont::justify(double twidth, double theight, double adjx, double adjy, 
                          int pos, const RenderContext& rc) {
  GLdouble pos1[4], pos2[4];
  double basex = 0.0, basey = 0.0, scaling = 1.0;
  GLboolean valid;
  gl2ps_centering = GL2PS_TEXT_BL;
  
  if (pos) {
    double offset = adjx, w = width("m");
    switch(pos) {
    case 1:
    case 3: 
      adjx = 0.5;
      break;
    case 2:
      adjx = 1.0 + w*offset/twidth;
      break;
    case 4:
      adjx = -w*offset/twidth;
      break;
    }
    switch(pos) {
    case 2:
    case 4:
      adjy = 0.5;
      break;
    case 1:
      adjy = 1.0 + offset;
      break;
    case 3:
      adjy = -offset;
      break;
    }
  }
  
  if (adjx > 0) {

    if (rc.gl2psActive > GL2PS_NONE) scaling = GL2PS_SCALING;
     
    if ( adjx > 0.25 && rc.gl2psActive == GL2PS_POSITIONAL) {
      if (adjx < 0.75) {
        basex = 0.5;
        gl2ps_centering = GL2PS_TEXT_B;
      } else {
        basex = 1.0;
        gl2ps_centering = GL2PS_TEXT_BR;
      }
    }
  }  

  if ((adjx != basex) || (adjy != basey)) {
    glGetDoublev(GL_CURRENT_RASTER_POSITION, pos1);    
    pos1[0] = pos1[0] - scaling*twidth*(adjx-basex); 
    pos1[1] = pos1[1] - scaling*theight*(adjy-basey);
    GLint pviewport[4] = {rc.subscene->pviewport.x, 
                          rc.subscene->pviewport.y, 
                          rc.subscene->pviewport.width, 
                          rc.subscene->pviewport.height};
    GLdouble modelMatrix[16], projMatrix[16];
    rc.subscene->modelMatrix.getData(modelMatrix);
    rc.subscene->projMatrix.getData(projMatrix);
    gluUnProject( pos1[0], pos1[1], pos1[2], modelMatrix, projMatrix, pviewport, pos2, pos2 + 1, pos2 + 2);
    glRasterPos3dv(pos2);
  }
  
  glGetBooleanv(GL_CURRENT_RASTER_POSITION_VALID, &valid);
  return valid;
}

//
// CLASS
//   GLBitmapFont
//

GLBitmapFont::~GLBitmapFont() {
    delete [] widths;
    if (nglyph) glDeleteLists(listBase+GL_BITMAP_FONT_FIRST_GLYPH, nglyph);
}

double GLBitmapFont::width(const char* text) {
  double result = 0.0;
  for(int i=0; text[i]; i++) {
    char c;
    if ((int)(text[i]) >= (int)firstGlyph && (c = (int)(text[i]) - (int)firstGlyph) < (int)nglyph)
      result += widths[(int)c];
  }
  return result;
}

double GLBitmapFont::width(const wchar_t* text) {
  double result = 0.0;
  for(int i=0; text[i]; i++) {
    wchar_t c;
    if ((int)text[i] >= (int)firstGlyph && (c = (int)(text[i]) - (int)firstGlyph) < (int)nglyph)
      result += widths[c];  
  }    
  return result;
}
  
double GLBitmapFont::height() {
  return ascent;
}

bool GLBitmapFont::valid(const char* text) {
  for (int i=0; text[i]; i++)
    if ((int)text[i] < (int)firstGlyph || (int)text[i] - (int)firstGlyph >= (int)nglyph)
      return false;
  return true;
}

void GLBitmapFont::draw(const char* text, int length, 
                        double adjx, double adjy, 
                        int pos, const RenderContext& rc) {

  if (justify(width(text), height(), adjx, adjy, pos, rc)) {
    if (rc.gl2psActive == GL2PS_NONE) {
      glListBase(listBase);
      glCallLists(length, GL_UNSIGNED_BYTE, text);
    } else
      gl2psTextOpt(text, GL2PS_FONT, GL2PS_FONTSIZE*cex, gl2ps_centering, 0.0);
  }
}

void GLBitmapFont::draw(const wchar_t* text, int length, 
                        double adjx, double adjy, 
                        int pos, const RenderContext& rc) {
  
  if (justify(width(text), height(), adjx, adjy, pos, rc)) {
    GLenum type = sizeof(wchar_t) == 4 ? GL_UNSIGNED_INT :
                  sizeof(wchar_t) == 2 ? GL_UNSIGNED_SHORT : GL_UNSIGNED_BYTE ;
    if (rc.gl2psActive == GL2PS_NONE) {
      glListBase(listBase);
      glCallLists(length, type, text);
    }
  // gl2ps doesn't support wchar_t?  Should convert?
  }
}

#ifdef HAVE_FREETYPE

GLFTFont::GLFTFont(const char* in_family, int in_style, double in_cex, const char* in_fontname) 
: GLFont(in_family, in_style, in_cex, in_fontname, true)
{
  font=new FTGLPixmapFont(fontname);
  if (font->Error()) { 
    errmsg = "Cannot create Freetype font";
    delete font;
    font = NULL;
  } else {
    unsigned int size = 16*cex + 0.5;
    if (size<1) { size=1; }
    if (!font->FaceSize(size)) {
      errmsg = "Cannot create Freetype font of requested size";
      delete font;
      font = NULL;
    }
  }
/*  font->CharMap(ft_encoding_unicode);
  if (font->Error()) {
    error("Cannot set unicode encoding."); 
  }*/

}

GLFTFont::~GLFTFont()
{
  if (font) delete font;
}

double GLFTFont::width(const char* text) {
  return font->Advance(text);
}

double GLFTFont::width(const wchar_t* text) {
  return font->Advance(text);
}
  
double GLFTFont::height() {
  return font->Ascender();
}

void GLFTFont::draw(const char* text, int length, double adjx, double adjy, 
                    int pos, const RenderContext& rc) {
  
  if ( justify( width(text), height(), adjx, adjy, pos, rc ) ) {
    if (rc.gl2psActive == GL2PS_NONE)
      font->Render(text);
    else
      gl2psTextOpt(text, GL2PS_FONT, GL2PS_FONTSIZE*cex, gl2ps_centering, 0.0);
  }
}

void GLFTFont::draw(const wchar_t* text, int length, double adjx, double adjy, 
                    int pos, const RenderContext& rc) {
  
  if ( justify( width(text), height(), adjx, adjy, pos, rc ) ) {
    if (rc.gl2psActive == GL2PS_NONE) 
      font->Render(text);
  }      
}
      
#endif
