#include "rglview.h"
#include "DeviceManager.h"
#include "api.h"

using namespace rgl;

namespace rgl {
extern DeviceManager* deviceManager;
}

/* These defines are not in the installed version of R */
#include "R.h"

#include <Rinternals.h>

static void userControl(void *userData, int mouseX, int mouseY)
{
  SEXP fn = (SEXP)userData;
  if (fn) {
  // Rprintf("userControl called with mouseX=%d userData=%p\n", mouseX, userData);
    Rf_eval(PROTECT(Rf_lang3(fn, PROTECT(Rf_ScalarInteger(mouseX)), PROTECT(Rf_ScalarInteger(mouseY)))), R_GlobalEnv);
    UNPROTECT(3);
  }
}

static void userControlEnd(void *userData)
{
  SEXP fn = (SEXP)userData;
  if (fn) {
    Rf_eval(PROTECT(Rf_lang1(fn)), R_GlobalEnv);
    UNPROTECT(1);
  }
}

static void userCleanup(void **userData)
{
  for (int i=0; i<3; i++) {
    if (userData[i]) {
      R_ReleaseObject((SEXP)userData[i]);
      userData[i] = 0;
    }
  }
}

static void userWheel(void *wheelData, int dir)
{
  SEXP fn = (SEXP)wheelData;
  Rf_eval(PROTECT(Rf_lang2(fn, PROTECT(Rf_ScalarInteger(dir)))), R_GlobalEnv);
  UNPROTECT(2);
}

SEXP rgl::rgl_setMouseCallbacks(SEXP button, SEXP begin, SEXP update, SEXP end,
                                SEXP dev, SEXP sub)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getDevice(Rf_asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* userData[3] = {0, 0, 0};
    userControlPtr beginCallback, updateCallback;
    userControlEndPtr endCallback;
    userCleanupPtr cleanupCallback;
    
    int b = Rf_asInteger(button);
    if (b < 0 || b > 4) Rf_error("button must be 1=left, 2=right, 3=middle, 4=wheel, or 0 for no button");

    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(Rf_asInteger(sub));
    if (!subscene) Rf_error("subscene not found");
    subscene->getMouseCallbacks(b, &beginCallback, &updateCallback, &endCallback, 
                               &cleanupCallback, (void**)&userData);
    if (Rf_isFunction(begin)) {
      beginCallback = &userControl;
      userData[0] = (void*)begin;
      R_PreserveObject(begin);
    } else if (begin == R_NilValue) beginCallback = 0;
    else Rf_error("callback must be a function");
    
    if (Rf_isFunction(update)) {
      updateCallback = &userControl;
      userData[1] = (void*)update;
      R_PreserveObject(update);
    } else if (update == R_NilValue) updateCallback = 0;
    else Rf_error("callback must be a function");
    
    if (Rf_isFunction(end)) {
      endCallback = &userControlEnd;
      userData[2] = (void*)end;
      R_PreserveObject(end);
    } else if (end == R_NilValue) endCallback = 0;
    else Rf_error("callback must be a function");
    rglview->captureLost();
    // Rprintf("setting mouse callbacks\n");
    subscene->setMouseCallbacks(b, beginCallback, updateCallback, endCallback, 
                               &userCleanup, userData);
    if (b == bnNOBUTTON)
      rglview->windowImpl->watchMouse(subscene->getRootSubscene()->mouseNeedsWatching());
    
  } else Rf_error("rgl device is not open");
  return R_NilValue;
}      

SEXP rgl::rgl_getMouseCallbacks(SEXP button, SEXP dev, SEXP sub)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getDevice(Rf_asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* userData[3] = {0, 0, 0};
    userControlPtr beginCallback, updateCallback;
    userControlEndPtr endCallback;
    userCleanupPtr cleanupCallback;
    
    int b = Rf_asInteger(button);
    if (b < 0 || b > 4) Rf_error("button must be 1=left, 2=right, 3=middle, 4=wheel, or 0 for no button");

    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(Rf_asInteger(sub));
    if (!subscene) Rf_error("subscene not found");
    subscene->getMouseCallbacks(b, &beginCallback, &updateCallback, &endCallback, 
                               &cleanupCallback, (void**)&userData);
    SEXP result;
    PROTECT(result = Rf_allocVector(VECSXP, 3));
    
    if (beginCallback == &userControl) 
      SET_VECTOR_ELT(result, 0, (SEXP)userData[0]);
    
    if (updateCallback == &userControl) 
      SET_VECTOR_ELT(result, 1, (SEXP)userData[1]);
    
    if (endCallback == &userControlEnd)
      SET_VECTOR_ELT(result, 2, (SEXP)userData[2]);

    UNPROTECT(1);
    return result;
  } else Rf_error("rgl device is not open");
  return R_NilValue;
}      
 
