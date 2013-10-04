#include "../config.hpp"
// ---------------------------------------------------------------------------
#ifdef RGL_COCOA
// ---------------------------------------------------------------------------
#include "../lib.hpp"
#include "../NULLgui.hpp"

// ---------------------------------------------------------------------------
#include "osxgui.hpp"
// ---------------------------------------------------------------------------
#include "../R.h"
#include "../assert.hpp"
// ---------------------------------------------------------------------------

using namespace rgl;

void rgl::printMessage(const char* message)
{
  warning("RGL: %s\n", message);
}
// ---------------------------------------------------------------------------
double rgl::getTime()
{
  return 0.0;
}
// ---------------------------------------------------------------------------
OSXGUIFactory* gGUIFactory = 0;
NULLGUIFactory* gNULLFactory = 0;
// ---------------------------------------------------------------------------
GUIFactory* rgl::getGUIFactory(bool useNULLDevice)
{ 
  if (useNULLDevice)
    return gNULLFactory;
  else if (gGUIFactory)
    return gGUIFactory;
  else
    error("NSOpenGL device not initialized");  
}
// ---------------------------------------------------------------------------
const char * rgl::GUIFactoryName(bool useNULLDevice)
{
  return useNULLDevice ? "null" : "NSOpenGL";
}
// ---------------------------------------------------------------------------
bool rgl::init(bool useNULLDevice)
{
  bool success = false;
  gNULLFactory = new NULLGUIFactory();
  if (useNULLDevice) {
    success = true;
  } else {
    gGUIFactory = new OSXGUIFactory();
    if (!gGUIFactory->hasEventLoop()) {
	error("RGL: configured for Cocoa, must run in R.app");
    } else 
      success = true;
  }
  return success;
}
// ---------------------------------------------------------------------------
void rgl::quit()
{
  if (gGUIFactory)
    delete gGUIFactory;
  delete gNULLFactory;
  gGUIFactory = 0;
  gNULLFactory = 0;
}
// ---------------------------------------------------------------------------
#endif // RGL_COCOA
// ---------------------------------------------------------------------------


