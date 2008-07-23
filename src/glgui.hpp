#ifndef GL_GUI_H
#define GL_GUI_H

// C++ header
// This file is part of rgl
//
// $Id$

#include "opengl.hpp"
#include <vector>
#include "RenderContext.hpp"

// CLASS
//   GLFont
//

class GLFont
{
public:
  GLFont(const char* in_family, int in_style, double in_cex, 
         const char* in_fontname, bool in_useFreeType):
  style(in_style), cex(in_cex), useFreeType(in_useFreeType) 
  {
    family = new char[strlen(in_family) + 1];
    memcpy(family, in_family, strlen(in_family) + 1);
    fontname = new char[strlen(in_fontname) + 1];
    memcpy(fontname, in_fontname, strlen(in_fontname) + 1);    
  };
  
  ~GLFont()
  {
    delete [] family;
    delete [] fontname;
  }
  
  virtual void draw(const char* text, int length, double adjx, double adjy, const RenderContext& rc) = 0;
  virtual void draw(const wchar_t* text, int length, double adjx, double adjy, const RenderContext& rc) = 0;
  virtual double width(const char* text) = 0;
  virtual double width(const wchar_t* text) = 0;
  virtual double height() = 0;
  // justify returns false if justification puts the text outside the viewport
  GLboolean justify(double width, double height, double adjx, double adjy, const RenderContext& rc);
  char* family;
  int style;
  double cex;
  char* fontname;
  bool useFreeType;
  int gl2ps_centering;
};

#define GL_BITMAP_FONT_FIRST_GLYPH  32
#define GL_BITMAP_FONT_LAST_GLYPH   127
#define GL_BITMAP_FONT_COUNT       (GL_BITMAP_FONT_LAST_GLYPH-GL_BITMAP_FONT_FIRST_GLYPH+1)

#define GL2PS_FONT 	"Helvetica"
#define GL2PS_FONTSIZE 	12
#define GL2PS_SCALING   0.8

#define GL2PS_NONE	 0
#define GL2PS_LEFT_ONLY	 1
#define GL2PS_POSITIONAL 2

//
// CLASS
//   GLBitmapFont
//

class GLBitmapFont : public GLFont
{
public:
  // Most initialization of this object is done by the system-specific driver
  GLBitmapFont(const char* in_family, int in_style, double in_cex, const char* in_fontname): 
    GLFont(in_family, in_style, in_cex, in_fontname, false) {};
  ~GLBitmapFont();

  void draw(const char* text, int length, double adjx, double adjy, const RenderContext& rc);
  void draw(const wchar_t* text, int length, double adjx, double adjy, const RenderContext& rc); 
  double width(const char* text);
  double width(const wchar_t* text);
  double height();
  
  GLuint listBase;
  GLuint firstGlyph;
  GLuint nglyph;
  unsigned int* widths;
  unsigned int ascent;
};

#ifdef HAVE_FREETYPE
#include "FTGL/ftgl.h"
#endif

//
// CLASS
//   GLFTFont
//

class GLFTFont : public GLFont
{
public:
  GLFTFont(const char* in_family, int in_style, double in_cex, const char* in_fontname);
  
  ~GLFTFont();
#ifdef HAVE_FREETYPE
  void draw(const char* text, int length, double adjx, double adjy, const RenderContext& rc);
  void draw(const wchar_t* text, int length, double adjx, double adjy, const RenderContext& rc);
  double width(const char* text);
  double width(const wchar_t* text);
  double height();
  
  FTFont *font;
  const char *errmsg;
#endif
};

/**
 * FontArray
 **/
typedef std::vector<GLFont*> FontArray;

/* The macros below are taken from the R internationalization code, which
   is marked

   Copyright (C) 1995-1999, 2000-2007 Free Software Foundation, Inc.
*/   
/* Pathname support.
   ISSLASH(C)           tests whether C is a directory separator character.
   IS_ABSOLUTE_PATH(P)  tests whether P is an absolute path.  If it is not,
                        it may be concatenated to a directory pathname.
 */
#if defined _WIN32 || defined __WIN32__ || defined __CYGWIN__ || defined __EMX__ || defined __DJGPP__
  /* Win32, Cygwin, OS/2, DOS */
# define ISSLASH(C) ((C) == '/' || (C) == '\\')
# define HAS_DEVICE(P) \
    ((((P)[0] >= 'A' && (P)[0] <= 'Z') || ((P)[0] >= 'a' && (P)[0] <= 'z')) \
     && (P)[1] == ':')
# define IS_ABSOLUTE_PATH(P) (ISSLASH ((P)[0]) || HAS_DEVICE (P))
#else
  /* Unix */
# define ISSLASH(C) ((C) == '/')
# define IS_ABSOLUTE_PATH(P) ISSLASH ((P)[0])
#endif

#endif /* GL_GUI_H */

