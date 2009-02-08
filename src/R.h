#ifndef RGL_R_H
#define RGL_R_H

// This define avoids a warning about ERROR redefinition in Windows
#define STRICT_R_HEADERS

#include <R.h>

/* Set this to 1 to turn on more extensive testing */
#define USE_SAVEGLERROR 1

#if USE_SAVEGLERROR
#define SAVEGLERROR saveGLerror(__FILE__, __LINE__);
#else
#define SAVEGLERROR 
#endif 

#define CHECKGLERROR checkGLerror(__FILE__, __LINE__);

/* saveGLerror is safe to call from a message handler.  It saves one error.          */
/* checkGLerror is not safe within a message handler.  It checks for saved errors or */
/*   other errors, then reports them through R.                                      */
/* Neither one can be called with glBegin() ... glEnd() pairs.                       */
/* These are defined in glErrors.cpp                                                 */

void saveGLerror(const char *, int);  
void checkGLerror(const char *, int);

#endif /* RGL_R_H */
