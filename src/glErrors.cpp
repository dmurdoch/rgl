// 
// This file is part of RGL.
//

#include "R.h"
#include "opengl.hpp"

static GLenum SaveErrnum = GL_NO_ERROR;
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
  GLenum errnum;
  if (SaveErrnum != GL_NO_ERROR) {
    errnum = SaveErrnum;
    SaveErrnum = GL_NO_ERROR;
    file = SaveFile;
    line = SaveLine;
  } else 
    errnum = glGetError();
  if (errnum != GL_NO_ERROR) {
    while (glGetError() != GL_NO_ERROR) {} /* clear other errors, if any */
    error("OpenGL error at %s:%d: %s", file, line, gluErrorString(errnum));
  }
}

