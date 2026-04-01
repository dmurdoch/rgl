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

void rgl::saveGLerror(const char * file, int line)
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

void rgl::checkGLerror(const char * file, int line)
{
#ifndef RGL_NO_OPENGL
  const char * messages[] = {
    "GL_INVALID_ENUM: An unacceptable value is specified for an enumerated argument.",
    "GL_INVALID_VALUE: A numeric argument is out of range.",
    "GL_INVALID_OPERATION: The specified operation is not allowed in the current state.",
    "GL_STACK_OVERFLOW: This command would cause a stack overflow.",
    "GL_STACK_UNDERFLOW: This command would cause a stack underflow.",
    "GL_OUT_OF_MEMORY: There is not enough memory left to execute the command.",
    "GL_INVALID_FRAMEBUFFER_OPERATION: The framebuffer object is not complete."
  };
  rgl::saveGLerror(file, line);
  if (SaveErrnum != GL_NO_ERROR) {
    int err = SaveErrnum;
    SaveErrnum = GL_NO_ERROR;
    while (glGetError() != GL_NO_ERROR) {} /* clear other errors, if any */
    if (0x500 <= err && err <= 0x506)
      Rf_error("OpenGL error at %s:%d: %#3x:%s", SaveFile, SaveLine, err, messages[err-0x500]);
    Rf_error("OpenGL error at %s:%d: %#4x:%s", SaveFile, SaveLine, err,
             gluErrorString(err));
  }
#endif
}

