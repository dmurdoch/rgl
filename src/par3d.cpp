/* Avoid conflict with Rinternals.h */
// #undef DEBUG

#include "R.h"
#include "Rversion.h"

#include "DeviceManager.h"
#include "rglview.h"

#include "api.h"

/* These defines are not in the installed version of R */

#define _  
#define streql(s, t)  (!strcmp((s), (t)))

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
  userviewpoint->setObserver(automatic, Vertex(static_cast<float>(ddata[0]), 
                                               static_cast<float>(ddata[1]), 
                                               static_cast<float>(ddata[2])));
  rglview->update();
}

/* These functions used to be in api.h and api.c, but are only accessed from par3d, so
 have been made static */

static void getZoom(double* zoom, Subscene* subscene)
{
  UserViewpoint* userviewpoint = subscene->getUserViewpoint();
  *zoom = userviewpoint->getZoom();
  CHECKGLERROR;
}

static void setZoom(double* zoom, RGLView* rglview, Subscene* subscene)
{
  UserViewpoint* userviewpoint = subscene->getUserViewpoint();
  userviewpoint->setZoom(static_cast<float>(*zoom) );
  rglview->update();
  CHECKGLERROR;
}

static void getFOV(double* fov, Subscene* subscene)
{
  UserViewpoint* userviewpoint = subscene->getUserViewpoint();
  *fov = userviewpoint->getFOV();
  CHECKGLERROR;
}

static void setFOV(double* fov, RGLView* rglview, Subscene* sub)
{
  UserViewpoint* userviewpoint = sub->getUserViewpoint();
  userviewpoint->setFOV(static_cast<float>(*fov));
  rglview->update();
  CHECKGLERROR;
}

static void getIgnoreExtent(int* ignoreExtent, Device* device)
{
  *ignoreExtent = device->getIgnoreExtent();
  CHECKGLERROR;
}

static void setIgnoreExtent(int* ignoreExtent, Device* device)
{
  device->setIgnoreExtent(*ignoreExtent);
  CHECKGLERROR;
}

static void getSkipRedraw(int* skipRedraw, Device* device)
{
  *skipRedraw = device->getSkipRedraw();
  CHECKGLERROR;
}

static void setSkipRedraw(int* skipRedraw, Device* device)
{
  device->setSkipRedraw(*skipRedraw);
  CHECKGLERROR;
}

static void getMouseMode(int *button, int* mode, Subscene* subscene)
{
  *mode = static_cast<int>( subscene->getMouseMode(*button) );
  CHECKGLERROR;
}

static void setMouseMode(int* button, int* mode, RGLView* rglview, Subscene* subscene)
{
  subscene->setMouseMode(*button, (MouseModeID)(*mode));
  if (*button == bnNOBUTTON)
    rglview->windowImpl->watchMouse(subscene->getRootSubscene()->mouseNeedsWatching());
  CHECKGLERROR;
}

static void getUserMatrix(double* userMatrix, Subscene* subscene)
{
  subscene->getUserMatrix(userMatrix);
  
  CHECKGLERROR;
  
}

static void setUserMatrix(double* userMatrix, RGLView* rglview, Subscene* subscene)
{
  subscene->setUserMatrix(userMatrix);
  rglview->update();
  CHECKGLERROR;
}

static void getUserProjection(double* userProjection, Subscene* subscene)
{
  subscene->getUserProjection(userProjection);
  
  CHECKGLERROR;
  
}

static void setUserProjection(double* userProjection, RGLView* rglview, Subscene* subscene)
{
  subscene->setUserProjection(userProjection);
  rglview->update();
  CHECKGLERROR;
}

static void getPosition(double* position, Subscene* subscene)
{
  subscene->getPosition(position);
  CHECKGLERROR;
}

static void setPosition(double* position, RGLView* rglview, Subscene* subscene)
{
  subscene->setPosition(position);
  rglview->update()
    
    CHECKGLERROR;
}

static void getScale(double* scale, Subscene* subscene)
{
  subscene->getScale(scale);
}

static void setScale(double* scale, RGLView* rglview, Subscene* subscene)
{
  
  subscene->setScale(scale);
  rglview->update();
  
  CHECKGLERROR;
}

