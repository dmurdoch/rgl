#ifndef RGL_R_H
#define RGL_R_H

// This define avoids a warning about ERROR redefinition in Windows
#define STRICT_R_HEADERS

#include <string>

#include <R.h>

/* Default for antialiasing */
#define RGL_ANTIALIAS 8

/* Set this to 1 to turn on glGetError testing */
#define USE_GLGETERROR 1

#define NA_FLOAT static_cast<float>(NA_REAL)

namespace rgl {

#if USE_GLGETERROR
#define SAVEGLERROR saveGLerror(__FILE__, __LINE__);
#define CHECKGLERROR checkGLerror(__FILE__, __LINE__);

/* saveGLerror is safe to call from a message handler.  It saves one error.          */
/* checkGLerror is not safe within a message handler.  It checks for saved errors or */
/*   other errors, then reports them through R.                                      */
/* Neither one can be called with glBegin() ... glEnd() pairs.                       */
/* They are defined in glErrors.cpp                                                  */

extern int SaveErrnum;

void saveGLerror(const char * file, int line); 

void checkGLerror(const char * file, int line);

#else
#define SAVEGLERROR
#define CHECKGLERROR
#endif

char* copyStringToR(std::string s);

} // namespace rgl

#endif /* RGL_R_H */
