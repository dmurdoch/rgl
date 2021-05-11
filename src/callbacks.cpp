#include "api.h"
#include "rglview.h"

#include "DeviceManager.h"

using namespace rgl;

namespace rgl {
extern DeviceManager* deviceManager;
}

/* These defines are not in the installed version of R */
#include "R.h"

#include <Rdefines.h>
#include <Rinternals.h>

static void userControl(void *userData, int mouseX, int mouseY)
{
  SEXP fn = (SEXP)userData;
  if (fn) {
  // Rprintf("userControl called with mouseX=%d userData=%p\n", mouseX, userData);
    eval(PROTECT(lang3(fn, PROTECT(ScalarInteger(mouseX)), PROTECT(ScalarInteger(mouseY)))), R_GlobalEnv);
    UNPROTECT(3);
  }
}

static void userControlEnd(void *userData)
{
  SEXP fn = (SEXP)userData;
  if (fn) {
    eval(PROTECT(lang1(fn)), R_GlobalEnv);
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
  eval(PROTECT(lang2(fn, PROTECT(ScalarInteger(dir)))), R_GlobalEnv);
  UNPROTECT(2);
}

SEXP rgl::rgl_setMouseCallbacks(SEXP button, SEXP begin, SEXP update, SEXP end,
                                SEXP dev, SEXP sub)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getDevice(asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* userData[3] = {0, 0, 0};
    userControlPtr beginCallback, updateCallback;
    userControlEndPtr endCallback;
    userCleanupPtr cleanupCallback;
    
    int b = asInteger(button);
    if (b < 0 || b > 4) error("button must be 1=left, 2=right, 3=middle, 4=wheel, or 0 for no button");

    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(asInteger(sub));
    if (!subscene) error("subscene not found");
    subscene->getMouseCallbacks(b, &beginCallback, &updateCallback, &endCallback, 
                               &cleanupCallback, (void**)&userData);
    if (isFunction(begin)) {
      beginCallback = &userControl;
      userData[0] = (void*)begin;
      R_PreserveObject(begin);
    } else if (begin == R_NilValue) beginCallback = 0;
    else error("callback must be a function");
    
    if (isFunction(update)) {
      updateCallback = &userControl;
      userData[1] = (void*)update;
      R_PreserveObject(update);
    } else if (update == R_NilValue) updateCallback = 0;
    else error("callback must be a function");
    
    if (isFunction(end)) {
      endCallback = &userControlEnd;
      userData[2] = (void*)end;
      R_PreserveObject(end);
    } else if (end == R_NilValue) endCallback = 0;
    else error("callback must be a function");
    rglview->captureLost();
    // Rprintf("setting mouse callbacks\n");
    subscene->setMouseCallbacks(b, beginCallback, updateCallback, endCallback, 
                               &userCleanup, userData);
    if (b == bnNOBUTTON)
      rglview->windowImpl->watchMouse(subscene->getRootSubscene()->mouseNeedsWatching());
    
  } else error("rgl device is not open");
  return R_NilValue;
}      

SEXP rgl::rgl_getMouseCallbacks(SEXP button, SEXP dev, SEXP sub)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getDevice(asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* userData[3] = {0, 0, 0};
    userControlPtr beginCallback, updateCallback;
    userControlEndPtr endCallback;
    userCleanupPtr cleanupCallback;
    
    int b = asInteger(button);
    if (b < 0 || b > 4) error("button must be 1=left, 2=right, 3=middle, 4=wheel, or 0 for no button");

    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(asInteger(sub));
    if (!subscene) error("subscene not found");
    subscene->getMouseCallbacks(b, &beginCallback, &updateCallback, &endCallback, 
                               &cleanupCallback, (void**)&userData);
    SEXP result;
    PROTECT(result = allocVector(VECSXP, 3));
    
    if (beginCallback == &userControl) 
      SET_VECTOR_ELT(result, 0, (SEXP)userData[0]);
    
    if (updateCallback == &userControl) 
      SET_VECTOR_ELT(result, 1, (SEXP)userData[1]);
    
    if (endCallback == &userControlEnd)
      SET_VECTOR_ELT(result, 2, (SEXP)userData[2]);

    UNPROTECT(1);
    return result;
  } else error("rgl device is not open");
  return R_NilValue;
}      
 
SEXP rgl::rgl_setWheelCallback(SEXP rotate, SEXP dev, SEXP sub)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getDevice(asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* wheelData = 0;
    userWheelPtr wheelCallback;
      
    if (isFunction(rotate)) {
      wheelCallback = &userWheel;
      wheelData = (void*)rotate;
      R_PreserveObject(rotate);
    } else if (rotate == R_NilValue) wheelCallback = 0;
    else error("callback must be a function");

    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(asInteger(sub));
    if (!subscene) error("subscene not found");
    subscene->setWheelCallback(wheelCallback, wheelData);
  } else error("rgl device is not open");
  return R_NilValue;
}

SEXP rgl::rgl_getWheelCallback(SEXP dev, SEXP sub)
{
  Device* device;
  SEXP result = R_NilValue;
  if (deviceManager && (device = deviceManager->getDevice(asInteger(dev)))) {
    RGLView* rglview = device->getRGLView();
    void* wheelData = 0;
    userWheelPtr wheelCallback;
    
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(asInteger(sub));
    if (!subscene) error("subscene not found");
    subscene->getWheelCallback(&wheelCallback, (void**)&wheelData);
    if (wheelCallback == &userWheel)
      result = (SEXP)wheelData;
  } else error("rgl device is not open");
  return result;
}      
