#ifndef PLATFORM_H
#define PLATFORM_H

/* These are some platform-specific definitions, currently to support MacOSX */

#include "opengl.h"

/*  MacOSX */

#ifdef RGL_OSX

#include <Availability.h>

#ifndef __MAC_10_9
#define __MAC_10_9 1090
#endif

#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9
  // pre-Mavericks code
#else
  // Mavericks and later  

#define gluUnProject rgl_gluUnProject
#define gluErrorString rgl_gluErrorString
  
                 
GLint gluUnProject(GLdouble  winX,  GLdouble  winY,  GLdouble  winZ,  
                   const GLdouble *  model,  const GLdouble *  proj,  
                   const GLint *  view,  GLdouble*  objX,  GLdouble*  objY,  
                   GLdouble*  objZ);
                   
const GLubyte * gluErrorString(GLenum  error);
                 
#endif /* Mavericks */

#endif /* RGL_OSX */

#endif /* PLATFORM_H */
