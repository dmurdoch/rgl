#ifndef RGL_OPENGL_H
#define RGL_OPENGL_H

#include "config.h"

#ifdef RGL_NO_OPENGL

#include "OpenGL/gl.h"

#else
#ifdef RGL_W32
#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glext.h>
#include <GL/wglext.h>
#else

// Use glad 
#include <glad/gl.h>

// ---------------------------------------------------------------------------
// Using OpenGL and GLU
// ---------------------------------------------------------------------------
#ifdef RGL_OSX
#include <OpenGL/glu.h>
#endif
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
#ifdef RGL_X11
#include <GL/glu.h>
#endif

#endif // not RGL_W32

#endif // RGL_NO_OPENGL
// ---------------------------------------------------------------------------
#endif // RGL_OPENGL_H
 
