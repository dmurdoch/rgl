// 
// This file is part of RGL.
//

#include "opengl.hpp"
#include "R.h"
#include "platform.h"

namespace rgl {
int SaveErrnum = GL_NO_ERROR;
}

using namespace rgl;

static const char * SaveFile;
static int SaveLine;

void saveGLerror(const char * file, int line)
{
  GLenum errnum;
  if (SaveErrnum == GL_NO_ERROR && (errnum = glGetError()) != GL_NO_ERROR) {
    SaveErrnum = errnum;
    SaveFile = file;
    SaveLine = line;
  }
}

void checkGLerror(const char * file, int line)
{
  saveGLerror(file, line);
  if (SaveErrnum != GL_NO_ERROR) {
    int err = SaveErrnum;
    SaveErrnum = GL_NO_ERROR;
    while (glGetError() != GL_NO_ERROR) {} /* clear other errors, if any */
    error("OpenGL error at %s:%d: %s", SaveFile, SaveLine, gluErrorString(err));
  }
}

