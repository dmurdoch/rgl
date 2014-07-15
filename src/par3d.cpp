/* Avoid conflict with Rinternals.h */
// #undef DEBUG

#include "R.h"
#include "Rversion.h"

#include "DeviceManager.hpp"
#include "rglview.h"

#include "api.h"

/* These defines are not in the installed version of R */

#define _  
#define streql(s, t)	(!strcmp((s), (t)))

#include <Rdefines.h>
#include <Rinternals.h>

namespace rgl {
void getObserver(double* ddata, Subscene* subscene);
void setObserver(bool automatic, double* ddata, RGLView* rglview, Subscene* subscene);
}

using namespace rgl;

/* These two are currently exposed, because observer3d uses them. */
void rgl::getObserver(double* ddata, Subscene* subscene)
{
  UserViewpoint* userviewpoint = subscene->getUserViewpoint();
  Vertex res = userviewpoint->getObserver();
  ddata[0] = res.x;
  ddata[1] = res.y;
  ddata[2] = res.z;
}   

void rgl::setObserver(bool automatic, double* ddata, RGLView* rglview, Subscene* subscene)
{
    UserViewpoint* userviewpoint = subscene->getUserViewpoint();
    userviewpoint->setObserver(automatic, Vertex(ddata[0], ddata[1], ddata[2]));
    rglview->update();
}

/* These functions used to be in api.h and api.c, but are only accessed from par3d, so
   have been made static */
   
static void rgl_getZoom(double* zoom, Subscene* subscene)
{
    UserViewpoint* userviewpoint = subscene->getUserViewpoint();
    *zoom = userviewpoint->getZoom();
    CHECKGLERROR;
}

static void rgl_setZoom(double* zoom, RGLView* rglview, Subscene* subscene)
{
    UserViewpoint* userviewpoint = subscene->getUserViewpoint();
    userviewpoint->setZoom( *zoom );
    rglview->update();
    CHECKGLERROR;
}

static void rgl_getFOV(double* fov, Subscene* subscene)
{
    UserViewpoint* userviewpoint = subscene->getUserViewpoint();
    *fov = userviewpoint->getFOV();
    CHECKGLERROR;
}

static void rgl_setFOV(double* fov, RGLView* rglview, Subscene* sub)
{
  UserViewpoint* userviewpoint = sub->getUserViewpoint();
  userviewpoint->setFOV(*fov);
  rglview->update();
  CHECKGLERROR;
}

static void rgl_getIgnoreExtent(int* ignoreExtent, Device* device)
{
    *ignoreExtent = device->getIgnoreExtent();
    CHECKGLERROR;
}

static void rgl_setIgnoreExtent(int* ignoreExtent, Device* device)
{
  device->setIgnoreExtent(*ignoreExtent);
  CHECKGLERROR;
}

static void rgl_getSkipRedraw(int* skipRedraw, Device* device)
{
    *skipRedraw = device->getSkipRedraw();
    CHECKGLERROR;
}

static void rgl_setSkipRedraw(int* skipRedraw, Device* device)
{
  device->setSkipRedraw(*skipRedraw);
  CHECKGLERROR;
}

static void rgl_getMouseMode(int *button, int* mode, RGLView* rglview)
{
    *mode = static_cast<int>( rglview->getMouseMode(*button) );
    CHECKGLERROR;
}

static void rgl_setMouseMode(int* button, int* mode, RGLView* rglview)
{
  rglview->setMouseMode(*button, (MouseModeID)(*mode));

  CHECKGLERROR;
}

static void rgl_getWheelMode(int* mode, RGLView* rglview)
{
    *mode = static_cast<int>( rglview->getWheelMode() );
    CHECKGLERROR;
}

static void rgl_setWheelMode(int* mode, RGLView* rglview)
{
  rglview->setWheelMode((WheelModeID)(*mode));

  CHECKGLERROR;
}

static void rgl_getUserMatrix(double* userMatrix, Subscene* subscene)
{
    subscene->getUserMatrix(userMatrix);

    CHECKGLERROR;

}

static void rgl_setUserMatrix(double* userMatrix, RGLView* rglview, Subscene* subscene)
{
  subscene->setUserMatrix(userMatrix);
  rglview->update();
  CHECKGLERROR;
}

