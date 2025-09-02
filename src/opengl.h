#ifndef RGL_OPENGL_H
#define RGL_OPENGL_H

#include "config.h"

namespace rgl {

#define doUseShaders 1

} // namespace rgl

#ifdef RGL_NO_OPENGL

#include "OpenGL/gl.h"

#else

// Use glad 
#include <glad/gl.h>

#ifdef RGL_W32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <GL/glu.h>
#include <GL/glext.h>
#include <GL/wglext.h>
#else

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
 
