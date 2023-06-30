// 
// This file is part of RGL.
//

#include "opengl.h"
#include "R.h"
#include "platform.h"

namespace rgl {
int SaveErrnum = GL_NO_ERROR;
}

using namespace rgl;

#ifndef RGL_NO_OPENGL
static const char * SaveFile;
static int SaveLine;
#endif

void saveGLerror(const char * file, int line)
{
#ifndef RGL_NO_OPENGL
  GLenum errnum;
  if (SaveErrnum == GL_NO_ERROR && (errnum = glGetError()) != GL_NO_ERROR) {
    SaveErrnum = errnum;
    SaveFile = file;
    SaveLine = line;
  }
#endif
}

void checkGLerror(const char * file, int line)
{
#ifndef RGL_NO_OPENGL
  saveGLerror(file, line);
  if (SaveErrnum != GL_NO_ERROR) {
    int err = SaveErrnum;
    SaveErrnum = GL_NO_ERROR;
    while (glGetError() != GL_NO_ERROR) {} /* clear other errors, if any */
    Rf_error("OpenGL error at %s:%d: %s", SaveFile, SaveLine, gluErrorString(err));
  }
#endif
}