static void rgl_getPosition(double* position, Subscene* subscene)
{
  subscene->getPosition(position);
  CHECKGLERROR;
}

static void rgl_setPosition(double* position, RGLView* rglview, Subscene* subscene)
{
    subscene->setPosition(position);
    rglview->update()

    CHECKGLERROR;
}

static void rgl_getScale(double* scale, Subscene* subscene)
{
    subscene->getScale(scale);
}

static void rgl_setScale(double* scale, RGLView* rglview, Subscene* subscene)
{

  subscene->setScale(scale);
  rglview->update();
  
  CHECKGLERROR;
}

static void rgl_getModelMatrix(double* modelMatrix, Subscene* subscene)
{ 
      const AABox& bbox = subscene->getBoundingBox();
      subscene->getModelMatrix(modelMatrix, bbox.getCenter());
      CHECKGLERROR;  	
}

static void rgl_getProjMatrix(double* projMatrix, Subscene* subscene)
{     
      for (int i=0; i<16; i++) {
        projMatrix[i] = subscene->projMatrix[i];
      }	
      CHECKGLERROR;
}

static void rgl_setViewport(double* viewport, Device* device, RGLView* rglview, Subscene* subscene)
{
  Embedding embedding;
  
  while ((embedding = subscene->getEmbedding(0)) == EMBED_INHERIT)
    subscene = subscene->getParent();

  int left, top, right, bottom;
  double x, y, width, height;
  if (embedding == EMBED_REPLACE) {
    device->getWindowRect(&left, &top, &right, &bottom);
    width = right - left;
    height = bottom - top;
    bottom = 0;
    left = 0;
  } else {
    left = subscene->getParent()->pviewport[0];
    bottom = subscene->getParent()->pviewport[1];
    width = subscene->getParent()->pviewport[2];
    height = subscene->getParent()->pviewport[3];
  }
  x = (viewport[0]-left)/width;
  y = (viewport[1]-bottom)/height;
  width = viewport[2]/width;
  height = viewport[3]/height;
  subscene->setViewport(x, y, width, height);
  rglview->update();
}	

static void rgl_getViewport(int* viewport, Subscene* subscene)
{      
      for (int i=0; i<4; i++) {
        viewport[i] = subscene->pviewport[i];
      }      
      CHECKGLERROR;
}

static void rgl_getWindowRect(int* rect, Device* device)
{
     device->getWindowRect(rect, rect+1, rect+2, rect+3);
     CHECKGLERROR;
}

static void rgl_setWindowRect(int* rect, Device* dev)
{
    dev->setWindowRect(rect[0], rect[1], rect[2], rect[3]);
    CHECKGLERROR;
}

static void rgl_getBoundingbox(double* bboxvec, Subscene* subscene)
{
      const AABox& bbox = subscene->getBoundingBox();
      bboxvec[0] = bbox.vmin.x;
      bboxvec[1] = bbox.vmax.x;
      bboxvec[2] = bbox.vmin.y;
      bboxvec[3] = bbox.vmax.y;
      bboxvec[4] = bbox.vmin.z;
      bboxvec[5] = bbox.vmax.z;

      CHECKGLERROR;
}

/* font access functions.  These are only used from par3d */

static char* rgl_getFamily(RGLView* rglview)
{
    const char* f = rglview->getFontFamily();
    char* result;
    result = R_alloc(strlen(f)+1, 1);
    strcpy(result, f);
    CHECKGLERROR;
    return result;
}

static bool rgl_setFamily(const char *family, RGLView* rglview)
{
  rglview->setFontFamily(family);
  CHECKGLERROR;
  return true;
}

static int rgl_getFont(RGLView* rglview)
{
    int result = rglview->getFontStyle();
    CHECKGLERROR;
    return result;
}

static bool rgl_setFont(int font, RGLView* rglview)
{
  rglview->setFontStyle(font);
  CHECKGLERROR;
  return true;
}

static double rgl_getCex(RGLView* rglview)
{
    double result = rglview->getFontCex();
    CHECKGLERROR;  
    return result;
}

static bool rgl_setCex(double cex, RGLView* rglview)
{
  rglview->setFontCex(cex);
  CHECKGLERROR;
  return true;
}

