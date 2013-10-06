#include "api.h"
#include "rglview.h"

#include "DeviceManager.hpp"

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
  eval(lang3(fn, ScalarInteger(mouseX), ScalarInteger(mouseY)), R_GlobalEnv);
}

static void userControlEnd(void *userData)
{
  SEXP fn = (SEXP)userData;
  eval(lang1(fn), R_GlobalEnv);
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

SEXP rgl::rgl_setMouseCallbacks(SEXP button, SEXP begin, SEXP update, SEXP end)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    void* userData[3];
    userControlPtr beginCallback, updateCallback;
    userControlEndPtr endCallback;
    userCleanupPtr cleanupCallback;
    
    int b = asInteger(button);
    if (b < 1 || b > 3) error("button must be 1, 2 or 3");
    
    rglview->getMouseCallbacks(b, &beginCallback, &updateCallback, &endCallback, 
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
    
    rglview->setMouseCallbacks(b, beginCallback, updateCallback, endCallback, 
                               &userCleanup, userData);
  } else error("no rgl device is open");
  return R_NilValue;
}      
      
