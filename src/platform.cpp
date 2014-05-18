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
  
#include <GLKMathUtils.h> 
#include <GLKVector3.h>
#include <GLKMatrix4.h>
  
GLint gluProject(GLdouble  objX,  GLdouble  objY,  GLdouble  objZ,  
                 const GLdouble *  model,  const GLdouble *  proj,  
                 const GLint *  view,  GLdouble*  winX,  GLdouble*  winY,  
                 GLdouble*  winZ) 
{
  int glkview[] = {view[0], view[1], view[2]};
  GLKVector3 result =
  GLKMathProject(GLKVector3Make(objX, objY, objZ),
                 GLKMatrix4Make(model[0],model[1],model[2],model[3],
                 		model[4],model[5],model[6],model[7],
                 		model[8],model[9],model[10],model[11],
                 		model[12],model[13],model[14],model[15]),
                 GLKMatrix4Make(proj[0],proj[1],proj[2],proj[3],
                 		proj[4],proj[5],proj[6],proj[7],
                 		proj[8],proj[9],proj[10],proj[11],
                 		proj[12],proj[13],proj[14],proj[15]),
                 glkview                 
                 );
  *winX = result.x;
  *winY = result.y;
  *winZ = result.z;
  return GLU_TRUE;
}   

GLint gluUnProject(GLdouble  winX,  GLdouble  winY,  GLdouble  winZ,  
                   const GLdouble *  model,  const GLdouble *  proj,  
                   const GLint *  view,  GLdouble*  objX,  GLdouble*  objY,  
                   GLdouble*  objZ)
{
  int glkview[] = {view[0], view[1], view[2]};
  bool success;
  GLKVector3 result =
  GLKMathUnproject(GLKVector3Make(winX, winY, winZ),
                 GLKMatrix4Make(model[0],model[1],model[2],model[3],
                 		model[4],model[5],model[6],model[7],
                 		model[8],model[9],model[10],model[11],
                 		model[12],model[13],model[14],model[15]),
                 GLKMatrix4Make(proj[0],proj[1],proj[2],proj[3],
                 		proj[4],proj[5],proj[6],proj[7],
                 		proj[8],proj[9],proj[10],proj[11],
                 		proj[12],proj[13],proj[14],proj[15]),
                 glkview,
                 &success
                 );
  *objX = result.x;
  *objY = result.y;
  *objZ = result.z;
  return success ? GLU_TRUE : GLU_FALSE;
}               

const GLubyte * gluErrorString(GLenum  error)
{
  return (GLubyte*)"glu Error";
}
                      
#endif /* Mavericks */

#endif /* RGL_OSX */