SEXP rgl::rgl_setWheelCallback(SEXP rotate, SEXP dev, SEXP sub)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getDevice(Rf_asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* wheelData = 0;
    userWheelPtr wheelCallback;
      
    if (Rf_isFunction(rotate)) {
      wheelCallback = &userWheel;
      wheelData = (void*)rotate;
      R_PreserveObject(rotate);
    } else if (rotate == R_NilValue) wheelCallback = 0;
    else Rf_error("callback must be a function");

    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(Rf_asInteger(sub));
    if (!subscene) Rf_error("subscene not found");
    subscene->setWheelCallback(wheelCallback, wheelData);
  } else Rf_error("rgl device is not open");
  return R_NilValue;
}

SEXP rgl::rgl_getWheelCallback(SEXP dev, SEXP sub)
{
  Device* device;
  SEXP result = R_NilValue;
  if (deviceManager && (device = deviceManager->getDevice(Rf_asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* wheelData = 0;
    userWheelPtr wheelCallback;
    
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(Rf_asInteger(sub));
    if (!subscene) Rf_error("subscene not found");
    subscene->getWheelCallback(&wheelCallback, (void**)&wheelData);
    if (wheelCallback == &userWheel)
      result = (SEXP)wheelData;
  } else Rf_error("rgl device is not open");
  return result;
}      

static void userAxis(void *axisData, int axis, int edge[3])
{
  SEXP fn = (SEXP)axisData;
  char margin[4] = "   ";
  int i, j = 1;
  margin[0] = 'x' + axis;
  for (i = 0; i < 3 && j < 3; i++) {
    if (edge[i] == 1)
      margin[j++] = '+';
    else if (edge[i] == -1)
      margin[j++] = '-';
  }
  margin[j] = 0;
  // Rprintf("margin=%s\n", margin);
  Rf_eval(PROTECT(Rf_lang2(fn, PROTECT(Rf_ScalarString(Rf_mkChar(margin))))), R_GlobalEnv);
  UNPROTECT(2);
}

SEXP rgl::rgl_setAxisCallback(SEXP draw, SEXP dev, SEXP sub, SEXP axis)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getDevice(Rf_asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* axisData = 0;
    userAxisPtr axisCallback;
    
    if (Rf_isFunction(draw)) {
      axisCallback = &userAxis;
      axisData = (void*)draw;
      R_PreserveObject(draw);
    } else if (draw == R_NilValue) axisCallback = 0;
    else Rf_error("callback must be a function");
    
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(Rf_asInteger(sub));
    if (!subscene) Rf_error("subscene not found");
    BBoxDeco* bboxdeco = subscene->get_bboxdeco();
    if (!bboxdeco) Rf_error("no bbox decoration");
    int a = Rf_asInteger(axis);
    if (a < 0 || a > 2) Rf_error("axis must be 0=x, 1=y, or 2=z");
    bboxdeco->setAxisCallback(axisCallback, axisData, a);
    rglview->update();
  } else Rf_error("rgl device is not open");
  return R_NilValue;
}

SEXP rgl::rgl_getAxisCallback(SEXP dev, SEXP sub, SEXP axis)
{
  Device* device;
  SEXP result = R_NilValue;
  if (deviceManager && (device = deviceManager->getDevice(Rf_asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* axisData = 0;
    userAxisPtr axisCallback;
    
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(Rf_asInteger(sub));
    if (!subscene) Rf_error("subscene not found");
    BBoxDeco* bboxdeco = subscene->get_bboxdeco();
    if (!bboxdeco) Rf_error("bboxdeco not found");
    bboxdeco->getAxisCallback(&axisCallback, (void**)&axisData, Rf_asInteger(axis));
    
    if (axisCallback == &userAxis)
      result = (SEXP)axisData;
  } else Rf_error("rgl device is not open");
  return result;
}      
