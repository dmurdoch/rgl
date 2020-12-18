// C++ source
// This file is part of RGL.
//

#include "platform.h"

/*  MacOSX */

#ifdef RGL_OSX

#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9
  // pre-Mavericks code
#else
  // Mavericks and later
  
#include <GLKit/GLKMathUtils.h> 
#include <GLKit/GLKVector3.h>
#include <GLKit/GLKMatrix4.h>
  

GLint gluUnProject(GLdouble  winX,  GLdouble  winY,  GLdouble  winZ,  
                   const GLdouble *  model,  const GLdouble *  proj,  
                   const GLint *  view,  GLdouble*  objX,  GLdouble*  objY,  
                   GLdouble*  objZ)
{
  int glkview[] = {view[0], view[1], view[2], view[3]};
  bool success;
  GLKVector3 result =
  GLKMathUnproject(GLKVector3Make(static_cast<float>(winX), 
                                  static_cast<float>(winY), 
                                  static_cast<float>(winZ)),
                 GLKMatrix4Make(static_cast<float>(model[0]),
                                static_cast<float>(model[1]),
                                static_cast<float>(model[2]),
                                static_cast<float>(model[3]),
                                static_cast<float>(model[4]),
                                static_cast<float>(model[5]),
                                static_cast<float>(model[6]),
                                static_cast<float>(model[7]),
                 		            static_cast<float>(model[8]),
                 		            static_cast<float>(model[9]),
                 		            static_cast<float>(model[10]),
                 		            static_cast<float>(model[11]),
                 		            static_cast<float>(model[12]),
                 		            static_cast<float>(model[13]),
                 		            static_cast<float>(model[14]),
                 		            static_cast<float>(model[15])),
                 GLKMatrix4Make(static_cast<float>(proj[0]),
                                static_cast<float>(proj[1]),
                                static_cast<float>(proj[2]),
                                static_cast<float>(proj[3]),
                 		            static_cast<float>(proj[4]),
                 		            static_cast<float>(proj[5]),
                 		            static_cast<float>(proj[6]),
                 		            static_cast<float>(proj[7]),
                 		            static_cast<float>(proj[8]),
                 		            static_cast<float>(proj[9]),
                 		            static_cast<float>(proj[10]),
                 		            static_cast<float>(proj[11]),
                 		            static_cast<float>(proj[12]),
                 		            static_cast<float>(proj[13]),
                 		            static_cast<float>(proj[14]),
                 		            static_cast<float>(proj[15])),
                 glkview,
                 &success
                 );
  *objX = result.v[0];
  *objY = result.v[1];
  *objZ = result.v[2];
  return success ? GLU_TRUE : GLU_FALSE;
}               

const GLubyte * gluErrorString(GLenum  error)
{
  return (GLubyte*)"glu Error";
}
                      
#endif /* Mavericks */

#endif /* RGL_OSX */
