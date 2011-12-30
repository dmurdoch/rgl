#ifndef RGL_OPENGL_H
#define RGL_OPENGL_H
// ---------------------------------------------------------------------------
// Using OpenGL and GLU
//
// $Id$
// ---------------------------------------------------------------------------
#include "config.hpp"
// ---------------------------------------------------------------------------
#ifdef RGL_OSX
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#endif
// ---------------------------------------------------------------------------
#ifdef RGL_W32
#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GLsdk/GL/glext.h>
#endif
// ---------------------------------------------------------------------------
#ifdef RGL_X11
#include <GL/gl.h>
#include <GL/glu.h>
#endif
// ---------------------------------------------------------------------------
#endif // RGL_OPENGL_HPP
 