static void setViewport(double* viewport, Device* device, RGLView* rglview, Subscene* subscene)
{
  subscene = subscene->getMaster(EM_VIEWPORT);
  
  int left, top, right, bottom;
  double x, y, width, height;
  if (subscene->getEmbedding(EM_VIEWPORT) == EMBED_REPLACE) {
    device->getWindowRect(&left, &top, &right, &bottom);
    width = right - left;
    height = bottom - top;
    bottom = 0;
    left = 0;
  } else {
    left = subscene->getParent()->pviewport.x;
    bottom = subscene->getParent()->pviewport.y;
    width = subscene->getParent()->pviewport.width;
    height = subscene->getParent()->pviewport.height;
  }
  x = (viewport[0]-left)/width;
  y = (viewport[1]-bottom)/height;
  width = viewport[2]/width;
  height = viewport[3]/height;
  subscene->setViewport(x, y, width, height);
  rglview->update();
}  

static void getViewport(int* viewport, Subscene* subscene)
{      
  viewport[0] = subscene->pviewport.x;
  viewport[1] = subscene->pviewport.y;
  viewport[2] = subscene->pviewport.width;
  viewport[3] = subscene->pviewport.height;
  CHECKGLERROR;
}

static void getWindowRect(int* rect, Device* device)
{
  device->getWindowRect(rect, rect+1, rect+2, rect+3);
  CHECKGLERROR;
}

static void setWindowRect(int* rect, Device* dev)
{
  dev->setWindowRect(rect[0], rect[1], rect[2], rect[3]);
  CHECKGLERROR;
}

static void getBoundingbox(double* bboxvec, Subscene* subscene)
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

static char* getFamily(RGLView* rglview)
{
  const char* f = rglview->getFontFamily();
  char* result;
  result = R_alloc(strlen(f)+1, 1);
  strcpy(result, f);
  CHECKGLERROR;
  return result;
}

static bool setFamily(const char *family, RGLView* rglview)
{
  rglview->setFontFamily(family);
  CHECKGLERROR;
  return true;
}

static int getFont(RGLView* rglview)
{
  int result = rglview->getFontStyle();
  CHECKGLERROR;
  return result;
}

static bool setFont(int font, RGLView* rglview)
{
  rglview->setFontStyle(font);
  CHECKGLERROR;
  return true;
}

static double getCex(RGLView* rglview)
{
  double result = rglview->getFontCex();
  CHECKGLERROR;  
  return result;
}

static bool setCex(double cex, RGLView* rglview)
{
  rglview->setFontCex(cex);
  CHECKGLERROR;
  return true;
}

static int getUseFreeType(RGLView* rglview)
{
  int result = (int) rglview->getFontUseFreeType();
  CHECKGLERROR;  
  return result;
}

static bool setUseFreeType(bool useFreeType, RGLView* rglview)
{
  rglview->setFontUseFreeType(useFreeType);
  CHECKGLERROR;
  return true;
}

static char* getFontname(RGLView* rglview)
{
  char* result = NULL;
  
  const char* f = rglview->getFontname();
  result = R_alloc(strlen(f)+1, 1);
  strcpy(result, f);
  CHECKGLERROR;
  return result;
}

static int getAntialias(RGLView* rglview)
{
  return rglview->windowImpl->getAntialias();
}

static int getMaxClipPlanes(RGLView* rglview)
{
  return rglview->windowImpl->getMaxClipPlanes();
}  

static double getGlVersion()
{
#ifndef RGL_NO_OPENGL
  const char* version = (const char*)glGetString(GL_VERSION);
  if (version) return atof(version);
  else 
#endif
    return R_NaReal;
}

static int activeSubscene(RGLView* rglview)
{
  return rglview->getActiveSubscene();
}