static int rgl_getUseFreeType(RGLView* rglview)
{
    int result = (int) rglview->getFontUseFreeType();
    CHECKGLERROR;  
    return result;
}

static bool rgl_setUseFreeType(bool useFreeType, RGLView* rglview)
{
  rglview->setFontUseFreeType(useFreeType);
  CHECKGLERROR;
  return true;
}

static char* rgl_getFontname(RGLView* rglview)
{
  char* result = NULL;

  const char* f = rglview->getFontname();
  result = R_alloc(strlen(f)+1, 1);
  strcpy(result, f);
  CHECKGLERROR;
  return result;
}

static int rgl_getAntialias(RGLView* rglview)
{
    WindowImpl* windowImpl = rglview->windowImpl;
    if (windowImpl->beginGL()) {
      int result;      
      glGetIntegerv(GL_SAMPLES, &result);
      windowImpl->endGL();
      CHECKGLERROR;
      return result;
    }
  return 1;
}

static int rgl_getMaxClipPlanes()
{
  int result;
  glGetError();
  glGetIntegerv(GL_MAX_CLIP_PLANES, &result);
  if (glGetError() == GL_NO_ERROR)
    return result;
  else
    return 6;
}  


/* par3d implementation based on R's par implementation
 *
 *  Main functions:
 *	par3d(.)	
 *	Specify(.)	[ par(what = value) ]
 *	Query(.)	[ par(what) ]
 */

static void par_error(const char *what)
{
    error(_("invalid value specified for rgl parameter \"%s\""),  what);
}

static void lengthCheck(const char *what, SEXP v, int n)
{
    if (length(v) != n)
	error(_("parameter \"%s\" has the wrong length"), what);
}

static void dimCheck(const char *what, SEXP v, int r, int c)
{
    SEXP dim = coerceVector(getAttrib(v, R_DimSymbol), INTSXP);
    if (length(dim) != 2 || INTEGER(dim)[0] != r || INTEGER(dim)[1] != c)
    	error(_("parameter \"%s\" has the wrong dimension"), what);
}

#ifdef UNUSED
static void nonnegIntCheck(int x, const char *s)
{
    if (x == NA_INTEGER || x < 0)
	par_error(s);
}

static void posIntCheck(int x, const char *s)
{
    if (x == NA_INTEGER || x <= 0)
	par_error(s);
}

static void naIntCheck(int x, const char *s)
{
    if (x == NA_INTEGER)
	par_error(s);
}
#endif

static void posRealCheck(double x, const char *s)
{
    if (!R_FINITE(x) || x <= 0)
	par_error(s);
}

#ifdef UNUSED
static void nonnegRealCheck(double x, const char *s)
{
    if (!R_FINITE(x) || x < 0)
	par_error(s);
}

static void naRealCheck(double x, const char *s)
{
    if (!R_FINITE(x))
	par_error(s);
}
#endif

static void BoundsCheck(double x, double a, double b, const char *s)
{
/* Check if   a <= x <= b */
    if (!R_FINITE(x) || (R_FINITE(a) && x < a) || (R_FINITE(b) && x > b))
	par_error(s);
}

/* These modes must match the definitions of mmTRACKBALL etc in rglview.h ! */ 

namespace rgl {
const char* mouseModes[] = {"none", "trackball", "xAxis", "yAxis", "zAxis", "polar", "selecting", "zoom", "fov", "user"};
const char* wheelModes[] = {"none", "push", "pull", "user"};
const char* viewportlabels[] = {"x", "y", "width", "height"};
}

#define mmLAST 10
#define wmLAST  4

/* At R 2.6.0, the type of the first arg to psmatch changed to const char *.  Conditionally cast 
   to char * if we're in an old version */
#if defined(R_VERSION) && R_VERSION < R_Version(2, 6, 0)
#define OLDCAST (char *)
#else
#define OLDCAST
#endif


