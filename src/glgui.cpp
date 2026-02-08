// C++ source
// This file is part of RGL.
//

#include <cstdio>
#ifdef HAVE_FREETYPE
#include "R.h"
#endif
#include "types.h"
#include "glgui.h"
#include "gl2ps.h"
#include "opengl.h"
#include "RenderContext.h"
#include "subscene.h"
#include "platform.h"

using namespace rgl;

//
// CLASS
//   GLFont
//

GLFont::~GLFont() {
  delete [] family;
  delete [] fontname;
}

double GLFont::width(const char* text) {
  /* FIXME!!! */
  return 1;
}

GLboolean GLFont::justify(double twidth, double theight, 
                          double adjx, double adjy, double adjz,
                          int pos, const RenderContext& rc) {
#ifndef RGL_NO_OPENGL
  double basex = 0.0, basey = 0.0, basez = 0.5;
  GLboolean valid = true;
  gl2ps_centering = GL2PS_TEXT_BL;
  
  if (pos) {
    double offset = adjx, w = width("m");
    switch(pos) {
	case 0:
    case 1:
    case 3:
    case 5:
    case 6:
      adjx = 0.5;
      break;
    case 2:
      adjx = 1.0 + w*offset/twidth;
      break;
    case 4:
      adjx = -w*offset/twidth;
      break;
    }
    switch(pos) {
	case 0:
    case 2:
    case 4:
    case 5:
    case 6:
      adjy = 0.5;
      break;
    case 1:
      adjy = 1.0 + offset;
      break;
    case 3:
      adjy = -offset;
      break;
    }
    switch(pos) {
	case 0:
    case 1:
    case 2:
    case 3:
    case 4:
	  adjz = 0.5;
	  break;
    case 5:
      adjz = 1.0 + offset;
      break;
    case 6:
      adjz = -offset;
      break;
    }
  }
  
  if (adjx > 0) {
     
    if ( adjx > 0.25 && rc.gl2psActive == GL2PS_POSITIONAL) {
      if (adjx < 0.75) {
        basex = 0.5;
        gl2ps_centering = GL2PS_TEXT_B;
      } else {
        basex = 1.0;
        gl2ps_centering = GL2PS_TEXT_BR;
      }
    }
  }  

  if ((adjx != basex) || (adjy != basey) || (adjz != basez)) {
    // glGetDoublev(GL_CURRENT_RASTER_POSITION, pos1);    
    // pos1[0] = pos1[0] - scaling*twidth*(adjx-basex); 
    // pos1[1] = pos1[1] - scaling*theight*(adjy-basey);
    // pos1[2] = pos1[2] - scaling*theight*(adjz-basez)/1000.0;
    // GLint pviewport[4] = {rc.subscene->pviewport.x, 
    //                       rc.subscene->pviewport.y, 
    //                       rc.subscene->pviewport.width, 
    //                       rc.subscene->pviewport.height};
    // GLdouble modelMatrix[16], projMatrix[16];
    // rc.subscene->modelMatrix.getData(modelMatrix);
    // rc.subscene->projMatrix.getData(projMatrix);
    // gluUnProject( pos1[0], pos1[1], pos1[2], modelMatrix, projMatrix, pviewport, pos2, pos2 + 1, pos2 + 2);
    // glRasterPos3dv(pos2);
  }
  
  // glGetBooleanv(GL_CURRENT_RASTER_POSITION_VALID, &valid);
  return valid;
#else
  return 0;
#endif
}