/* par3d implementation based on R's par implementation
 *
 *  Main functions:
 *  par3d(.)  
 *  Specify(.)  [ par(what = value) ]
 *  Query(.)  [ par(what) ]
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
const char* mouseModes[] = {"none", "trackball", "xAxis", "yAxis", "zAxis", "polar", "selecting", "zoom", "fov", "user",
                            "push", "pull", "user2"};
const char* viewportlabels[] = {"x", "y", "width", "height"};
}

#define mmLAST 10
#define wmLAST 13

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
    lengthCheck(what, value, 1);  v = asReal(value);
    BoundsCheck(v, 0.0, 179.0, what);
    setFOV(&v, rglview, sub);
  }
  else if (streql(what, "ignoreExtent")) {
    lengthCheck(what, value, 1);  iv = asLogical(value);
    setIgnoreExtent(&iv, dev);
  }    
  else if (streql(what, "mouseMode")) {
    value = coerceVector(value, STRSXP);
    if (length(value) > 5) par_error(what);   
    for (int i=bnNOBUTTON; i<=bnWHEEL && i <= length(value); i++) {
      if (STRING_ELT(value, i) != NA_STRING) {
        success = 0;
        /* check exact first, then partial */
        for (int mode = 0; mode < (i != bnWHEEL ? mmLAST : wmLAST) ; mode++) {
          if (psmatch(OLDCAST mouseModes[mode], CHAR(STRING_ELT(value, i)), (Rboolean)TRUE)) {
            setMouseMode(&i, &mode, rglview, sub);
            success = 1;
            break;
          }
        }
        if (!success) {
          for (int mode = 0; mode < (i != 4 ? mmLAST : wmLAST) ; mode++) {
            if (psmatch(OLDCAST mouseModes[mode], CHAR(STRING_ELT(value, i)), (Rboolean)FALSE)) {
              setMouseMode(&i, &mode, rglview, sub);
              success = 1;
              break;
            }
          }    
        }
        if (!success) par_error(what);
      }
    }
  }
  else if (streql(what, "listeners")) {
    x = coerceVector(value, INTSXP);
    rglview->setMouseListeners(sub, length(x), INTEGER(x));
  }
  else if (streql(what, "skipRedraw")) {
    lengthCheck(what, value, 1);  iv = asLogical(value);
    setSkipRedraw(&iv, dev);
  }
  else if (streql(what, "userMatrix")) {
    dimCheck(what, value, 4, 4);
    x = coerceVector(value, REALSXP);
    
    setUserMatrix(REAL(x), rglview, sub);
  }
  else if (streql(what, "userProjection")) {
    dimCheck(what, value, 4, 4);
    x = coerceVector(value, REALSXP);
    setUserProjection(REAL(x), rglview, sub);
  }
  else if (streql(what, "scale")) {
    lengthCheck(what, value, 3);
    x = coerceVector(value, REALSXP);
    
    setScale(REAL(x), rglview, sub);
  }
  else if (streql(what, "viewport")) {
    lengthCheck(what, value, 4);
    x = coerceVector(value, REALSXP);
    setViewport(REAL(x), dev, rglview, sub);
  }
  else if (streql(what, "zoom")) {
    lengthCheck(what, value, 1);  v = asReal(value);
    posRealCheck(v, what);
    setZoom(&v, rglview, sub);
  }
  else if (streql(what, ".position")) {
    lengthCheck(what, value, 2);
    x = coerceVector(value, REALSXP);
    
    setPosition(REAL(x), rglview, sub);
  }
  else if (streql(what, "windowRect")) {
    lengthCheck(what, value, 4);
    x = coerceVector(value, INTSXP);
    
    setWindowRect(INTEGER(x), dev);
  }    
  else if (streql(what, "family")) {
    lengthCheck(what, value, 1);
    x = coerceVector(value, STRSXP);
    if (!setFamily(CHAR(STRING_ELT(x, 0)), rglview)) success = 0;
  }
  else if (streql(what, "font")) {
    lengthCheck(what, value, 1);
    x=coerceVector(value, INTSXP);
    if (INTEGER(x)[0] < 1 || INTEGER(x)[0] > 5) { par_error(what); }
    if (!setFont(INTEGER(x)[0], rglview)) success = 0;
  }
  else if (streql(what, "cex")) {
    lengthCheck(what, value, 1);
    x=coerceVector(value, REALSXP);
    if (REAL(x)[0] <= 0) { par_error(what); }
    if (!setCex(REAL(x)[0],rglview)) success = 0;
  }
  else if (streql(what, "useFreeType")) {
    lengthCheck(what, value, 1);
    x=coerceVector(value, LGLSXP);
#ifndef HAVE_FREETYPE
    if (LOGICAL(x)[0] && strcmp( dev->getDevtype(), "null" ))
      warning("FreeType not supported in this build");
#endif
    if (!setUseFreeType(LOGICAL(x)[0], rglview)) success = 0;
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
    PROTECT(value = allocVector(REALSXP, 1));
    getFOV(REAL(value), sub);
  }
  else if (streql(what, "ignoreExtent")) {
    PROTECT(value = allocVector(LGLSXP, 1));
    getIgnoreExtent(LOGICAL(value), dev);
  }    
  else if (streql(what, "modelMatrix")) {
    PROTECT(value = allocMatrix(REALSXP, 4, 4));
    sub->modelMatrix.getData(REAL(value));
  }
  else if (streql(what, "mouseMode")) {
    PROTECT(value = allocVector(STRSXP, 5));
    for (i=0; i<5; i++) {
      getMouseMode(&i, &mode, sub); 
      if (mode < 0 || mode > wmLAST) mode = 0;
      SET_STRING_ELT(value, i, mkChar(mouseModes[mode]));
    }

    PROTECT(names = allocVector(STRSXP, 5));
    SET_STRING_ELT(names, 0, mkChar("none"));
    SET_STRING_ELT(names, 1, mkChar("left"));
    SET_STRING_ELT(names, 2, mkChar("right"));  
    SET_STRING_ELT(names, 3, mkChar("middle"));
    SET_STRING_ELT(names, 4, mkChar("wheel"));
    value = namesgets(value, names);
    UNPROTECT(2); /* names and old values */
    PROTECT(value);
  }
  else if (streql(what, "observer")) {
    PROTECT(value = allocVector(REALSXP, 3));
    rgl::getObserver(REAL(value), sub);
  }
  else if (streql(what, "projMatrix")) {
    PROTECT(value = allocMatrix(REALSXP, 4, 4));
    sub->projMatrix.getData(REAL(value));    
  }
  else if (streql(what, "listeners")) {
    PROTECT(value = allocVector(INTSXP, sub->mouseListeners.size()));
    sub->getMouseListeners(length(value), INTEGER(value));
  }
  else if (streql(what, "skipRedraw")) {
    PROTECT(value = allocVector(LGLSXP, 1));
    getSkipRedraw(LOGICAL(value), dev);
  }
  else if (streql(what, "userMatrix")) {
    PROTECT(value = allocMatrix(REALSXP, 4, 4));
    getUserMatrix(REAL(value), sub);
  }
  else if (streql(what, "userProjection")) {
    PROTECT(value = allocMatrix(REALSXP, 4, 4));
    getUserProjection(REAL(value), sub);
  }
  else if (streql(what, "scale")) {
    PROTECT(value = allocVector(REALSXP, 3));
    getScale(REAL(value), sub);
  }
  else if (streql(what, "viewport")) {
    PROTECT(value = allocVector(INTSXP, 4));
    getViewport(INTEGER(value), sub);
    PROTECT(names = allocVector(STRSXP, 4));
    for (i=0; i<4; i++)
      SET_STRING_ELT(names, i, mkChar(viewportlabels[i]));
    value = namesgets(value, names);
    UNPROTECT(2);
    PROTECT(value);
  }
  else if (streql(what, "zoom")) {
    PROTECT(value = allocVector(REALSXP, 1));
    getZoom(REAL(value), sub);
  }
  else if (streql(what, "bbox")) {
    PROTECT(value = allocVector(REALSXP, 6));
    getBoundingbox(REAL(value), sub);
  }
  else if (streql(what, ".position")) {
    PROTECT(value = allocVector(REALSXP, 2));
    getPosition(REAL(value), sub);
  }
  else if (streql(what, "windowRect")) {
    PROTECT(value = allocVector(INTSXP, 4));
    getWindowRect(INTEGER(value), dev);
  }
  else if (streql(what, "family")) {
    buf = getFamily(rglview);
    if (buf) {
      value = mkString(buf);
    }
    PROTECT(value);
  }
  else if (streql(what, "font")) {
    PROTECT(value = allocVector(INTSXP, 1));
    INTEGER(value)[0] = getFont(rglview);
    success = INTEGER(value)[0] >= 0;
  }
  else if (streql(what, "cex")) {
    PROTECT(value = allocVector(REALSXP, 1));
    REAL(value)[0] = getCex(rglview);
    success = REAL(value)[0] >= 0;
  }    
  else if (streql(what, "useFreeType")) {
    int useFreeType = getUseFreeType(rglview);
    PROTECT(value = allocVector(LGLSXP, 1));
    if (useFreeType < 0) {
      LOGICAL(value)[0] = false;
      success = 0;
    } else {
      LOGICAL(value)[0] = (bool)useFreeType;
    }
  }    
  else if (streql(what, "fontname")) {
    buf = getFontname(rglview);
    if (buf) {
      value = mkString(buf);
    } 
    PROTECT(value);
  }
  else if (streql(what, "antialias")) {
    PROTECT(value = allocVector(INTSXP, 1));
    INTEGER(value)[0] = getAntialias(rglview);
  }
  else if (streql(what, "maxClipPlanes")) {
    PROTECT(value = allocVector(INTSXP, 1));
    INTEGER(value)[0] = getMaxClipPlanes(rglview);
  }
  else if (streql(what, "glVersion")) {
    PROTECT(value = allocVector(REALSXP, 1));
    REAL(value)[0] = getGlVersion();
  }
  else if (streql(what, "activeSubscene")) {
    PROTECT(value = allocVector(INTSXP, 1));
    INTEGER(value)[0] = activeSubscene(rglview);
  } else
    PROTECT(value);
  
  UNPROTECT(1);
  
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
    PROTECT(oldnames = getAttrib(args, R_NamesSymbol));
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
    UNPROTECT(3);
  }
  else {
    error(_("invalid parameter passed to par3d()"));
    return R_NilValue/* -Wall */;
  }
  return value;
}