static void Specify(Device* dev, RGLView* rglview, Subscene* sub, const char *what, SEXP value)
{
 
 /* Do NOT forget to update  ../R/par3d.R */
 /* if you  ADD a NEW  par !! 

 */
    SEXP x;
    double v;
    int iv;
    int success = 1;

    if (streql(what, "FOV")) {
    	lengthCheck(what, value, 1);	v = asReal(value);
	BoundsCheck(v, 0.0, 179.0, what);
	rgl_setFOV(&v, rglview, sub);
    }
    else if (streql(what, "ignoreExtent")) {
    	lengthCheck(what, value, 1);	iv = asLogical(value);
    	rgl_setIgnoreExtent(&iv, dev);
    }    
    else if (streql(what, "mouseMode")) {
    	value = coerceVector(value, STRSXP);
	if (length(value) > 4) par_error(what);   
        for (int i=1; i<=3 && i <= length(value); i++) {
            if (STRING_ELT(value, i-1) != NA_STRING) {
		success = 0;
		/* check exact first, then partial */
		for (int mode = 0; mode < mmLAST; mode++) {
		    if (psmatch(OLDCAST mouseModes[mode], CHAR(STRING_ELT(value, i-1)), (Rboolean)TRUE)) {
			rgl_setMouseMode(&i, &mode, rglview);
			success = 1;
			break;
		    }
		}
		if (!success) {
		    for (int mode = 0; mode < mmLAST; mode++) {
			if (psmatch(OLDCAST mouseModes[mode], CHAR(STRING_ELT(value, i-1)), (Rboolean)FALSE)) {
			    rgl_setMouseMode(&i, &mode, rglview);
			    success = 1;
			    break;
			}
		    }		
		}
		if (!success) par_error(what);
	    }
   	}
	if (length(value) == 4) {
	    if (STRING_ELT(value, 3) != NA_STRING) {
		success = 0;
		for (int mode = 0; mode < wmLAST; mode++) {
		    if (psmatch(OLDCAST wheelModes[mode], CHAR(STRING_ELT(value, 3)), (Rboolean)TRUE)) {
			rgl_setWheelMode(&mode, rglview);
			success = 1;
			break;
		    }
		}
		if (!success) {
		    for (int mode = 0; mode < wmLAST; mode++) {
			if (psmatch(OLDCAST wheelModes[mode], CHAR(STRING_ELT(value, 3)), (Rboolean)FALSE)) {
			    rgl_setWheelMode(&mode, rglview);
			    success = 1;
			    break;
			}
		    }
		}
		if (!success) par_error(what);
	    }
	}
    }
    else if (streql(what, "skipRedraw")) {
    	lengthCheck(what, value, 1);	iv = asLogical(value);
    	rgl_setSkipRedraw(&iv, dev);
    }
    else if (streql(what, "userMatrix")) {
	dimCheck(what, value, 4, 4);
	x = coerceVector(value, REALSXP);
	
	rgl_setUserMatrix(REAL(x), rglview, sub);
    }
    else if (streql(what, "scale")) {
	lengthCheck(what, value, 3);
	x = coerceVector(value, REALSXP);
	
	rgl_setScale(REAL(x), rglview, sub);
    }
    else if (streql(what, "viewport")) {
	lengthCheck(what, value, 4);
	x = coerceVector(value, REALSXP);
	rgl_setViewport(REAL(x), dev, rglview, sub);
    }
    else if (streql(what, "zoom")) {
    	lengthCheck(what, value, 1);	v = asReal(value);
	posRealCheck(v, what);
	rgl_setZoom(&v, rglview, sub);
    }
    else if (streql(what, ".position")) {
	lengthCheck(what, value, 2);
	x = coerceVector(value, REALSXP);
	
	rgl_setPosition(REAL(x), rglview, sub);
    }
    else if (streql(what, "windowRect")) {
        lengthCheck(what, value, 4);
        x = coerceVector(value, INTSXP);
        
        rgl_setWindowRect(INTEGER(x), dev);
    }    
    else if (streql(what, "family")) {
      lengthCheck(what, value, 1);
      x = coerceVector(value, STRSXP);
      if (!rgl_setFamily(CHAR(STRING_ELT(x, 0)), rglview)) success = 0;
    }
    else if (streql(what, "font")) {
      lengthCheck(what, value, 1);
      x=coerceVector(value, INTSXP);
      if (INTEGER(x)[0] < 1 || INTEGER(x)[0] > 5) { par_error(what); }
      if (!rgl_setFont(INTEGER(x)[0], rglview)) success = 0;
    }
    else if (streql(what, "cex")) {
      lengthCheck(what, value, 1);
      x=coerceVector(value, REALSXP);
      if (REAL(x)[0] <= 0) { par_error(what); }
      if (!rgl_setCex(REAL(x)[0],rglview)) success = 0;
    }
    else if (streql(what, "useFreeType")) {
      lengthCheck(what, value, 1);
      x=coerceVector(value, LGLSXP);
#ifndef HAVE_FREETYPE
      if (LOGICAL(x)[0])
          warning("FreeType not supported in this build");
#endif
      if (!rgl_setUseFreeType(LOGICAL(x)[0], rglview)) success = 0;
    }
    
     else warning(_("parameter \"%s\" cannot be set"), what);
 
    if (!success) par_error(what);
    
    return;
} 
 
 
 /* Do NOT forget to update  ../R/par3d.R */
 /* if you  ADD a NEW  par !! */
 
 
