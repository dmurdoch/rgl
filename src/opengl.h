#ifndef RGL_OPENGL_H
#define RGL_OPENGL_H

#include "config.h"

#ifdef RGL_NO_OPENGL

#include "OpenGL/gl.h"

#else
// Use glad 
#include <glad/gl.h>
// ---------------------------------------------------------------------------
// Using OpenGL and GLU
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
#include <GL/glext.h>
#include <GL/wglext.h>
#endif
// ---------------------------------------------------------------------------
#ifdef RGL_X11
#include <GL/gl.h>
#include <GL/glu.h>
#endif

#endif // RGL_NO_OPENGL
// ---------------------------------------------------------------------------
#endif // RGL_OPENGL_H
 
