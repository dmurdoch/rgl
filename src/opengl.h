#ifndef OPENGL_H
#define OPENGL_H

// C++ header file
// This file is part of RGL
//
// $Id: opengl.h,v 1.2 2003/05/14 10:58:36 dadler Exp $

#ifdef _WIN32
#include <windows.h>
#endif

extern "C" {

#ifdef NO_GL_PREFIX
#include <gl.h>
#include <glu.h>
#else
#include <GL/gl.h>
#include <GL/glu.h>
#endif

};

//
// CLASS
//   GLBitmapFont
//

#define GL_BITMAP_FONT_FIRST_GLYPH  32
#define GL_BITMAP_FONT_LAST_GLYPH   127
#define GL_BITMAP_FONT_COUNT       (GL_BITMAP_FONT_LAST_GLYPH-GL_BITMAP_FONT_FIRST_GLYPH+1)

#endif /* OPENGL_H */
