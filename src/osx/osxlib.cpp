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
namespace lib {
// ---------------------------------------------------------------------------
void printMessage(const char* message)
{
  warning("RGL: %s\n", message);
}
// ---------------------------------------------------------------------------
double getTime()
{
  return 0.0;
}
// ---------------------------------------------------------------------------
gui::OSXGUIFactory* gGUIFactory = 0;
gui::NULLGUIFactory* gNULLFactory = 0;
// ---------------------------------------------------------------------------
gui::GUIFactory* getGUIFactory(bool useNULLDevice)
{ 
  if (useNULLDevice)
    return gNULLFactory;
  else if (gGUIFactory)
    return gGUIFactory;
  else
    error("NSOpenGL device not initialized");  
}
// ---------------------------------------------------------------------------
const char * GUIFactoryName(bool useNULLDevice)
{
  return useNULLDevice ? "null" : "NSOpenGL";
}
// ---------------------------------------------------------------------------
bool init(bool useNULLDevice)
{
  bool success = false;
  gNULLFactory = new gui::NULLGUIFactory();
  if (useNULLDevice) {
    success = true;
  } else {
    gGUIFactory = new gui::OSXGUIFactory();
    if (!gGUIFactory->hasEventLoop()) {
	error("RGL: configured for Cocoa, must run in R.app");
    } else 
      success = true;
  }
  return success;
}
// ---------------------------------------------------------------------------
void quit()
{
  if (gGUIFactory)
    delete gGUIFactory;
  delete gNULLFactory;
  gGUIFactory = 0;
  gNULLFactory = 0;
}
// ---------------------------------------------------------------------------
} // namespace lib
// ---------------------------------------------------------------------------
#endif // RGL_COCOA
// ---------------------------------------------------------------------------