static SEXP Query(Device* dev, RGLView* rglview, Subscene* sub, const char *what)
{
    SEXP value, names;
    int i, mode, success = 1;
    char* buf;

    value = R_NilValue;
    
    if (streql(what, "FOV")) {
	value = allocVector(REALSXP, 1);
	rgl_getFOV(REAL(value), sub);
    }
    else if (streql(what, "ignoreExtent")) {
    	value = allocVector(LGLSXP, 1);
    	rgl_getIgnoreExtent(LOGICAL(value), dev);
    }    
    else if (streql(what, "modelMatrix")) {
	value = allocMatrix(REALSXP, 4, 4);
	rgl_getModelMatrix(REAL(value), sub);
    }
    else if (streql(what, "mouseMode")) {
    	PROTECT(value = allocVector(STRSXP, 4));
    	for (i=1; i<4; i++) {
	    rgl_getMouseMode(&i, &mode, rglview); 
	    if (mode < 0 || mode > mmLAST) mode = 0;
	    SET_STRING_ELT(value, i-1, mkChar(mouseModes[mode]));
    	};    
	rgl_getWheelMode(&mode, rglview);
	if (mode < 0 || mode > mmLAST) mode = 0;
	SET_STRING_ELT(value, 3, mkChar(wheelModes[mode]));
	
    	PROTECT(names = allocVector(STRSXP, 4));
    	SET_STRING_ELT(names, 0, mkChar("left"));
    	SET_STRING_ELT(names, 1, mkChar("right"));  
    	SET_STRING_ELT(names, 2, mkChar("middle"));
	SET_STRING_ELT(names, 3, mkChar("wheel"));
    	UNPROTECT(2);
    	value = namesgets(value, names);
    }
    else if (streql(what, "observer")) {
        value = allocVector(REALSXP, 3);
        rgl::getObserver(REAL(value), sub);
    }
    else if (streql(what, "projMatrix")) {
	value = allocMatrix(REALSXP, 4, 4);
	rgl_getProjMatrix(REAL(value), sub);    
    }
    else if (streql(what, "skipRedraw")) {
    	value = allocVector(LGLSXP, 1);
    	rgl_getSkipRedraw(LOGICAL(value), dev);
    }
    else if (streql(what, "userMatrix")) {
	value = allocMatrix(REALSXP, 4, 4);
	rgl_getUserMatrix(REAL(value), sub);
    }
    else if (streql(what, "scale")) {
        value = allocVector(REALSXP, 3);
        rgl_getScale(REAL(value), sub);
    }
    else if (streql(what, "viewport")) {
	PROTECT(value = allocVector(INTSXP, 4));
	rgl_getViewport(INTEGER(value), sub);
	PROTECT(names = allocVector(STRSXP, 4));
	for (i=0; i<4; i++)
	  SET_STRING_ELT(names, i, mkChar(viewportlabels[i]));
	value = namesgets(value, names);
	UNPROTECT(2);
    }
    else if (streql(what, "zoom")) {
	value = allocVector(REALSXP, 1);
	rgl_getZoom(REAL(value), sub);
    }
    else if (streql(what, "bbox")) {
      value = allocVector(REALSXP, 6);
      rgl_getBoundingbox(REAL(value), sub);
    }
    else if (streql(what, ".position")) {
      value = allocVector(REALSXP, 2);
      rgl_getPosition(REAL(value), sub);
    }
    else if (streql(what, "windowRect")) {
      value = allocVector(INTSXP, 4);
      rgl_getWindowRect(INTEGER(value), dev);
    }
    else if (streql(what, "family")) {
      buf = rgl_getFamily(rglview);
      if (buf) {
        value = mkString(buf);
      } 
    }
    else if (streql(what, "font")) {
      value = allocVector(INTSXP, 1);
      INTEGER(value)[0] = rgl_getFont(rglview);
      success = INTEGER(value)[0] >= 0;
    }
    else if (streql(what, "cex")) {
      value = allocVector(REALSXP, 1);
      REAL(value)[0] = rgl_getCex(rglview);
      success = REAL(value)[0] >= 0;
    }    
    else if (streql(what, "useFreeType")) {
      int useFreeType = rgl_getUseFreeType(rglview);
      value = allocVector(LGLSXP, 1);
      if (useFreeType < 0) {
        LOGICAL(value)[0] = false;
        success = 0;
      } else {
        LOGICAL(value)[0] = (bool)useFreeType;
      }
    }    
    else if (streql(what, "fontname")) {
      buf = rgl_getFontname(rglview);
      if (buf) {
        value = mkString(buf);
      } 
    }
    else if (streql(what, "antialias")) {
      value = allocVector(INTSXP, 1);
      INTEGER(value)[0] = rgl_getAntialias(rglview);
    }
    else if (streql(what, "maxClipPlanes")) {
	value = allocVector(INTSXP, 1);
	INTEGER(value)[0] = rgl_getMaxClipPlanes();
    }
  	
    if (! success) error(_("unknown error getting rgl parameter \"%s\""),  what);

    return value;
}

namespace rgl {
extern DeviceManager* deviceManager;
}
  
SEXP rgl::rgl_par3d(SEXP device, SEXP subscene, SEXP args)
{
    Device* dev;
    
    if (!deviceManager || !(dev = deviceManager->getDevice(asInteger(device))))
    	error(_("rgl device %d cannot be found"), asInteger(device));
    	
    RGLView* rglview = dev->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* sub = scene->getSubscene(asInteger(subscene));
    
    if (!sub)
    	error(_("rgl subscene %d cannot be found"), asInteger(subscene));
    
    SEXP value;
    int nargs;
    
    nargs = length(args);
    if (isNewList(args)) {
	SEXP oldnames, newnames, tag, val;
	int i;
	PROTECT(newnames = allocVector(STRSXP, nargs));
	PROTECT(value = allocVector(VECSXP, nargs));
	oldnames = getAttrib(args, R_NamesSymbol);
	for (i = 0 ; i < nargs ; i++) {
	    if (oldnames != R_NilValue)
		tag = STRING_ELT(oldnames, i);
	    else
		tag = R_NilValue;
	    val = VECTOR_ELT(args, i);
	    if (tag != R_NilValue && CHAR(tag)[0]) {
		SET_VECTOR_ELT(value, i, Query(dev, rglview, sub, CHAR(tag)));
		SET_STRING_ELT(newnames, i, tag);
		Specify(dev, rglview, sub, CHAR(tag), val);
		CHECKGLERROR;
	    }
	    else if (isString(val) && length(val) > 0) {
		tag = STRING_ELT(val, 0);
		if (tag != R_NilValue && CHAR(tag)[0]) {
		    SET_VECTOR_ELT(value, i, Query(dev, rglview, sub, CHAR(tag)));
		    SET_STRING_ELT(newnames, i, tag);
		    CHECKGLERROR;
		}
	    }
	    else {
		SET_VECTOR_ELT(value, i, R_NilValue);
		SET_STRING_ELT(newnames, i, R_BlankString);
	    }
	}
	setAttrib(value, R_NamesSymbol, newnames);
	UNPROTECT(2);
    }
    else {
    	error(_("invalid parameter passed to par3d()"));
    	return R_NilValue/* -Wall */;
    }
    return value;
}


